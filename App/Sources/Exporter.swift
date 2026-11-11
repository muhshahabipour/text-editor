import AppKit
import UniformTypeIdentifiers

enum ExportFormat: CaseIterable {
    case txt, markdown, html, rtf, pdf

    var title: String {
        switch self {
        case .txt: return "Plain Text (.txt)"
        case .markdown: return "Markdown (.md)"
        case .html: return "HTML (.html)"
        case .rtf: return "Rich Text (.rtf)"
        case .pdf: return "PDF (.pdf)"
        }
    }

    var fileExtension: String {
        switch self {
        case .txt: return "txt"
        case .markdown: return "md"
        case .html: return "html"
        case .rtf: return "rtf"
        case .pdf: return "pdf"
        }
    }

    var contentType: UTType {
        UTType(filenameExtension: fileExtension) ?? .plainText
    }
}

enum Exporter {
    static func write(text: String, format: ExportFormat, to url: URL) throws {
        switch format {
        case .txt, .markdown:
            try Data(text.utf8).write(to: url, options: .atomic)
        case .html:
            try Data(html(from: text).utf8).write(to: url, options: .atomic)
        case .rtf:
            let attr = attributedString(from: text)
            let data = try attr.data(from: NSRange(location: 0, length: attr.length),
                                     documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            try data.write(to: url, options: .atomic)
        case .pdf:
            try writePDF(text: text, to: url)
        }
    }

    // MARK: HTML

    static func html(from text: String) -> String {
        func esc(_ s: Substring) -> String {
            s.replacingOccurrences(of: "&", with: "&amp;")
             .replacingOccurrences(of: "<", with: "&lt;")
             .replacingOccurrences(of: ">", with: "&gt;")
        }
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n", omittingEmptySubsequences: false)
        let body = lines.map { $0.isEmpty ? "<p dir=\"auto\">&nbsp;</p>" : "<p dir=\"auto\">\(esc($0))</p>" }
            .joined(separator: "\n")
        return """
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        body { font-family: Vazirmatn, -apple-system, "Helvetica Neue", sans-serif; font-size: 16px;
               line-height: 1.7; max-width: 46em; margin: 2em auto; padding: 0 1em; color: #111; background: #fff; }
        p { margin: 0; white-space: pre-wrap; }
        </style>
        </head>
        <body>
        \(body)
        </body>
        </html>

        """
    }

    // MARK: RTF / PDF

    static func attributedString(from text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle()
        p.baseWritingDirection = .natural
        p.alignment = .natural
        return NSAttributedString(string: text, attributes: [
            .font: EditorViewController.defaultFont(),
            .foregroundColor: NSColor.black,
            .paragraphStyle: p,
        ])
    }

    private static func writePDF(text: String, to url: URL) throws {
        let info = NSPrintInfo()
        info.paperSize = NSSize(width: 595, height: 842) // A4
        info.topMargin = 56; info.bottomMargin = 56; info.leftMargin = 56; info.rightMargin = 56
        info.isVerticallyCentered = false
        info.isHorizontallyCentered = false
        info.jobDisposition = .save
        info.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = url

        let width = info.paperSize.width - info.leftMargin - info.rightMargin
        let tv = NSTextView(frame: NSRect(x: 0, y: 0, width: width, height: 100))
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.minSize = NSSize(width: width, height: 0)
        tv.maxSize = NSSize(width: width, height: .greatestFiniteMagnitude)
        tv.textContainer?.containerSize = NSSize(width: width, height: .greatestFiniteMagnitude)
        tv.textContainer?.widthTracksTextView = true
        tv.textContainerInset = .zero
        tv.drawsBackground = true
        tv.backgroundColor = .white
        tv.appearance = NSAppearance(named: .aqua)
        tv.textStorage?.setAttributedString(attributedString(from: text))
        tv.layoutManager?.ensureLayout(for: tv.textContainer!)
        tv.sizeToFit()

        let op = NSPrintOperation(view: tv, printInfo: info)
        op.showsPrintPanel = false
        op.showsProgressPanel = false
        guard op.run() else {
            throw NSError(domain: "Exporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create the PDF."])
        }
    }
}
