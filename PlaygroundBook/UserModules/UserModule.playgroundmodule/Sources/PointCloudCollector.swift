/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The host app renderer.
*/

import Metal
import MetalKit
import ARKit

enum TextureIndices : UInt32 {
    case kTextureY = 0
    case kTextureCbCr = 1
    case kTextureDepth = 2
    case kTextureConfidence = 3
}

enum BufferIndices : UInt32 {
    case kPointCloudUniforms = 0
    case kParticleUniforms = 1
    case kGridPoints = 2
}


struct PointCloudUniforms {
    var viewProjectionMatrix : matrix_float4x4;
    var localToWorld : matrix_float4x4;
    var cameraIntrinsicsInversed : matrix_float3x3;
    var cameraResolution : simd_float2;
    
    var particleSize : Float;
    var maxPoints: Int32; // int in metal -> A signed two’s complement 32-bit integer. // https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
    var pointCloudCurrentIndex : Int32;
}

struct ParticleUniforms {
    var position : simd_float3;
    var color : simd_float3;
    var confidence : Float;
}


final class PointCloudCollector {
    // Maximum number of points we store in the point cloud
    private let maxPoints = 100000
    // Number of sample points on the grid
    private let numGridPoints = 1000
    // Particle's size in pixels
    private let particleSize: Float = 10
    // We only use landscape orientation in this app
    private let orientation = UIInterfaceOrientation.landscapeRight
    // Camera's threshold values for detecting when the camera moves so that we can accumulate the points
    private let cameraRotationThreshold = cos(2 * .degreesToRadian)
    private let cameraTranslationThreshold: Float = pow(0.02, 2)   // (meter-squared)
    // The max number of command buffers in flight
    private let maxInFlightBuffers = 4
    
    private lazy var rotateToARCamera = Self.makeRotateToARCameraMatrix(orientation: orientation)
    private let session: ARSession
    
    // Metal objects and textures
    private let device: MTLDevice
    private var library: MTLLibrary
    private let depthStencilState: MTLDepthStencilState
    private let commandQueue: MTLCommandQueue
    private lazy var unprojectPipelineState = makeUnprojectionPipelineState()!
    private let offlineTextureDescriptor : MTLTextureDescriptor = MTLTextureDescriptor()
    private var offlineRenderPassDescriptor : MTLRenderPassDescriptor = MTLRenderPassDescriptor()
    private var offlineTexture : MTLTexture?
    // texture cache for captured image
    private lazy var textureCache = makeTextureCache()
    private var capturedImageTextureY: CVMetalTexture?
    private var capturedImageTextureCbCr: CVMetalTexture?
    private var depthTexture: CVMetalTexture?
    private var confidenceTexture: CVMetalTexture?
    
    // Multi-buffer rendering pipeline
    private let inFlightSemaphore: DispatchSemaphore
    private var currentBufferIndex = 0
    
    // The current viewport size
    private var viewportSize = CGSize()
    // The grid of sample points
    private lazy var gridPointsBuffer = MetalBuffer<Float2>(device: device,
                                                            array: makeGridPoints(),
                                                            index: BufferIndices.kGridPoints.rawValue, options: [])
    

    // Point Cloud buffer
    private lazy var pointCloudUniforms: PointCloudUniforms = {
        var uniforms = PointCloudUniforms(viewProjectionMatrix: matrix_identity_float4x4, localToWorld: matrix_identity_float4x4, cameraIntrinsicsInversed: matrix_identity_float3x3, cameraResolution: cameraResolution, particleSize: particleSize, maxPoints: Int32(maxPoints), pointCloudCurrentIndex: 0)
        return uniforms
    }()
    private var pointCloudUniformsBuffers = [MetalBuffer<PointCloudUniforms>]()
    // Particles buffer
    public var particlesBuffer: MetalBuffer<ParticleUniforms>
    public var currentPointIndex = 0
    public var currentPointCount = 0
    
    // Camera data
    private var sampleFrame: ARFrame { session.currentFrame! }
    private lazy var cameraResolution = Float2(Float(sampleFrame.camera.imageResolution.width), Float(sampleFrame.camera.imageResolution.height))
    private lazy var viewToCamera = sampleFrame.displayTransform(for: orientation, viewportSize: viewportSize).inverted()
    private lazy var lastCameraTransform = sampleFrame.camera.transform
    
    var pointCloudsUpdated: (() -> Void)?
    
    init(session: ARSession, metalDevice device: MTLDevice) {
        self.session = session
        self.device = device
        
        offlineTextureDescriptor.textureType = .type2D
        offlineTextureDescriptor.pixelFormat = .rgba8Unorm
        offlineTextureDescriptor.usage = [.renderTarget, .shaderRead]
        
        var tempLib : MTLLibrary? = nil
        do {
            try tempLib = device.makeDefaultLibrary(bundle: Bundle(for: PointCloudCollector.self))
        } catch let error {
            print(error)
        }
        
        if let tempLib = tempLib {
            library = tempLib
        } else if let path = Bundle.main.path(forResource: "Shaders", ofType: "metal") {
            do {
                try tempLib = device.makeLibrary(filepath: path)
            } catch let error {
                print(error)
            }
        }
        
        if let tempLib = tempLib {
            library = tempLib
        } else { library = device.makeDefaultLibrary()!
        }
        
        commandQueue = device.makeCommandQueue()!
        
        // initialize our buffers
        for _ in 0 ..< maxInFlightBuffers {
            pointCloudUniformsBuffers.append(.init(device: device, count: 1, index: BufferIndices.kPointCloudUniforms.rawValue))
        }
        particlesBuffer = .init(device: device, count: maxPoints, index: BufferIndices.kParticleUniforms.rawValue)

        
        // setup depth test for point cloud
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = .lessEqual
        depthStateDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStateDescriptor)!
        
        inFlightSemaphore = DispatchSemaphore(value: maxInFlightBuffers)
    }
    
    func drawRectResized(size: CGSize) {
        if size.width == 0 || size.height == 0 {
            return
        }
        if viewportSize.width == size.width && viewportSize.height == size.height {
            return
        }
        print("drawRectResized \(size)")
        viewportSize = size
        offlineTextureDescriptor.width = Int(viewportSize.width)
        offlineTextureDescriptor.height = Int(viewportSize.height)
        offlineTexture = device.makeTexture(descriptor: offlineTextureDescriptor)
        offlineRenderPassDescriptor.colorAttachments[0].texture = offlineTexture
        offlineRenderPassDescriptor.colorAttachments[0].loadAction = .load
        offlineRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        offlineRenderPassDescriptor.colorAttachments[0].storeAction = .store
    }
   
    private func updateCapturedImageTextures(frame: ARFrame) {
        // Create two textures (Y and CbCr) from the provided frame's captured image
        let pixelBuffer = frame.capturedImage
        guard CVPixelBufferGetPlaneCount(pixelBuffer) >= 2 else {
            return
        }
        
        capturedImageTextureY = makeTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .r8Unorm, planeIndex: 0)
        capturedImageTextureCbCr = makeTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .rg8Unorm, planeIndex: 1)
    }
    
    private func updateDepthTextures(frame: ARFrame) -> Bool {
        guard let depthMap = frame.sceneDepth?.depthMap,
            let confidenceMap = frame.sceneDepth?.confidenceMap else {
                return false
        }
        
        depthTexture = makeTexture(fromPixelBuffer: depthMap, pixelFormat: .r32Float, planeIndex: 0)
        confidenceTexture = makeTexture(fromPixelBuffer: confidenceMap, pixelFormat: .r8Uint, planeIndex: 0)
        
        return true
    }
    
    private func update(frame: ARFrame) {
        // frame dependent info
        let camera = frame.camera
        let cameraIntrinsicsInversed = camera.intrinsics.inverse
        let viewMatrix = camera.viewMatrix(for: orientation)
        let viewMatrixInversed = viewMatrix.inverse
        let projectionMatrix = camera.projectionMatrix(for: orientation, viewportSize: viewportSize, zNear: 0.001, zFar: 0)
        pointCloudUniforms.viewProjectionMatrix = projectionMatrix * viewMatrix
        pointCloudUniforms.localToWorld = viewMatrixInversed * rotateToARCamera
        pointCloudUniforms.cameraIntrinsicsInversed = cameraIntrinsicsInversed
    }
    
    func draw() {
        let renderDescriptor = offlineRenderPassDescriptor
        guard let currentFrame = session.currentFrame,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let _ = offlineTexture,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {
                return
        }
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        commandBuffer.addCompletedHandler { [weak self] commandBuffer in
            if let self = self {
                self.inFlightSemaphore.signal()
            }
        }
        
        // update frame data
        update(frame: currentFrame)
        updateCapturedImageTextures(frame: currentFrame)
        
        // handle buffer rotating
        currentBufferIndex = (currentBufferIndex + 1) % maxInFlightBuffers
        pointCloudUniformsBuffers[currentBufferIndex][0] = pointCloudUniforms
        
        if shouldAccumulate(frame: currentFrame), updateDepthTextures(frame: currentFrame) {
            accumulatePoints(frame: currentFrame, commandBuffer: commandBuffer, renderEncoder: renderEncoder)
        }
       
        renderEncoder.endEncoding()
        commandBuffer.commit()
    }
    
    private func shouldAccumulate(frame: ARFrame) -> Bool {
        let cameraTransform = frame.camera.transform
        return currentPointCount == 0
            || dot(cameraTransform.columns.2, lastCameraTransform.columns.2) <= cameraRotationThreshold
            || distance_squared(cameraTransform.columns.3, lastCameraTransform.columns.3) >= cameraTranslationThreshold
    }
    
    private func accumulatePoints(frame: ARFrame, commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder) {
        pointCloudUniforms.pointCloudCurrentIndex = Int32(currentPointIndex)
        
        var retainingTextures = [capturedImageTextureY, capturedImageTextureCbCr, depthTexture, confidenceTexture]
        commandBuffer.addCompletedHandler { buffer in
            retainingTextures.removeAll()
            self.pointCloudsUpdated?()
            print("pointCloudsUpdated \(self.currentPointIndex)/\(self.currentPointCount)")
        }
        
        renderEncoder.setRenderPipelineState(unprojectPipelineState)
        renderEncoder.setVertexBuffer(pointCloudUniformsBuffers[currentBufferIndex])
        renderEncoder.setVertexBuffer(particlesBuffer)
        renderEncoder.setVertexBuffer(gridPointsBuffer)
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(capturedImageTextureY!), index: Int(TextureIndices.kTextureY.rawValue))
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(capturedImageTextureCbCr!), index: Int(TextureIndices.kTextureCbCr.rawValue))
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(depthTexture!), index: Int(TextureIndices.kTextureDepth.rawValue))
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(confidenceTexture!), index: Int(TextureIndices.kTextureConfidence.rawValue))
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: gridPointsBuffer.count)
        
        currentPointIndex = (currentPointIndex + gridPointsBuffer.count) % maxPoints
        currentPointCount = min(currentPointCount + gridPointsBuffer.count, maxPoints)
        lastCameraTransform = frame.camera.transform
    }
}

// MARK: - Metal Helpers

private extension PointCloudCollector {
    func makeUnprojectionPipelineState() -> MTLRenderPipelineState? {
        guard let vertexFunction = library.makeFunction(name: "unprojectVertex") else {
                return nil
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.isRasterizationEnabled = false
        descriptor.depthAttachmentPixelFormat = .depth32Float
        descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        
        return try? device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    /// Makes sample points on camera image, also precompute the anchor point for animation
    func makeGridPoints() -> [Float2] {
        let gridArea = cameraResolution.x * cameraResolution.y
        let spacing = sqrt(gridArea / Float(numGridPoints))
        let deltaX = Int(round(cameraResolution.x / spacing))
        let deltaY = Int(round(cameraResolution.y / spacing))
        
        var points = [Float2]()
        for gridY in 0 ..< deltaY {
            let alternatingOffsetX = Float(gridY % 2) * spacing / 2
            for gridX in 0 ..< deltaX {
                let cameraPoint = Float2(alternatingOffsetX + (Float(gridX) + 0.5) * spacing, (Float(gridY) + 0.5) * spacing)
                
                points.append(cameraPoint)
            }
        }
        
        return points
    }
    
    func makeTextureCache() -> CVMetalTextureCache {
        // Create captured image texture cache
        var cache: CVMetalTextureCache!
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        
        return cache
    }
    
    func makeTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
        
        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }
    
    static func cameraToDisplayRotation(orientation: UIInterfaceOrientation) -> Int {
        switch orientation {
        case .landscapeLeft:
            return 180
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return -90
        default:
            return 0
        }
    }
    
    static func makeRotateToARCameraMatrix(orientation: UIInterfaceOrientation) -> matrix_float4x4 {
        // flip to ARKit Camera's coordinate
        let flipYZ = matrix_float4x4(
            [1, 0, 0, 0],
            [0, -1, 0, 0],
            [0, 0, -1, 0],
            [0, 0, 0, 1] )

        let rotationAngle = Float(cameraToDisplayRotation(orientation: orientation)) * .degreesToRadian
        return flipYZ * matrix_float4x4(simd_quaternion(rotationAngle, Float3(0, 0, 1)))
    }
}
