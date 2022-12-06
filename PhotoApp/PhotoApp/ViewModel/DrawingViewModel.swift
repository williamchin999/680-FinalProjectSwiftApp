//
//  DrawingViewModel.swift
//  ImageMapApp
//
//  Created by William Chin on 12/4/22.
//

import Foundation
import SwiftUI
import PencilKit
//Holds all drawing data

class DrawingViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var imageData: Data = Data(count:0)
    
    //Canvas to draw
    @Published var canvas = PKCanvasView()
    //Tool Picker
    @Published var toolPicker = PKToolPicker()
    // List of Text Boxes
    @Published var textBoxes: [TextBox] = []
    @Published var addNewBox = false
    
    @Published var currentIndex: Int = 0
    
    @Published var rect: CGRect = .zero

    @Published var showAlert = false
    @Published var message = ""
    func cancelImageEditing() {
        imageData = Data(count: 0)
        canvas = PKCanvasView()
        textBoxes.removeAll()
    }
    
    func cancelTextView(){
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        withAnimation{
            addNewBox = false
        }
        
        if !textBoxes[currentIndex].isAdded{
            textBoxes.removeLast()
        }
    }
    
    func saveImage(){
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let SwiftUIView = ZStack {
            ForEach(textBoxes){ [self] box in
                Text(textBoxes[currentIndex].id == box.id && addNewBox ? "" : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold: .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
            }
        }
        
        let controller = UIHostingController(rootView: SwiftUIView).view!
        controller.frame = rect
        
        //Clear background
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = generatedImage?.pngData(){
            
            //save image
            UIImageWriteToSavedPhotosAlbum(UIImage(data: image)!, nil, nil, nil)
            print("Success")
            self.message = "Saved Successfully"
            self.showAlert.toggle()
        }
    }
}
