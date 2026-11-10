import AppKit
import EditorCore

final class EditorViewController: NSViewController, NSTextViewDelegate {
    let document: TextDocument
    let scrollView = NSScrollView()
    let textView = NSTextView(usingTextLayoutManager: true)

    var currentText: String { textView.string }

    init(document: TextDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let root = NSView()
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: root.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
        ])
        configureTextView()
        scrollView.documentView = textView
        view = root
    }

    private func configureTextView() {
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.textContainerInset = NSSize(width: 12, height: 10)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.baseWritingDirection = .natural
        textView.font = Self.defaultFont()
        textView.defaultParagraphStyle = {
            let p = NSMutableParagraphStyle()
            p.baseWritingDirection = .natural
            p.alignment = .natural
            return p
        }()
        textView.typingAttributes = [
            .font: textView.font!,
            .paragraphStyle: textView.defaultParagraphStyle!,
        ]
        textView.string = document.text
        textView.delegate = self
    }

    static func defaultFont() -> NSFont {
        NSFont(name: "Vazirmatn", size: 15) ?? NSFont.systemFont(ofSize: 15)
    }

    func textDidChange(_ notification: Notification) {
        document.updateChangeCount(.changeDone)
    }
}
