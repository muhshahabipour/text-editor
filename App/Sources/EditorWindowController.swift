import AppKit

final class EditorWindowController: NSWindowController {
    convenience init(document: TextDocument) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered, defer: false)
        window.tabbingMode = .preferred
        window.tabbingIdentifier = "TextEditorTab"
        self.init(window: window)
        let vc = EditorViewController(document: document)
        document.editor = vc
        window.contentViewController = vc
        // The view has no intrinsic size, so setting contentViewController collapses the window.
        window.setContentSize(NSSize(width: 760, height: 560))
        window.contentMinSize = NSSize(width: 360, height: 240)
        window.center()
    }
}
