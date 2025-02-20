//
//  EditorView.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 18.02.2025.
//

import SwiftUI
import PDFKit
import PhotosUI

struct EditorView: View {
    @State private var text: String = ""
    @State private var images: [UIImage] = []
    @State private var isPickerPresented = false
    @State private var showDeleteSheet: Bool = false
    @State private var showSheet: Bool = false
    
    @StateObject var viewModel: EditorViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            PDFKitView(document: viewModel.document)
            //.edgesIgnoringSafeArea(.all)
                .overlay(alignment: .topTrailing) {
                    VStack {
                        Button("Save") {
                            saveInputAlert { name in
                                viewModel.savePDF(filename: name)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(width: 60)
                        
                        Button("Share") {
                            viewModel.sharePDF()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(width: 60)
                    }
                    .padding()                    
                }
            
            
            HStack {
                TextEditor(text: $text)
                    .frame(height: 40)
                    .border(Color.cyan)
                
                Button("Add Text") {
                    viewModel.addText(text: text)
                    text = ""
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 100)
            }
            .padding(.horizontal)
            
            
            HStack {
                Button("Delete Page") {
                    showPageInputAlert { pageToDelete in
                        viewModel.deletePage(pageNumber: pageToDelete - 1)
                    }
                }
                .buttonStyle(AlertButtonStyle())
                
                Button("Add Page") {
                    viewModel.addNewPage()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Add Image") {
                    isPickerPresented = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showSheet) {
            if viewModel.share {
                if let url = viewModel.lastURLSaved {
                    ActivityView(activityItems: [url])
                }
            }
            else if isPickerPresented {
                ImagePicker { image in
                    viewModel.addImage(image: image)
                }
            }
        }
        .alert("", isPresented: $viewModel.showMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.message)
        }
        .onChange(of: showSheet) { val in
            if !val {
                viewModel.share = false
                isPickerPresented = false
            }
        }
        .onChange(of: viewModel.share) { val in
            if val {
                showSheet = true
            }
        }
        .onChange(of: isPickerPresented) { val in
            if val {
                showSheet = true
            }
        }
        .navigationTitle("PDF Editor")
    }
}

extension EditorView {
    func showPageInputAlert(onDelete: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: "Delete Page", message: "Enter the page number:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Page number"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            if let text = alert.textFields?.first?.text, let page = Int(text) {
                onDelete(page)
            }
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(alert, animated: true)
        }
    }
    
    func saveInputAlert(onSave: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Save PDF", message: "Enter the file name:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .destructive) { _ in
            if let text = alert.textFields?.first?.text {
                onSave(text)
            }
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(alert, animated: true)
        }
    }
}

#Preview {
    EditorView(viewModel: .init())
}
