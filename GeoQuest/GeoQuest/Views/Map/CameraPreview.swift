//
//  CameraPreview.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 09/04/2026.
//

import SwiftUI
import AVFoundation


// Bridges UIKit camera preview into SwiftUI
struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var cameraModel: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        cameraModel.previewLayer.videoGravity = .resizeAspectFill
        cameraModel.previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(cameraModel.previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
