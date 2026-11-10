import AppKit
import EditorCore

final class PersianFindController: NSWindowController {
    private let findField = NSTextField()
    private let replaceField = NSTextField()
    private let ignoreCheck = NSButton(checkboxWithTitle: "Ignore ي/ی and ك/ک differences", target: nil, action: nil)
    private let status = NSTextField(labelWithString: "")
    weak var textView: NSTextView?

    convenience init() {
        let w = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 420, height: 170),
                        styleMask: [.titled, .closable, .utilityWindow], backing: .buffered, defer: false)
        w.title = "Find (Persian-aware)"
        w.isFloatingPanel = true
        self.init(window: w)
        build()
    }

    private func build() {
        let content = window!.contentView!
        findField.placeholderString = "Find"; replaceField.placeholderString = "Replace with"
        ignoreCheck.state = Preferences.ignoreVariants ? .on : .off
        ignoreCheck.target = self; ignoreCheck.action = #selector(optionChanged)
        func btn(_ t: String, _ a: Selector) -> NSButton { NSButton(title: t, target: self, action: a) }
        let row = NSStackView(views: [btn("Previous", #selector(prev)), btn("Next", #selector(next)),
                                      btn("Replace", #selector(replaceOne)), btn("Replace All", #selector(replaceAll))])
        let stack = NSStackView(views: [findField, replaceField, ignoreCheck, row, status])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
            findField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            replaceField.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ])
    }

    @objc private func optionChanged() { Preferences.ignoreVariants = ignoreCheck.state == .on }

    private func matches() -> [NSRange] {
        guard let tv = textView else { return [] }
        return PersianText.findRanges(of: findField.stringValue, in: tv.string, ignoreVariants: Preferences.ignoreVariants)
    }

    private func select(_ r: NSRange) {
        guard let tv = textView else { return }
        tv.setSelectedRange(r); tv.scrollRangeToVisible(r); tv.showFindIndicator(for: r)
    }

    @objc private func next() { step(forward: true) }
    @objc private func prev() { step(forward: false) }

    private func step(forward: Bool) {
        let all = matches()
        status.stringValue = "\(all.count) matches"
        guard let tv = textView, !all.isEmpty else { NSSound.beep(); return }
        let cur = tv.selectedRange()
        let target: NSRange
        if forward {
            target = all.first { $0.location >= cur.location + (cur.length > 0 ? 1 : 0) } ?? all[0]
        } else {
            target = all.last { $0.location < cur.location } ?? all[all.count - 1]
        }
        select(target)
    }

    @objc private func replaceOne() {
        guard let tv = textView else { return }
        let sel = tv.selectedRange()
        if matches().contains(sel), tv.shouldChangeText(in: sel, replacementString: replaceField.stringValue) {
            tv.replaceCharacters(in: sel, with: replaceField.stringValue)
            tv.didChangeText()
        }
        next()
    }

    @objc private func replaceAll() {
        guard let tv = textView else { return }
        let all = matches()
        guard !all.isEmpty else { NSSound.beep(); return }
        let rep = replaceField.stringValue
        tv.undoManager?.beginUndoGrouping()
        for r in all.reversed() where tv.shouldChangeText(in: r, replacementString: rep) {
            tv.replaceCharacters(in: r, with: rep)
        }
        tv.didChangeText()
        tv.undoManager?.endUndoGrouping()
        status.stringValue = "Replaced \(all.count)"
    }

    func show(for textView: NSTextView) {
        self.textView = textView
        showWindow(nil)
        window?.makeFirstResponder(findField)
    }
}
