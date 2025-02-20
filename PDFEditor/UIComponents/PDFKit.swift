//
//  PDFKit.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 18.02.2025.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    var document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document !== document {
            uiView.document = document
        }

    }
    
}
