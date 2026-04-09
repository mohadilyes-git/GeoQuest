//
//  CameraModel.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 09/04/2026.
//

import SwiftUI
import AVFoundation
import Combine

// Handles all camera session logic
@MainActor
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var cameraQueue = DispatchQueue(label: "cameraQueue")
    
    var previewLayer: AVCaptureVideoPreviewLayer
    
    // Captured image passed back to CacheDetailView
    @Published var capturedImage: UIImage? = nil
    @Published var photoTaken = false
    
    override init() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
        setupSession()
    }
    
    // Set up camera input and output
    private func setupSession() {
        session.sessionPreset = .photo
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input),
              session.canAddOutput(output) else {
            return
        }
        session.addInput(input)
        session.addOutput(output)
    }
    
    // Start camera session
    func startSession() {
        cameraQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    // Stop camera session
    func stopSession() {
        cameraQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    // Take photo
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        output.capturePhoto(with: settings, delegate: self)
    }
    
    // Called when photo is taken
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.photoTaken = true
        }
    }
}
