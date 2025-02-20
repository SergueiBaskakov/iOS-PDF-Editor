//
//  FileElement.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 19.02.2025.
//

import Foundation
import UIKit

struct FileModel: Hashable {
    let name: String
    let fileExtension: String
    let creationDate: Date?
    let thumbnail: UIImage?
    let url: URL?
}
