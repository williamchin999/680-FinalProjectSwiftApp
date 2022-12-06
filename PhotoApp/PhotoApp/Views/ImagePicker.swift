//
//  ImagePicker.swift
//  ImageMapApp
//
//  Created by William Chin on 12/4/22.
//

import Foundation
import SwiftUI

//Image Picker Using UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    @Binding var imageData: Data
    
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        //get parent view context to update image
        var parent : ImagePicker
        
        init (parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            //get image and closing
            if let imageData = (info[.originalImage]as? UIImage)?.pngData() {
                parent.imageData = imageData
                parent.showPicker.toggle()
            }
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            //closing view if canceled
            parent.showPicker.toggle()
        }
    }
}
