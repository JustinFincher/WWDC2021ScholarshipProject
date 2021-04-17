//
//  ActivityViewControllerView.swift
//  UserModuleFramework
//
//  Created by fincher on 4/13/21.
//

import SwiftUI
import UIKit

struct ActivityViewControllerView: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
}
