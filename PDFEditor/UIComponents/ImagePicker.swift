//
//  ImagePicker.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 19.02.2025.
//
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {    
    let action: (UIImage) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            Task { //@MainActor in
                await withTaskGroup(of: UIImage?.self) { group in
                    for result in results {
                        group.addTask {
                            await self.loadAndCompressImage(from: result)
                        }
                    }
                    
                    for await image in group {
                        if let image = image {
                            self.parent.action(image)
                        }
                    }
                }
            }
        }
        
        func loadAndCompressImage(from result: PHPickerResult) async -> UIImage? {
            await withCheckedContinuation { continuation in
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let uiImage = image as? UIImage {
                        Task {
                            let compressedImage = await self.compressImageIfNeeded(uiImage, maxSizeInMB: 0.1)
                            continuation.resume(returning: compressedImage)
                        }
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
        
        func compressImageIfNeeded(_ image: UIImage, maxSizeInMB: Double) async -> UIImage {
            let maxSizeInBytes = maxSizeInMB * 1024 * 1024
            
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                return image
            }
            
            let imageSize = Double(imageData.count)
            
            guard imageSize > maxSizeInBytes else {
                return image
            }
            
            let compressionRatio = max(min(maxSizeInBytes / imageSize, 1.0), 0.05)
            
            if let compressedData = image.jpegData(compressionQuality: compressionRatio),
               let compressedImage = UIImage(data: compressedData) {
                return compressedImage
            }
            
            return image
        }
    }
}


