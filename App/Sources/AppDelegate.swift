import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    func applicationWillFinishLaunching(_ n: Notification) {
        applyTheme()
        NSApp.mainMenu = MenuBuilder.build(target: self)
    }
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool { true }
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }

    func applyTheme() {
        switch Preferences.theme {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark": NSApp.appearance = NSAppearance(named: .darkAqua)
        default: NSApp.appearance = nil
        }
    }

    @objc func setTheme(_ sender: NSMenuItem) {
        Preferences.theme = sender.representedObject as? String ?? "system"
        applyTheme()
    }

    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        if item.action == #selector(setTheme(_:)) {
            item.state = (item.representedObject as? String) == Preferences.theme ? .on : .off
        }
        return true
    }
}
