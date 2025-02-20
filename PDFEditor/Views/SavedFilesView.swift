//
//  SavedFilesView.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 19.02.2025.
//
import SwiftUI

struct SavedFilesView: View {
    @StateObject var viewModel = SavedFilesViewModel()
        
    @State var selectedItemUrl : URL? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if viewModel.pdfFiles.isEmpty {
                    Text("You do not have any saved file yet.")
                }
                ForEach(viewModel.pdfFiles, id: \.self) { file in
                    Button {
                        if viewModel.urlToJoin == nil {
                            selectedItemUrl = file.url
                        }
                        else {
                            viewModel.merge(url: file.url)
                        }
                    } label: {
                        HStack {
                            if let thumbnail = file.thumbnail {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .frame(width: 50, height: 70)
                                    .cornerRadius(4)
                                    .shadow(radius: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 50, height: 70)
                                    .cornerRadius(4)
                            }
                            
                            VStack {
                                Text(file.name)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(file.fileExtension)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let date = file.creationDate {
                                    Text(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 0.5)
                                .stroke(.teal)
                        )
                    }
                    .disabled(viewModel.urlToJoin == file.url)
                    .contextMenu {
                        Button {
                            viewModel.share(url: file.url)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            viewModel.delete(url: file.url)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        if viewModel.urlToJoin == file.url {
                            Button {
                                viewModel.merge(url: file.url)
                            } label: {
                                Label("Cancel merge", systemImage: "doc.text")
                            }
                        }
                        else if viewModel.urlToJoin == nil {
                            Button {
                                viewModel.merge(url: file.url)
                            } label: {
                                Label("Merge with another file", systemImage: "doc.text")
                            }
                        }
                        else {
                            Button {
                                viewModel.merge(url: file.url)
                            } label: {
                                Label("Merge with this file", systemImage: "doc.text")
                            }
                        }
                    }
                    
                    if let url = file.url {
                        NavigationLink(
                            destination: EditorView(viewModel: .init(url: url)),
                            tag: url,
                            selection: $selectedItemUrl) {
                                EmptyView()
                            }
                            .hidden()
                    }
                }
            }
            .padding()

        }
        .navigationTitle("Files list")
        .sheet(isPresented: $viewModel.shareFile) {
            if let url = viewModel.urlToShare {
                ActivityView(activityItems: [url])
            }
        }
        .onAppear {
            viewModel.loadFiles()
        }
    }
}

#Preview {
    SavedFilesView()
}
