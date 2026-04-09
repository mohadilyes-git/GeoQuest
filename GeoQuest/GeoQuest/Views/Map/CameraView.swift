//
//  CameraView.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 09/04/2026.
//

import SwiftUI

// Full screen camera with shutter button
struct CameraView: View {
    
    @StateObject private var cameraModel = CameraModel()
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            
            // Live camera preview
            CameraPreview(cameraModel: cameraModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                    
                    Text("Take photo as evidence")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
                
                // Shutter button
                Button {
                    cameraModel.capturePhoto()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.gqLeafGreen, lineWidth: 3)
                        )
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            cameraModel.startSession()
        }
        .onDisappear {
            cameraModel.stopSession()
        }
        .onChange(of: cameraModel.photoTaken) { taken in
            if taken {
                capturedImage = cameraModel.capturedImage
                dismiss()
            }
        }
    }
}
