// Usage: swift tools/make-icon.swift  -> writes App/Resources/AppIcon.icns (and tools/icon-preview.png)
import AppKit

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let u = s / 512  // design units are on a 512 canvas
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    func col(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(red: r, green: g, blue: b, alpha: a) }
    func pill(_ r: CGRect, _ radius: CGFloat, _ c: CGColor) {
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil))
        ctx.setFillColor(c); ctx.fillPath()
    }

    // Body (macOS template: ~10% margin, ~22.5% corner radius)
    let body = CGRect(x: 50 * u, y: 50 * u, width: 412 * u, height: 412 * u)
    let path = CGPath(roundedRect: body, cornerWidth: body.width * 0.225, cornerHeight: body.width * 0.225, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -6 * u), blur: 14 * u, color: col(0, 0, 0, 0.35))
    ctx.addPath(path); ctx.setFillColor(col(0.2, 0.22, 0.27)); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(path); ctx.clip()
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: [col(0.2, 0.22, 0.27), col(0.08, 0.09, 0.12)] as CFArray, locations: nil)!
    ctx.drawLinearGradient(grad, start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
    ctx.restoreGState()

    // Text lines; the last one is green and ends with a caret
    let widths: [CGFloat] = [200, 255, 170, 230]
    let white = col(0.92, 0.93, 0.96), green = col(0.55, 0.95, 0.7)
    for (i, w) in widths.enumerated() {
        pill(CGRect(x: 130 * u, y: (345 - CGFloat(i) * 62) * u, width: w * u, height: 22 * u), 11 * u, i == 3 ? green : white)
    }
    pill(CGRect(x: (130 + 230 + 12) * u, y: (345 - 3 * 62 - 10) * u, width: 16 * u, height: 42 * u), 4 * u, green)

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
