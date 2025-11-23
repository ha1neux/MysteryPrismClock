//
//  ColorExtension.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

// Extensions for color manipulation
extension Color {
    static var random: Color {
        Color(
            hue: Double.random(in: 0...1),
            saturation: Double.random(in: 0.3...0.6),
            brightness: Double.random(in: 0.7...0.9)
        )
    }
    
    var hsb: (hue: Double, saturation: Double, brightness: Double) {
        let nsColor = NSColor(self)
        if let hsb = nsColor.usingColorSpace(.deviceRGB) {
            return (Double(hsb.hueComponent), Double(hsb.saturationComponent), Double(hsb.brightnessComponent))
        }
        
        // Fallback values
        return (0.5, 0.9, 0.8)
    }
    
    /// Returns a new color with the hue offset by the specified amount (in 0-1 scale)
    /// - Parameter offset: The amount to offset the hue (e.g., 1/6 for 60 degrees)
    /// - Returns: A new color with the same saturation and brightness but offset hue
    func hueOffset(by offset: Double) -> Color {
        let hsbComponents = self.hsb
        var newHue = hsbComponents.hue + offset
        
        // Wrap around the color wheel
        if newHue > 1.0 { newHue -= 1.0 }
        if newHue < 0.0 { newHue += 1.0 }
        
        return Color(hue: newHue, saturation: hsbComponents.saturation, brightness: hsbComponents.brightness)
    }
}
