//
//  CodeEditorDemoDocument.swift
//  Shared
//
//  Created by Manuel M T Chakravarty on 21/05/2021.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static var swiftSource: UTType {
    UTType(importedAs: "public.swift-source")
  }
}

struct CodeEditorDemoDocument: FileDocument {
  var text: String

  init(text: String = "") {
    self.text = text
  }

  static var readableContentTypes: [UTType] { [.swiftSource] }

  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents,
          let string = String(data: data, encoding: .utf8)
    else {
      throw CocoaError(.fileReadCorruptFile)
    }
    text = string
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let data = text.data(using: .utf8)!
    return .init(regularFileWithContents: data)
  }
}
