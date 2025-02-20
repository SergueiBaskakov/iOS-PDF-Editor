//
//  SavedFilesViewModel.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 19.02.2025.
//
import Combine
import PDFKit

class SavedFilesViewModel: ObservableObject {
    @Published var pdfFiles: [FileModel] = []
    
    @Published var shareFile: Bool = false
    
    @Published var urlToShare: URL? = nil
    
    @Published var urlToJoin: URL? = nil
    
    private let folderName: String = GlobalVariables.mainFolder
    
    private let acceptedExtensions: Set<String> = ["pdf"]
    
    private let fileManager = FileManager.default
    
    func loadFiles() {
        Task {
            let files = try await getFiles()
            Task { @MainActor in
                pdfFiles = files
            }
        }
    }
    
    private func getFiles() async throws -> [FileModel] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        let filesFolderURL = documentsURL.appendingPathComponent(folderName)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: filesFolderURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            return fileURLs
                .filter { acceptedExtensions.contains($0.pathExtension.lowercased()) }
                .compactMap { url in
                    let name = String(url.deletingPathExtension().lastPathComponent.split(separator: ".").first ?? "")
                    let fileExtension = url.pathExtension
                    let creationDate = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate)
                    let thumbnail = generateThumbnail(for: url)
                    
                    return .init(name: name, fileExtension: fileExtension, creationDate: creationDate, thumbnail: thumbnail, url: url)
                }
        } catch {
            print("Error fetching PDF files: \(error.localizedDescription)")
            return []
        }
    }
    
    private func generateThumbnail(for url: URL) -> UIImage? {
        guard let document = PDFDocument(url: url), let page = document.page(at: 0) else { return nil }
        let pageRect = page.bounds(for: .mediaBox)
        let scale: CGFloat = 0.2
        let thumbnailSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)
        return page.thumbnail(of: thumbnailSize, for: .mediaBox)
    }
    
    private func mergeTwoPDFs(url1: URL, url2: URL) async throws -> PDFDocument? {
        guard let pdf1 = PDFDocument(url: url1),
              let pdf2 = PDFDocument(url: url2) else {
            return nil
        }

        for pageIndex in 0..<pdf2.pageCount {
            if let page = pdf2.page(at: pageIndex) {
                pdf1.insert(page, at: pdf1.pageCount)
            }
        }

        return pdf1
    }
    
    private func save(document: PDFDocument, url1: URL, url2: URL) {
        let directory = url1.deletingLastPathComponent()
        let name1 = url1.deletingPathExtension().lastPathComponent
        let name2 = url2.deletingPathExtension().lastPathComponent
        
        let mergedFileName = "\(name1)_\(name2)_merged.pdf"
        let outputURL = directory.appendingPathComponent(mergedFileName)
        
        document.write(to: outputURL)
    }
    
    func share(url: URL?) {
        guard let url = url else { return }
        urlToShare = url
        shareFile = true
    }
    
    func delete(url: URL?) {
        guard let url = url else { return }
        do {
            try fileManager.removeItem(at: url)
            loadFiles()
        } catch {
            print("Error deleting PDF: \(error.localizedDescription)")
        }
    }
    
    func merge(url: URL?) {
        guard let url = url else { return }
        if let firstURL = urlToJoin {
            if firstURL == url {
                urlToJoin = nil
            }
            else {
                Task {
                    if let pdf = try await mergeTwoPDFs(url1: firstURL, url2: url) {
                        Task { @MainActor in
                            save(document: pdf, url1: firstURL, url2: url)
                            urlToJoin = nil
                            loadFiles()
                        }
                    }
                }
            }
        }
        else {
            urlToJoin = url
        }
    }
}
