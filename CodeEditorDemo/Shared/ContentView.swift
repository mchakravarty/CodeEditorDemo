//
//  ContentView.swift
//  Shared
//
//  Created by Manuel M T Chakravarty on 21/05/2021.
//

import SwiftUI
import CodeEditorView

struct ContentView: View {
  @Binding var document: CodeEditorDemoDocument

  @Environment(\.colorScheme) var colorScheme: ColorScheme

  var body: some View {
    CodeEditor(text: $document.text, with: .swift)
      .environment(\.codeEditorTheme,
                   colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(CodeEditorDemoDocument(text: "var x = 5")))
  }
}
