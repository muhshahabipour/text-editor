import Foundation

public enum PersianText {
    private static let letterMap: [Character: Character] = [
        "ي": "ی", "ى": "ی", "ك": "ک",
    ]

    public static func normalizeLetters(_ s: String) -> String {
        String(s.map { letterMap[$0] ?? $0 })
    }

    public static func toPersianDigits(_ s: String) -> String {
        let persian = Array("۰۱۲۳۴۵۶۷۸۹")
        return String(s.map { c in
            if let d = c.wholeNumberValue, c.isASCII { return persian[d] }
            return c
        })
    }

    /// Ranges (UTF-16, in the ORIGINAL text) where `query` occurs.
    public static func findRanges(of query: String, in text: String, ignoreVariants: Bool) -> [NSRange] {
        guard !query.isEmpty else { return [] }
        let t = ignoreVariants ? normalizeLetters(text) : text
        let q = ignoreVariants ? normalizeLetters(query) : query
        let ns = t as NSString
        var results: [NSRange] = []
        var search = NSRange(location: 0, length: ns.length)
        while search.length > 0 {
            let r = ns.range(of: q, options: [.caseInsensitive], range: search)
            if r.location == NSNotFound { break }
            results.append(r)
            let next = r.location + max(r.length, 1)
            search = NSRange(location: next, length: ns.length - next)
        }
        return results
    }
}
