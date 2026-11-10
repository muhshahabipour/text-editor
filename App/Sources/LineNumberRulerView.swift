import AppKit

final class LineNumberRulerView: NSRulerView {
    private var textView: NSTextView { clientView as! NSTextView }

    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)
        clientView = textView
        ruleThickness = 40
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsRedraw),
            name: NSText.didChangeNotification, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsRedraw),
            name: NSView.boundsDidChangeNotification, object: textView.enclosingScrollView!.contentView)
        textView.enclosingScrollView!.contentView.postsBoundsChangedNotifications = true
    }
    required init(coder: NSCoder) { fatalError() }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func setNeedsRedraw() { needsDisplay = true }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        NSColor.windowBackgroundColor.setFill(); bounds.fill()
        guard let tlm = textView.textLayoutManager,
              let tcm = tlm.textContentManager else { return }
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor,
        ]
        let visible = textView.visibleRect
        let inset = textView.textContainerOrigin
        var line = 1
        var lastMaxY: CGFloat = 0
        func draw(_ n: Int, at top: CGFloat) {
            let label = NSAttributedString(string: "\(n)", attributes: attrs)
            let size = label.size()
            label.draw(at: NSPoint(x: ruleThickness - size.width - 6, y: top + inset.y - visible.minY))
        }
        tlm.enumerateTextLayoutFragments(from: tcm.documentRange.location,
                                         options: [.ensuresLayout]) { fragment in
            let frame = fragment.layoutFragmentFrame
            if frame.maxY >= visible.minY - 1, frame.minY <= visible.maxY { draw(line, at: frame.minY) }
            lastMaxY = frame.maxY
            line += 1
            return frame.minY <= visible.maxY
        }
        // Layout fragments don't include the empty last line (empty document, or text ending in "\n").
        let text = textView.string
        if text.isEmpty || text.hasSuffix("\n") { draw(line, at: lastMaxY) }
    }
}
