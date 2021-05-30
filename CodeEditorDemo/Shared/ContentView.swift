//
//  ContentView.swift
//  Shared
//
//  Created by Manuel M T Chakravarty on 21/05/2021.
//

import SwiftUI
import CodeEditorView


struct MessageEntry: View {
  @Binding var messages: Set<Located<Message>>

  @Environment(\.presentationMode) var presentationMode

  @State private var category:  Message.Category = .error
  @State private var summary:   String           = ""
  @State private var lineStr:   String           = ""
  @State private var columnStr: String           = ""
  @State private var message:   String           = ""

  var body: some View {
    VStack(spacing: 16) {

      Text("Enter a message to display in the code view")

      Form {

        Section(header: Text("Brief")){
          Picker("Catgeory", selection: $category) {
            Text("Live").tag(Message.Category.live)
            Text("error").tag(Message.Category.error)
            Text("warning").tag(Message.Category.warning)
            Text("informational").tag(Message.Category.informational)
          }

          TextField("Summary", text: $summary)

          HStack {
            Text("Line:")
            TextField("1", text: $lineStr)
            Text("Column:")
            TextField("0", text: $columnStr)
          }

        }
        Section(header: Text("Detailed message")){
          TextEditor(text: $message)
            .frame(height: 100)
        }

      }
      HStack {

        Button("Cancel"){ presentationMode.wrappedValue.dismiss() }
          .keyboardShortcut(.cancelAction)

        Spacer()

        Button("Submit message"){

          let finalSummary = summary.count == 0 ? "Summary" : summary,
              line         = Int(lineStr) ?? 1,
              column       = Int(columnStr) ?? 0
          messages.insert(Located(location: Location(file: "main.swift", line: line, column: column),
                                  entity: Message(category: category,
                                                  length: 1,
                                                  summary: finalSummary,
                                                  description: NSAttributedString(string: message))))
          presentationMode.wrappedValue.dismiss()

        }
        .keyboardShortcut(.defaultAction)

      }
    }
    .padding(10)
  }
}

struct ContentView: View {
  @Binding var document: CodeEditorDemoDocument

  @Environment(\.colorScheme) private var colorScheme: ColorScheme

  @State private var messages:         Set<Located<Message>> = Set ()
  @State private var showMessageEntry: Bool                  = false

  var body: some View {
    VStack {

      CodeEditor(text: $document.text, messages: $messages, language: .swift)
        .environment(\.codeEditorTheme,
                     colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)

      Button("Add Message") { showMessageEntry = true }
        .sheet(isPresented: $showMessageEntry){ MessageEntry(messages: $messages) }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
    }

  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(CodeEditorDemoDocument(text: "var x = 5")))
      .preferredColorScheme(.dark)
  }
}
