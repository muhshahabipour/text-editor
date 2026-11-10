// Usage: swift tools/make-icon.swift  -> writes App/Resources/AppIcon.icns
import AppKit

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.clear(CGRect(x: 0, y: 0, width: s, height: s))

    // Icon body (macOS template: ~10% margin, ~22% corner radius)
    let body = CGRect(x: s * 0.098, y: s * 0.098, width: s * 0.804, height: s * 0.804)
    let bodyPath = CGPath(roundedRect: body, cornerWidth: body.width * 0.225, cornerHeight: body.width * 0.225, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.012), blur: s * 0.03, color: NSColor.black.withAlphaComponent(0.4).cgColor)
    ctx.addPath(bodyPath); ctx.setFillColor(NSColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1).cgColor); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(bodyPath); ctx.clip()
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
        NSColor(red: 0.10, green: 0.62, blue: 0.62, alpha: 1).cgColor,
        NSColor(red: 0.07, green: 0.22, blue: 0.45, alpha: 1).cgColor,
        NSColor(red: 0.08, green: 0.10, blue: 0.30, alpha: 1).cgColor] as CFArray, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: body.minX, y: body.maxY), end: CGPoint(x: body.maxX, y: body.minY), options: [])
    // soft top highlight
    let hi = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
        NSColor.white.withAlphaComponent(0.22).cgColor, NSColor.white.withAlphaComponent(0).cgColor] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(hi, start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.midY), options: [])
    ctx.restoreGState()

    // Two glyphs, one per script, split by a text caret: Latin "A" (LTR) and Persian "ب" (RTL)
    func glyph(_ str: String, fontName: String?, size: CGFloat, centerX: CGFloat) {
        let font = (fontName.flatMap { NSFont(name: $0, size: size) }) ?? NSFont.systemFont(ofSize: size, weight: .heavy)
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
        shadow.shadowOffset = NSSize(width: 0, height: -s * 0.01)
        shadow.shadowBlurRadius = s * 0.02
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white, .shadow: shadow]
        let a = NSAttributedString(string: str, attributes: attrs)
        let sz = a.size()
        a.draw(at: NSPoint(x: centerX - sz.width / 2, y: s * 0.5 - sz.height / 2))
    }
    glyph("A", fontName: nil, size: s * 0.36, centerX: s * 0.335)
    glyph("\u{0628}", fontName: "GeezaPro-Bold", size: s * 0.40, centerX: s * 0.675)

    // Caret
    let caretW = s * 0.032, caretH = s * 0.5
    let caret = CGRect(x: s * 0.5 - caretW / 2, y: s * 0.5 - caretH / 2, width: caretW, height: caretH)
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: s * 0.03, color: NSColor(red: 1, green: 0.7, blue: 0.2, alpha: 0.9).cgColor)
    ctx.addPath(CGPath(roundedRect: caret, cornerWidth: caretW / 2, cornerHeight: caretW / 2, transform: nil))
    ctx.setFillColor(NSColor(red: 1.0, green: 0.78, blue: 0.25, alpha: 1).cgColor); ctx.fillPath()
    ctx.restoreGState()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let fm = FileManager.default
let iconset = fm.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? fm.removeItem(at: iconset)
try fm.createDirectory(at: iconset, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    try render(base).write(to: iconset.appendingPathComponent("icon_\(base)x\(base).png"))
    try render(base * 2).write(to: iconset.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconset.path, "-o", "App/Resources/AppIcon.icns"]
try task.run(); task.waitUntilExit()
try render(512).write(to: URL(fileURLWithPath: "tools/icon-preview.png"))
print("done", task.terminationStatus)
