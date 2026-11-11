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

    let statusBar = StatusBarView()

    override func loadView() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 760, height: 560))
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        statusBar.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(scrollView); root.addSubview(statusBar)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: root.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: statusBar.topAnchor),
            statusBar.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            statusBar.bottomAnchor.constraint(equalTo: root.bottomAnchor),
        ])
        configureTextView()
        scrollView.documentView = textView
        statusBar.onDigitsToggled = { [weak self] in self?.refreshStatus() }
        view = root
        applyLineNumbers()
        refreshStatus()
    }

    func applyLineNumbers() {
        if Preferences.showLineNumbers {
            scrollView.verticalRulerView = LineNumberRulerView(textView: textView)
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
        } else {
            scrollView.rulersVisible = false
        }
    }

    static let findController = PersianFindController()
    @objc func showPersianFind(_ sender: Any?) { Self.findController.show(for: textView) }

    @objc func toggleLineNumbers(_ sender: Any?) {
        Preferences.showLineNumbers.toggle()
        applyLineNumbers()
    }

    private var exportFormats: [ExportFormat] { ExportFormat.allCases }
    private weak var exportPanel: NSSavePanel?
    private weak var exportPopup: NSPopUpButton?

    @objc func exportDocument(_ sender: Any?) {
        guard let window = view.window else { return }
        let panel = NSSavePanel()
        panel.title = "Export As"
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = document.displayName
        let popup = NSPopUpButton(frame: .zero, pullsDown: false)
        popup.addItems(withTitles: exportFormats.map(\.title))
        popup.target = self
        popup.action = #selector(exportFormatChanged(_:))
        let label = NSTextField(labelWithString: "Format:")
        let stack = NSStackView(views: [label, popup])
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        panel.accessoryView = stack
        exportPanel = panel; exportPopup = popup
        exportFormatChanged(popup)
        let text = textView.string
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url, let self,
                  let idx = self.exportPopup?.indexOfSelectedItem else { return }
            do { try Exporter.write(text: text, format: self.exportFormats[idx], to: url) }
            catch { NSAlert(error: error).beginSheetModal(for: window) }
        }
    }

    @objc private func exportFormatChanged(_ sender: NSPopUpButton) {
        guard let panel = exportPanel else { return }
        let f = exportFormats[sender.indexOfSelectedItem]
        panel.allowedContentTypes = [f.contentType]
        var name = panel.nameFieldStringValue
        if let dot = name.lastIndex(of: "."), name[name.index(after: dot)...].count <= 4 { name = String(name[..<dot]) }
        panel.nameFieldStringValue = name
    }

    func refreshStatus() {
        let text = textView.string
        let pos = StatsCalculator.position(in: text, utf16Offset: textView.selectedRange().location)
        statusBar.update(stats: StatsCalculator.stats(for: text), line: pos.line, column: pos.column)
    }

    func textViewDidChangeSelection(_ notification: Notification) { refreshStatus() }

    private func configureTextView() {
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.isContinuousSpellCheckingEnabled = true
        NSSpellChecker.shared.automaticallyIdentifiesLanguages = true
        textView.isGrammarCheckingEnabled = false
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
        textView.drawsBackground = true
        textView.backgroundColor = .textBackgroundColor
        textView.textColor = .textColor
        textView.insertionPointColor = .textColor
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor
        textView.typingAttributes = [
            .font: textView.font!,
            .foregroundColor: NSColor.textColor,
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
        refreshStatus()
    }
}
