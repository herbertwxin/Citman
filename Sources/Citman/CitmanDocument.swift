import SwiftUI
import UniformTypeIdentifiers

struct CitmanDocument: FileDocument {
    var entries: [BibTeXEntry]

    init() {
        self.entries = []
    }

    static var readableContentTypes: [UTType] { [UTType.plainText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.entries = BibTeXParser.parse(content: string)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let content = BibTeXParser.serialize(entries: entries)
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}
