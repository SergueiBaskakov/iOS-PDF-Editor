//
//  PDFEditorApp.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 17.02.2025.
//

import SwiftUI

@main
struct PDFEditorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
