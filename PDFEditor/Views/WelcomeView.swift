//
//  WelcomeView.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 17.02.2025.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var navigateToEditor: Bool = false
    
    @State var navigateToSavedFiles: Bool = false
    
    @State private var selectedPDFURL: URL?
    
    @State private var showDocumentPicker = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Welcome to PDF Editor")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.teal)
            
            Spacer()
            
            Text("PDF Editor is a simple tool to work with PDF documents and edit their content.")
            
            Spacer()
            
            Button {
                navigateToEditor = true
            } label: {
                Text("Create new PDF")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button {
                showDocumentPicker = true
            } label: {
                Text("Open PDF from files")
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.top, 8)
            
            Button {
                navigateToSavedFiles = true
            } label: {
                Text("Go to saved PDFs")
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.top, 8)
            .padding(.bottom)
            
            NavigationLink(destination: EditorView(viewModel: .init(url: selectedPDFURL)), isActive: $navigateToEditor) {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(destination: SavedFilesView(), isActive: $navigateToSavedFiles) {
                EmptyView()
            }
            .hidden()
            
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedURL: $selectedPDFURL, types: [.pdf])
        }
        .onChange(of: selectedPDFURL) { url in
            if url != nil {
                navigateToEditor = true
            }
        }
    }
}

#Preview {
    WelcomeView()
}
