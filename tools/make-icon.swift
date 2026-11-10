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
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.012), blur: s * 0.03, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    ctx.addPath(bodyPath); ctx.setFillColor(NSColor(red: 0.2, green: 0.25, blue: 0.7, alpha: 1).cgColor); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(bodyPath); ctx.clip()
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
        NSColor(red: 0.30, green: 0.52, blue: 0.98, alpha: 1).cgColor,
        NSColor(red: 0.35, green: 0.25, blue: 0.85, alpha: 1).cgColor] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
    ctx.restoreGState()

    // Page
    let page = CGRect(x: s * 0.27, y: s * 0.2, width: s * 0.46, height: s * 0.6)
    let pagePath = CGPath(roundedRect: page, cornerWidth: s * 0.04, cornerHeight: s * 0.04, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.01), blur: s * 0.025, color: NSColor.black.withAlphaComponent(0.3).cgColor)
    ctx.addPath(pagePath); ctx.setFillColor(NSColor.white.cgColor); ctx.fillPath()
    ctx.restoreGState()

    // Text lines: top group left-aligned (LTR), bottom group right-aligned (RTL)
    let lineH = s * 0.032, gap = s * 0.062
    let left = page.minX + s * 0.05, right = page.maxX - s * 0.05
    let full = right - left
    func line(y: CGFloat, w: CGFloat, fromLeft: Bool, color: NSColor) {
        let x = fromLeft ? left : right - w
        let r = CGRect(x: x, y: y, width: w, height: lineH)
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: lineH / 2, cornerHeight: lineH / 2, transform: nil))
        ctx.setFillColor(color.cgColor); ctx.fillPath()
    }
    let blue = NSColor(red: 0.30, green: 0.40, blue: 0.9, alpha: 1)
    let gray = NSColor(white: 0.78, alpha: 1)
    var y = page.maxY - s * 0.11
    line(y: y, w: full * 0.55, fromLeft: true, color: blue); y -= gap
    line(y: y, w: full, fromLeft: true, color: gray); y -= gap
    line(y: y, w: full * 0.8, fromLeft: true, color: gray); y -= gap * 1.25
    let orange = NSColor(red: 0.98, green: 0.55, blue: 0.2, alpha: 1)
    line(y: y, w: full * 0.55, fromLeft: false, color: orange); y -= gap
    line(y: y, w: full, fromLeft: false, color: gray); y -= gap
    line(y: y, w: full * 0.7, fromLeft: false, color: gray)

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
