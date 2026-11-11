import Foundation

public struct TextStats: Equatable {
    public var words: Int
    public var characters: Int
    public var lines: Int
    public init(words: Int, characters: Int, lines: Int) {
        self.words = words; self.characters = characters; self.lines = lines
    }
}

public enum StatsCalculator {
    public static func stats(for text: String) -> TextStats {
        var words = 0
        text.enumerateSubstrings(in: text.startIndex..., options: [.byWords, .substringNotRequired]) { _, _, _, _ in
            words += 1
        }
        let lines = text.reduce(1) { $1 == "\n" ? $0 + 1 : $0 }
        return TextStats(words: words, characters: text.count, lines: lines)
    }

    /// 1-based line and column (column counted in UTF-16 units, matching NSTextView selection).
    public static func position(in text: String, utf16Offset: Int) -> (line: Int, column: Int) {
        let ns = text as NSString
        let offset = max(0, min(utf16Offset, ns.length))
        var line = 1
        var lineStart = 0
        var i = 0
        while i < offset {
            if ns.character(at: i) == 0x0A { line += 1; lineStart = i + 1 }
            i += 1
        }
        return (line, offset - lineStart + 1)
    }
}
