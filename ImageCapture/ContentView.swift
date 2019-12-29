//
//  ContentView.swift
//  ImageCapture
//
//  Created by Bandu Wewalaarachchi on 29/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

class MyImage: ObservableObject {
    @Published var image: Image? = nil
}

struct ContentView: View {
    @ObservedObject var myImage: MyImage
    @State var showPicker: Bool = false
    @State var pickPhoto: Bool = false
    @State var newImage: UIImage? = nil
    
    var body: some View {
        VStack {
            (myImage.image ?? Image(systemName: "pin.slash"))
                .resizable().scaledToFit()
        }
        .gesture(TapGesture().onEnded {_ in
            print("tapped")
            self.showPicker = true
            self.pickPhoto = true
        })
        .sheet(isPresented: $showPicker){
            ImageScalling(image: self.$myImage.image, capturedImage: self.$newImage)
                .sheet(isPresented: self.$pickPhoto){
                    ImagePickingView(image: self.$newImage, isAbort: self.$showPicker)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(myImage: MyImage())
    }
}
