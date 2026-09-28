//
//  ImagePicker.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI
import UIKit

/// 系统相册 / 相机图片选择器（兼容 iOS 15）。
struct ImagePicker: UIViewControllerRepresentable {
    /// 图片来源：相册或相机。
    let sourceType: UIImagePickerController.SourceType
    /// 选择完成回调，返回裁剪后的图片。
    let onPicked: (UIImage) -> Void

    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                parent.onPicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
