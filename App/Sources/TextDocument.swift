import AppKit

final class TextDocument: NSDocument {
    override class var autosavesInPlace: Bool { true }
    override func data(ofType typeName: String) throws -> Data { Data() }
    override func read(from data: Data, ofType typeName: String) throws {}
}
