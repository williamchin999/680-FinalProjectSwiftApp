//
//  DrawingScreen.swift
//  ImageMapApp
//
//  Created by William Chin on 12/4/22.
//

import Foundation
import SwiftUI
import PencilKit

struct DrawingScreen: View {
    @EnvironmentObject var model: DrawingViewModel
    
    var body: some View{
        ZStack {
            GeometryReader{ proxy -> AnyView in
                let size = proxy.frame(in: .global)
                
                DispatchQueue.main.async {
                    if model.rect == .zero{
                        model.rect = size
                    }
                }
                
                return AnyView(
                    ZStack {
                        //Pencil Kit Drawing View
                        CanvasView(canvas:$model.canvas, imageData: $model.imageData, toolPicker: $model.toolPicker, rect:size.size)
                        
                        //Custom Text
                        
                        //Display text Box
                        ForEach(model.textBoxes){ box in
                            Text(model.textBoxes[model.currentIndex].id == box.id && model.addNewBox ? "" : box.text)
                                .font(.system(size: 30))
                                .fontWeight(box.isBold ? .bold: .none)
                                .foregroundColor(box.textColor)
                                .offset(box.offset)
                                .gesture(DragGesture().onChanged({ (value) in
                                    let current = value.translation
                                    //adding with last offset
                                    let lastOffset =  box.lastOffset
                                    let newTranslation = CGSize(width: lastOffset.width + current.width, height:  lastOffset.height + current.height)
                                    model.textBoxes[getIndex(textBox: box)].offset = newTranslation
                                }).onEnded({ (value) in
                                    //save last offset of each box
                                    model.textBoxes[getIndex(textBox: box)].lastOffset = value.translation
                                }))
                            
                            //edit typed box
                                .onLongPressGesture{
                                    //close toolbar
                                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                                    model.canvas.resignFirstResponder()
                                    
                                    model.currentIndex = getIndex(textBox: box)
                                    withAnimation{
                                        model.addNewBox = true
                                    }
                                }
                        }
                    }
                )
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Button(action: model.saveImage, label: {
                    Text("Save")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                    //creating 1 box
                    model.textBoxes.append(TextBox())
                    
                    //update index
                    model.currentIndex = model.textBoxes.count - 1
                    
                    withAnimation{
                        model.addNewBox.toggle()
                    }
                    //close toolbar
                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                    model.canvas.resignFirstResponder()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        })
    }
    
    func getIndex(textBox: TextBox)-> Int {
        let index = model.textBoxes.firstIndex{ (box) -> Bool in
            return textBox.id == box.id
            
        } ?? 0
        return index
    }
}

struct DrawingScreen_Previews: PreviewProvider {
    static var previews: some View {
        editView()
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var imageData: Data
    @Binding var toolPicker: PKToolPicker
    
    //view size
    var rect: CGSize
    
    func makeUIView(context: Context) -> PKCanvasView{
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
         
        //appending image in canvas subview
        if let image = UIImage(data: imageData){
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            //set image to back of canvas
            let subView = canvas.subviews[0]
            subView.addSubview(imageView)
            subView.sendSubviewToBack(imageView)
            
            //show picker tool
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        //Update UI for every action
        
    }
}
                
                               
