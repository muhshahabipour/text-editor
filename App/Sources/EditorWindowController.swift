import AppKit

final class EditorWindowController: NSWindowController {
    convenience init(document: TextDocument) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered, defer: false)
        window.tabbingMode = .preferred
        window.tabbingIdentifier = "PersianEditorTab"
        window.setFrameAutosaveName("EditorWindow")
        self.init(window: window)
        let vc = EditorViewController(document: document)
        document.editor = vc
        window.contentViewController = vc
    }
}
