import AppKit
import EditorCore

final class TextDocument: NSDocument {
    var text = ""
    private var encoding: String.Encoding = .utf8
    weak var editor: EditorViewController?

    override class var autosavesInPlace: Bool { true }

    override func makeWindowControllers() {
        addWindowController(EditorWindowController(document: self))
    }

    override func data(ofType typeName: String) throws -> Data {
        if let s = editor?.currentText { text = s }
        guard let d = text.data(using: encoding) else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileWriteInapplicableStringEncodingError)
        }
        return d
    }

    override func read(from data: Data, ofType typeName: String) throws {
        if let r = TextEncodingDetector.decode(data) {
            text = r.text; encoding = r.encoding
        } else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadInapplicableStringEncodingError,
                          userInfo: [NSLocalizedDescriptionKey:
                            "This file's text encoding could not be detected (tried UTF-8, UTF-16, Windows-1256)."])
        }
    }
}
