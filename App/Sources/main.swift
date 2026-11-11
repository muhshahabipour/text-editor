import AppKit

// No nib/storyboard, so the delegate must be set explicitly (@main would not attach it).
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
