//
//  ImagePicker.swift
//  ImageCapture
//
//  Created by Bandu Wewalaarachchi on 29/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI
import UIKit

struct ImagePickingView {
    @Binding var image: UIImage?
    @Binding var isAbort: Bool
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image, showMode: presentationMode, isAbort: $isAbort)
    }
}

extension ImagePickingView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickingView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickingView>) {
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @Binding var image: UIImage?
    @Binding var isAbort: Bool
    @Binding var presentationMode: PresentationMode

    init(image: Binding<UIImage?>, showMode: Binding<PresentationMode>, isAbort: Binding<Bool>) {
        self._image = image
        self._presentationMode = showMode
        self._isAbort = isAbort
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            self.isAbort = false
        }
        $presentationMode.wrappedValue.dismiss()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.image = image
            $presentationMode.wrappedValue.dismiss()
        }
    }
}
