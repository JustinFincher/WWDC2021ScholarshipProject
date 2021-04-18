# Swift Student Challenge Submission
HumanScan

# Author
Haotian Zheng ([justzht@hotmail.com](mailto:justzht@hotmail.com))

# Tell us about the features and technologies you used in your Swift playground
HumanScan is an interactive playground for capturing, rigging and applying animations to peoples in AR space. It involves four stages:
- **Environment Scanning**: HumanScan uses a lidar-enabled depth map to build up a point cloud around the person you wish to scan. Every ARFrame is processed with the Metal command queue to fill up the point cloud buffer. Then an updated SCNGeometry is built from the buffer.
- **Skeleton Tracking**: HumanScan uses ARKit 4's human tracking to acquire joint hierarchy. The hierarchy is then reduced from 91 joints to 19 joints for simplicity, with minor positioning adjustments if needed to better match the previously scanned point cloud.
- **Runtime Skinning**: HumanScan now has both mesh and skeleton information. The first it will do is build up a signed distance field based on the skeleton to filter points to isolate human point clouds from background point clouds. Then HumanScan will traverse each point (vertex) and examine the value of signed distance fields from different joints, essentially deciding which bones this particular vertex wants to follow. Finally, HumanScan creates a SCNSkinner from the calculated bone indices and weights so the skeleton can actually influence point clouds' position.
- **Animation Replay**: With the same technique in skeleton tracking, I have already pre-recorded an animation clip of myself doing hand-waving in AR space. This clip is serialized as a JSON file within the playground and will be applied to the newly created human model. Now, as the skeleton replays the same movement, the scanned point cloud will follow, demonstrating that we have created a digital clone that can perform arbitrary animations.

Frameworks used in HumanScan are SceneKit, ARKit, MetalKit, SwiftUI, and Combine. Together, HumanScan achieved point cloud generation and runtime mesh skinning. 

With word count still sufficient enough, I will explain why I have chosen to do digital clones in such a specific way (i.e., tech stacks) and address some concerns over the limitations of this playground.
- **Why use point clouds instead of meshes from ARKit?** The ARMeshAnchor in ARKit 4 provides basic meshes for scene understanding. Although they are sufficient for physical interaction, the polygon count is far from practical for human rendering. The UV and color information is also missing. I tried to do camera-space to model-space projection in the sense that the camera feed can be applied to vertex color or textures, but it ultimately failed due to the mesh being constantly updated. Point clouds as raw data sets can be cluttered, but at least it provides enough feature points.
- **Why my scanned model has choppy animations?** Two reasons. Firstly, my pre-recorded animation is somewhat already jittering, causing unnecessary shuttering. This can be fixed with a smoothed animation clip. Secondly, the way that I set up joints and signed distance fields reduces intersections and therefore reduced multiple bones in bone weight calculation. This can be fixed with more joint count and more overlapped signed distance fields.

# Beyond WWDC21 (optional)
I usually do not consider myself a typical CS student. I mean, I may get the idea of how magical the math and algorithm are, as most CS students do and enjoy. Still, most of the time, I was not the theory-oriented guy, probably not even the engineering-oriented guy, but just an application-oriented guy. As silly as it may sound, I actually believe this is a good thing, as I was constantly driven by real-life what-ifs and use-cases to learn about specific topics. It always a pleasure to build a prototype based on a cool idea and research related topics to see if a certain technique is fit for the prototype.
With that mindset, I have built some mildly interesting projects. One of them starts with a mini-golf game. So I love playing space games, and I thought to myself, man, how can I build one? I searched a lot about how No Man's Sky can utilize noise algorithm and procedural generation to create millions of planets. The first prototype I built with that knowledge was a golf game. The golf course map uses the same noise algorithm with the help of Apple GameplayKit so that it can be extended infinitely, and all was done within 1000 Swift lines. That one won WWDC 18 scholarship, and I thought, I have already built a shrink-down version, now is the time for a planet-sized golf site. The result was Epoch Core, a tech demo I built capable of randomly generating earth-like planets with mountains, grasses, and seas. The demo was on App Store for showcasing, and some people get confused, saying this is not even a meaningful product. Yeah, not every project needs to be production-ready, but the point is in the process, I learned how to write tri-planer terrain shaders and water reflections, two critical examples for me to understand computer graphics. With Epoch Core as a playground, I further researched planetary rendering techniques like volumetric clouds and floating origins. Now I am probably ready to build a universe with a working-in-progress game that truly matched my initial plan when I saw No Man's Sky, that I simply want to have one built on my own, and remember, this all starts from a simple mini-golf game. What I am trying to say is, there are many ways to do CS. You don't need to aim as high as getting to know complex systems at the beginning. Just find something you love to do and search about how to do it better. Halfway through, you look back, and chances are you have already built a complex system. That is the real magic beyond complex systems, beyond WWDC, and beyond Computer Science.

# Apps on the App Store (optional)
Developer profile: https://apps.apple.com/us/developer/haotian-zheng/id981803173
- Mapaper: a map wallpaper app that utilizes Shortcut Intents API to set Mapbox maps as wallpapers. Once featured on App Store 'Apps We Love Right Now' (https://apps.apple.com/us/app/mapaper/id1546487705)
- Contributions for GitHub: a cross-platform app (Mac / iOS / watchOS) to visualize your GitHub commits count.  Once featured on Product Hunt. (https://apps.apple.com/us/app/contributions-for-github/id1153432612)
- Epoch Core: a tech demo for my incoming space game, with working planetary rendering solutions. (https://apps.apple.com/us/app/epoch-core/id1177530091)
- Shader Node: a tech demo as a combination of GLSL shader and node-editor GUI pattern. A WWDC 20 applicant project. (https://apps.apple.com/us/app/shader-node/id1460562911)
- Golf GO: a tech demo for a golf game with infinite golf course maps written in 1000 lines of Swift code. (https://apps.apple.com/us/app/golf-go-scholarship-edition/id1380656648)

# Comments (optional)
Although I have made sure that my project won't crash as much as I can, there are some additional comments in case you faced issues:
- If you accidentally proceeded to the next step without finishing the current step, let's say you pressed next to generate skinning without actually align the model and the skeleton. Don't panic! Just close the playground and restarts the whole process.
- If you decided that the point clouds are too small, you could actually modify them to be bigger, which can create a cartoonish effect. Look for 'withPointSize' functions spread throughout the project, and change them from 15 to around 30.
- Always walk around the scene to make sure the skeleton and the human point cloud are paired and use the XYZ slider to adjust it when necessary.
Have fun!

# Résumé / CV (optional)
https://fincher.im/CV.pdf