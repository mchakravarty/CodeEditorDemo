//
//  CodeEditorDemoApp.swift
//  Shared
//
//  Created by Manuel M T Chakravarty on 21/05/2021.
//

import SwiftUI

@main
struct CodeEditorDemoApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: CodeEditorDemoDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
