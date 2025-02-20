//
//  EditorViewModel.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 18.02.2025.
//

import Combine
import PDFKit

class EditorViewModel: ObservableObject {
    @Published var document: PDFDocument
    
    @Published var message: String = ""
    
    @Published var showMessage: Bool = false
    
    @Published var share: Bool = false
    
    private var pdfElements: [PageElementModel] = []
    private let width: CGFloat = 612
    private let height: CGFloat = 792
    private let margin: CGFloat = 20
    private let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 16)
    ]
    
    private var replace = false
    private let folderName: String = GlobalVariables.mainFolder
    var lastURLSaved: URL?
    
    init(url: URL? = nil) {
        if let pdfURL = url,
           let doc = PDFDocument(url: pdfURL) {
            document = doc
        }
        else {
            let pageRect = CGRect(x: 0, y: 0, width: width, height: height)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            let blankPageData = renderer.pdfData { context in
                context.beginPage()
            }
            document = PDFDocument(data: blankPageData) ?? PDFDocument()
            replace = true
        }
    }
    
    private func updateTempDocument() {
        var i = 0
        var pdfElementsCount: Int = 0
        pdfElementsCount = pdfElements.count
        var pageToRemove: Int?
        if replace {
            pageToRemove = document.pageCount - 1
        }
        else {
            pageToRemove = nil
        }
        while i < pdfElementsCount {
            let pageRect = CGRect(x: 0, y: 0, width: width, height: height)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            var elementsInPage = 0
            let blankPageData = renderer.pdfData { context in
                context.beginPage()
                
                var stop: Bool = false
                var avaibleHeight: CGFloat = height - margin * 2
                
                while i < pdfElementsCount {
                    let element = pdfElements[i]
                    switch element.type {
                    case .newPage:
                        stop = true
                        i += 1
                        elementsInPage += 1
                    case .image(let image):
                        let imageSize = image.size
                        let scaleFactor = min(min((width - margin * 2) / imageSize.width, 1.0), min((height - margin * 2) / imageSize.height, 1.0))
                        let scaledSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
                        
                        if avaibleHeight < scaledSize.height {
                            stop = true
                        }
                        else {
                            let y = height - avaibleHeight - margin
                            let imageRect = CGRect(x: margin, y: y, width: scaledSize.width, height: scaledSize.height)
                            image.draw(in: imageRect)
                            
                            avaibleHeight -= scaledSize.height
                            i += 1
                            elementsInPage += 1
                        }
                    case .text(let value):
                        if avaibleHeight >= element.height ||
                            element.height > (height - margin * 2) {
                            
                            let y = height - avaibleHeight - margin
                            let constraintWidth = width - margin * 2
                            let textRect = CGRect(x: margin, y: y, width: constraintWidth, height: element.height)
                            (value as NSString).draw(in: textRect, withAttributes: attributes)
                            
                            avaibleHeight -= element.height
                            i += 1
                            elementsInPage += 1
                        }
                        else {
                            stop = true
                        }
                    }
                    if stop {
                        break
                    }
                }
                
            }
            
            if !(i < pdfElementsCount) {
                replace = true
                pdfElements.removeFirst(i - elementsInPage)
            }
            
            if let tempDoc = PDFDocument(data: blankPageData),
               let newPage = tempDoc.page(at: 0) {
                document.insert(newPage, at: document.pageCount)
            }
        }
        
        if let page = pageToRemove {
            document.removePage(at: page)
        }
    }
    
    func addNewPage() {
        
        if !pdfElements.isEmpty &&
            pdfElements.last?.type != .newPage
        {
            pdfElements.append(.init(type: .newPage))
        }
        pdfElements.append(.init(type: .newPage))
        
        updateTempDocument()
    }
    
    func addText(text: String) {
        let constrainedSize = CGSize(width: width - margin * 2, height: .greatestFiniteMagnitude)
        let boundingBox = (text as NSString).boundingRect(with: constrainedSize,
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: attributes,
                                                          context: nil)
        let textHeight = ceil(boundingBox.height)
        
        if pdfElements.last?.type == .newPage {
            pdfElements.removeLast()
        }
        pdfElements.append(.init(type: .text(text), height: textHeight))
        
        updateTempDocument()
        
    }
    
    func addImages(images: [UIImage]) {
        if pdfElements.last?.type == .newPage {
            pdfElements.removeLast()
        }
        
        for image in images {
            pdfElements.append(.init(type: .image(image)))
        }
        
        updateTempDocument()
    }
    
    func addImage(image: UIImage) {
        if pdfElements.last?.type == .newPage {
            pdfElements.removeLast()
        }
        
        pdfElements.append(.init(type: .image(image)))
        
        updateTempDocument()
    }
    
    func deletePage(pageNumber: Int) {
        if pageNumber >= 0 && pageNumber < document.pageCount {
            if pageNumber == document.pageCount - 1 {
                pdfElements = []
                replace = false
                updateTempDocument()
            }
                document.removePage(at: pageNumber)
        }
    }
    
    func savePDF(filename: String, showConfirmation: Bool = true) {
        guard let data = document.dataRepresentation() else { return }
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let pdfsFolderURL = documentsURL.appendingPathComponent(folderName)
        
        if !FileManager.default.fileExists(atPath: pdfsFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: pdfsFolderURL, withIntermediateDirectories: true, attributes: nil)
                print("Created 'PDFEditor' folder.")
            } catch {
                print("Error creating 'PDFEditor' folder: \(error.localizedDescription)")
                self.message = "Error saving PDF!"
                return
            }
        }
        
        let fileURL = pdfsFolderURL.appendingPathComponent("\(filename).pdf")
        
        do {
            try data.write(to: fileURL)
            self.message = "PDF saved successfully!"
            lastURLSaved = fileURL
            print("PDF saved to: \(fileURL)")
        } catch {
            self.message = "Error saving PDF!"
            print("Error saving PDF: \(error.localizedDescription)")
        }
        
        if showConfirmation {
            showMessage = true
        }
    }
    
    func sharePDF() {
        savePDF(filename: "shared_\(String(UUID().uuidString.prefix(6)))", showConfirmation: false)
        share = true
    }
}
