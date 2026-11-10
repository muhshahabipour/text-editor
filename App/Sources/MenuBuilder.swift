import AppKit

enum MenuBuilder {
    static func build() -> NSMenu {
        let main = NSMenu()
        func add(_ title: String, _ items: [NSMenuItem]) {
            let item = NSMenuItem(); main.addItem(item)
            let m = NSMenu(title: title); item.submenu = m
            items.forEach { m.addItem($0) }
        }
        func mi(_ t: String, _ a: Selector?, _ k: String = "", _ mods: NSEvent.ModifierFlags = .command) -> NSMenuItem {
            let i = NSMenuItem(title: t, action: a, keyEquivalent: k)
            i.keyEquivalentModifierMask = mods
            return i
        }
        let find = mi("Find…", #selector(NSResponder.performTextFinderAction(_:)), "f")
        find.tag = NSTextFinder.Action.showFindInterface.rawValue
        add("App", [
            mi("About Text Editor", #selector(NSApplication.orderFrontStandardAboutPanel(_:))),
            .separator(),
            mi("Hide Text Editor", #selector(NSApplication.hide(_:)), "h"),
            mi("Quit Text Editor", #selector(NSApplication.terminate(_:)), "q"),
        ])
        add("File", [
            mi("New", #selector(NSDocumentController.newDocument(_:)), "n"),
            mi("New Tab", #selector(NSWindow.newWindowForTab(_:)), "t"),
            mi("Open…", #selector(NSDocumentController.openDocument(_:)), "o"),
            .separator(),
            mi("Close", #selector(NSWindow.performClose(_:)), "w"),
            mi("Save…", #selector(NSDocument.save(_:)), "s"),
            mi("Save As…", #selector(NSDocument.saveAs(_:)), "S", [.command, .shift]),
            mi("Revert to Saved", #selector(NSDocument.revertToSaved(_:))),
        ])
        add("Edit", [
            mi("Undo", Selector(("undo:")), "z"),
            mi("Redo", Selector(("redo:")), "Z", [.command, .shift]),
            .separator(),
            mi("Cut", #selector(NSText.cut(_:)), "x"),
            mi("Copy", #selector(NSText.copy(_:)), "c"),
            mi("Paste", #selector(NSText.paste(_:)), "v"),
            mi("Select All", #selector(NSText.selectAll(_:)), "a"),
            .separator(),
            find,
            mi("Find (Persian-aware)…", Selector(("showPersianFind:")), "f", [.command, .option]),
            .separator(),
            mi("Show Spelling and Grammar", #selector(NSText.showGuessPanel(_:)), ":"),
            mi("Check Spelling While Typing", #selector(NSTextView.toggleContinuousSpellChecking(_:))),
        ])
        add("Format", [
            mi("Paragraph Left to Right", #selector(NSResponder.makeBaseWritingDirectionLeftToRight(_:)), String(UnicodeScalar(NSRightArrowFunctionKey)!), [.command, .shift]),
            mi("Paragraph Right to Left", #selector(NSResponder.makeBaseWritingDirectionRightToLeft(_:)), String(UnicodeScalar(NSLeftArrowFunctionKey)!), [.command, .shift]),
        ])
        add("View", [mi("Toggle Line Numbers", Selector(("toggleLineNumbers:")), "l", [.command, .option])])
        add("Window", [
            mi("Minimize", #selector(NSWindow.performMiniaturize(_:)), "m"),
            mi("Show Next Tab", #selector(NSWindow.selectNextTab(_:)), "}", [.command]),
            mi("Show Previous Tab", #selector(NSWindow.selectPreviousTab(_:)), "{", [.command]),
        ])
        return main
    }
}
