#!/usr/bin/env swift
// Renders the Base app icon at 1024x1024.
import AppKit

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError() }

// Background: deep rose-tinted near-black, vertical gradient
let bgTop = CGColor(red: 0.125, green: 0.078, blue: 0.098, alpha: 1)   // #20141A-ish
let bgBottom = CGColor(red: 0.055, green: 0.039, blue: 0.047, alpha: 1) // #0E0A0C
let bgGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                        colors: [bgTop, bgBottom] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(bgGrad, start: CGPoint(x: 512, y: 1024), end: CGPoint(x: 512, y: 0), options: [])

// Soft rose radial glow behind the mark
let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                      colors: [CGColor(red: 0.94, green: 0.45, blue: 0.70, alpha: 0.22),
                               CGColor(red: 0.94, green: 0.45, blue: 0.70, alpha: 0.0)] as CFArray,
                      locations: [0, 1])!
ctx.drawRadialGradient(glow, startCenter: CGPoint(x: 512, y: 540), startRadius: 0,
                       endCenter: CGPoint(x: 512, y: 540), endRadius: 520, options: [])

// The equals mark: two rounded bars with a rose gradient
let barWidth: CGFloat = 520
let barHeight: CGFloat = 128
let barRadius: CGFloat = 64
let gap: CGFloat = 118
let cx: CGFloat = 512
let cy: CGFloat = 512

let topBar = CGRect(x: cx - barWidth/2, y: cy + gap/2, width: barWidth, height: barHeight)
let bottomBar = CGRect(x: cx - barWidth/2, y: cy - gap/2 - barHeight, width: barWidth, height: barHeight)

let roseBright = CGColor(red: 0.941, green: 0.447, blue: 0.702, alpha: 1) // #F072B3
let roseDeep = CGColor(red: 0.859, green: 0.345, blue: 0.620, alpha: 1)   // #DB589E

// subtle drop shadow for physical presence
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 46,
              color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.45))

for rect in [topBar, bottomBar] {
    let path = CGPath(roundedRect: rect, cornerWidth: barRadius, cornerHeight: barRadius, transform: nil)
    ctx.addPath(path)
    ctx.clip()
    let barGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                             colors: [roseBright, roseDeep] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(barGrad,
                           start: CGPoint(x: rect.midX, y: rect.maxY),
                           end: CGPoint(x: rect.midX, y: rect.minY), options: [])
    ctx.resetClip()
}
ctx.restoreGState()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { fatalError() }
let out = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png")
try! png.write(to: out)
print("wrote \(out.path)")
