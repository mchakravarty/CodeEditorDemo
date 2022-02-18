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

      Form {

        Section(header: Text("Enter a message to display in the code view")){

          Picker("", selection: $category) {
            Text("Live").tag(Message.Category.live)
            Text("Error").tag(Message.Category.error)
            Text("Warning").tag(Message.Category.warning)
            Text("Informational").tag(Message.Category.informational)
          }
          .padding([.top, .bottom], 10)

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

  @SceneStorage("editPosition") private var editPosition: CodeEditor.Position = CodeEditor.Position()

  @State private var messages:         Set<Located<Message>> = Set ()
  @State private var showMessageEntry: Bool                  = false
  @State private var showMinimap:      Bool                  = true

  var body: some View {
    VStack {

      CodeEditor(text: $document.text,
                 position: $editPosition,
                 messages: $messages,
                 language: .swift,
                 layout: CodeEditor.LayoutConfiguration(showMinimap: showMinimap))
        .environment(\.codeEditorTheme,
                     colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)

      HStack {

        Button("Add Message") { showMessageEntry = true }
        .sheet(isPresented: $showMessageEntry){ MessageEntry(messages: $messages) }

        #if os(macOS)

        Spacer()

        Toggle("Show Minimap", isOn: $showMinimap)
          .toggleStyle(CheckboxToggleStyle())
          .padding([.top, .bottom])

        #endif

      }
      .padding(EdgeInsets(top: 0, leading: 32, bottom: 8, trailing: 32))
    }

  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(CodeEditorDemoDocument(text: "var x = 5")))
      .preferredColorScheme(.dark)
  }
}
