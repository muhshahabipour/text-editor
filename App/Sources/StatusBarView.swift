import AppKit
import EditorCore

final class StatusBarView: NSView {
    private let label = NSTextField(labelWithString: "")
    private let digitsButton = NSButton(checkboxWithTitle: "۱۲۳", target: nil, action: nil)
    var onDigitsToggled: (() -> Void)?

    override init(frame: NSRect) {
        super.init(frame: frame)
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        digitsButton.controlSize = .small
        digitsButton.font = .systemFont(ofSize: 11)
        digitsButton.state = Preferences.persianDigits ? .on : .off
        digitsButton.target = self
        digitsButton.action = #selector(toggled)
        digitsButton.toolTip = "Show numbers with Persian digits"
        digitsButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label); addSubview(digitsButton)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            digitsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            digitsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func toggled() {
        Preferences.persianDigits = digitsButton.state == .on
        onDigitsToggled?()
    }

    func update(stats: TextStats, line: Int, column: Int) {
        let nf = NumberFormatter(); nf.numberStyle = .decimal; nf.locale = Locale(identifier: "en_US")
        func n(_ v: Int) -> String { nf.string(from: NSNumber(value: v)) ?? "\(v)" }
        var s = "Line \(n(line)), Col \(n(column))  ·  \(n(stats.words)) words  ·  \(n(stats.characters)) chars"
        if Preferences.persianDigits { s = PersianText.toPersianDigits(s) }
        label.stringValue = s
    }
}
