//
//  ContentView.swift
//  Shared
//
//  Created by Manuel M T Chakravarty on 21/05/2021.
//

import SwiftUI

import LanguageSupport
import CodeEditorView


struct MessageEntry: View {
  @Binding var messages: Set<TextLocated<Message>>

  @Environment(\.presentationMode) private var presentationMode

  @State private var category:  Message.Category = .error
  @State private var summary:   String           = ""
  @State private var lineStr:   String           = ""
  @State private var columnStr: String           = ""
  @State private var message:   String           = ""

  var body: some View {
    VStack(spacing: 16) {

      Text("Enter a message to display in the code view")

      Form {

        Section(header: Text("Essentials")) {

          Picker("", selection: $category) {
            Text("Live").tag(Message.Category.live)
            Text("Error").tag(Message.Category.error)
            Text("Warning").tag(Message.Category.warning)
            Text("Informational").tag(Message.Category.informational)
          }
          .padding([.top, .bottom], 4)

          TextField("Summary", text: $summary)

          #if os(iOS) || os(visionOS)
          HStack {
            TextField("Line", text: $lineStr)
            TextField("Column", text: $columnStr)
          }
          #elseif os(macOS)
          TextField("Line", text: $lineStr)
          TextField("Column", text: $columnStr)
          #endif
          Text("Line and column numbers start at 1.")
            .font(.system(.footnote))
          #if os(macOS)
            .padding([.bottom], 8)
          #endif

        }

        Section(header: Text("Detailed message")) {
          TextEditor(text: $message)
            .frame(height: 100)
        }

      }
      HStack {

        Button("Cancel"){ presentationMode.wrappedValue.dismiss() }
          .keyboardShortcut(.cancelAction)

        Spacer()

        Button("Submit message"){

          let finalSummary = summary.isEmpty ? "Summary" : summary,
              line         = Int(lineStr) ?? 1,
              column       = Int(columnStr) ?? 1
          messages.insert(TextLocated(location: TextLocation(oneBasedLine: line, column: column),
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

  // NB: In visionOS (v1), an update (set) to a a scene storage variable is (sometimes) not immeditely visible (to a
  //      get). This leads to flickering and similar issues.
#if os(visionOS)
  @State private var editPosition: CodeEditor.Position = CodeEditor.Position()
#else
  @SceneStorage("editPosition") private var editPosition: CodeEditor.Position = CodeEditor.Position()
#endif

  @State private var messages:         Set<TextLocated<Message>> = Set ()
  @State private var showMessageEntry: Bool                      = false
  @State private var showMinimap:      Bool                      = true
  @State private var wrapText:         Bool                      = true

  @FocusState private var editorIsFocused: Bool

  var body: some View {
    VStack {

      CodeEditor(text: $document.text,
                 position: $editPosition,
                 messages: $messages,
                 language: .swift(),
                 layout: CodeEditor.LayoutConfiguration(showMinimap: showMinimap, wrapText: wrapText))
        .environment(\.codeEditorTheme,
                     colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
        .focused($editorIsFocused)

      HStack {

        Button("Add Message") { showMessageEntry = true }
          .sheet(isPresented: $showMessageEntry){ MessageEntry(messages: $messages) }

        Spacer()

        Toggle("Show Minimap", isOn: $showMinimap)
#if os(macOS)
          .toggleStyle(.checkbox)
#else
          .toggleStyle(.button)
#endif
          .padding()

        Toggle("Wrap Text", isOn: $wrapText)
#if os(macOS)
          .toggleStyle(.checkbox)
#else
          .toggleStyle(.button)
#endif
          .padding()

      }
      .padding(EdgeInsets(top: 0, leading: 32, bottom: 8, trailing: 32))
      .onAppear{ editorIsFocused =  true }
    }

  }
}

// Mark: -
// Mark: Previews

struct MessageEntry_Previews: PreviewProvider {

  struct Container: View {
    @State var messages: Set<TextLocated<Message>> = Set()

    var body: some View {
      MessageEntry(messages: $messages)
        .preferredColorScheme(.dark)
    }
  }

  static var previews: some View { Container() }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(CodeEditorDemoDocument(text: "var x = 5")))
      .preferredColorScheme(.dark)
  }
}
