//
//  PageElementModel.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 18.02.2025.
//

import Foundation
import SwiftUI

struct PageElementModel: Hashable {
    let type: PDFElementType
    let height: CGFloat
    
    init(type: PDFElementType, height: CGFloat = 0) {
        self.type = type
        self.height = height
    }
}

enum PDFElementType: Hashable {
    case image(UIImage)
    case text(String)
    case newPage
}
