//
//  ImageScalling.swift
//  ImageCapture
//
//  Created by Bandu Wewalaarachchi on 29/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

struct ImageScalling: View {
    @Binding var image: Image?
    @Environment(\.presentationMode) var presentationMode
    @Binding var capturedImage: UIImage?
    @ObservedObject var container = Container()
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    (self.capturedImage != nil ? Image(uiImage: self.capturedImage!) : Image(systemName: "pin"))
                    .resizable()
                    .scaledToFit()
                        .scaleEffect(self.container.scale)
                        .offset(self.container.shift)
                    .gesture(DragGesture()
                        .onChanged { value in
                            self.container.onDrag(currentShift: value.translation)
                        }
                        .onEnded { value in
                            self.container.onDragEnd(currentShift: value.translation)
                        }
                    )
                    .simultaneousGesture(MagnificationGesture()
                        .onChanged { value in
                            self.container.onResize(currentScale: value)
                        }
                        .onEnded { value in
                            self.container.onResizeEnd(currentScale: value)
                        }
                    )
                    self.container.getMask(size: proxy.size)
                        .fill(Color.init(.sRGB, white: 1, opacity: 0.7), style: FillStyle(eoFill: true))
                }
                .clipped()
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Text("Cancel")
                },
                trailing: Button(action: {
                    if let image = self.capturedImage{
                        self.image = Image(uiImage: self.container.cropImage(viewSize: proxy.size, capturedImage: image))
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Text("Save")
                })
            }
        }
    }
        
    class Container: ObservableObject {
        @Published var scale: CGFloat = 1
        @Published var shift: CGSize = .zero
        var containerScale: CGFloat = 1
        var containerShift: CGSize = .zero
        
        func getMask(size: CGSize) -> Path {
            var path = Path()
            let rect = CGRect(origin: .zero, size: size)
            path.addRect(rect)
            let window = rect.insetBy(dx: 0, dy: (rect.height - rect.width * 0.75) / 2)
            path.addRect(window)
            return path
        }

        
        func onDrag (currentShift: CGSize){
            self.shift = CGSize(
                width: containerShift.width + currentShift.width,
                height: containerShift.height + currentShift.height
            )
        }
        
        func onDragEnd( currentShift: CGSize){
            containerShift.width += currentShift.width
            containerShift.height += currentShift.height
        }
        
        func onResize (currentScale: CGFloat){
            self.scale = containerScale * currentScale
        }
        
        func onResizeEnd (currentScale: CGFloat){
            containerScale *= currentScale
        }
        
        func cropImage(viewSize: CGSize, capturedImage: UIImage) -> UIImage {
            let outputSize = CGSize(width: 800, height: 600)
            let newSize = CGSize(width: outputSize.width * scale, height: outputSize.height * scale)
            let origin = CGPoint(
                x: ((newSize.width - outputSize.width) * -0.5) + (shift.width * outputSize.width / viewSize.width),
                y: ((newSize.height - outputSize.height) * -0.5) + (shift.height * newSize.height / viewSize.height))
            let renderer = UIGraphicsImageRenderer(size: outputSize)
            let newImage = renderer.image(actions: {
                context in
                capturedImage.draw(in: CGRect(origin: origin, size: newSize))
            })
            return newImage
        }
    }
}
