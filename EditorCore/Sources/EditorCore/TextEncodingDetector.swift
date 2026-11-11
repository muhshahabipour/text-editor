import Foundation

public enum TextEncodingDetector {
    public static let windows1256 = String.Encoding(
        rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.windowsArabic.rawValue)))

    public static func decode(_ data: Data) -> (text: String, encoding: String.Encoding)? {
        if data.count >= 2, (data[0] == 0xFF && data[1] == 0xFE) || (data[0] == 0xFE && data[1] == 0xFF) {
            if let s = String(data: data, encoding: .utf16) { return (s, .utf16) }
        }
        var body = data
        if data.starts(with: [0xEF, 0xBB, 0xBF]) { body = data.dropFirst(3) }
        if let s = String(data: body, encoding: .utf8) { return (s, .utf8) }
        if let s = String(data: data, encoding: windows1256) { return (s, windows1256) }
        return nil
    }

    public static func decode(_ data: Data, using encoding: String.Encoding) -> String? {
        String(data: data, encoding: encoding)
    }
}
