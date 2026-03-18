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
    
    /// Smoothly interpolates between this color and another in HSB color space
    ///
    /// This function performs linear interpolation (lerp) for saturation and brightness,
    /// but uses special logic for hue to ensure the shortest path around the color wheel.
    ///
    /// Color Wheel Wrapping Logic:
    /// The hue component represents a circular color wheel (0.0 to 1.0, wrapping around).
    /// When transitioning from one hue to another, there are two possible paths:
    /// - Clockwise path
    /// - Counter-clockwise path
    ///
    /// This function chooses the shorter path to create more natural color transitions.
    ///
    /// Example:
    /// - From hue 0.1 (red) to 0.9 (purple):
    ///   - Direct path: 0.1 -> 0.9 (distance = 0.8, goes through green/blue)
    ///   - Wrapped path: 0.1 -> 0.0 -> 1.0 -> 0.9 (distance = 0.2, stays in red/purple range)
    ///   - We choose the wrapped path (shorter)
    ///
    /// - Parameters:
    ///   - other: The target color
    ///   - progress: Interpolation progress from 0.0 (self) to 1.0 (other)
    /// - Returns: Interpolated color at the given progress
    func interpolated(to other: Color, progress: Double) -> Color {
        let startHSB = self.hsb
        let endHSB = other.hsb

        // HUE INTERPOLATION with shortest path wrapping
        // Calculate the hue difference (range: -1.0 to 1.0)
        var hueDiff = endHSB.hue - startHSB.hue

        // Adjust for shortest path around the color wheel
        // If difference > 0.5 (more than halfway), wrap backwards (counter-clockwise)
        // Example: 0.9 - 0.1 = 0.8 -> adjust to 0.8 - 1.0 = -0.2 (go backwards instead)
        if hueDiff > 0.5 {
            hueDiff -= 1.0
        }
        // If difference < -0.5 (more than halfway backwards), wrap forwards (clockwise)
        // Example: 0.1 - 0.9 = -0.8 -> adjust to -0.8 + 1.0 = 0.2 (go forwards instead)
        else if hueDiff < -0.5 {
            hueDiff += 1.0
        }

        // Linear interpolation: start + (difference × progress)
        // Example: start=0.1, diff=-0.2, progress=0.5 -> 0.1 + (-0.1) = 0.0
        var interpolatedHue = startHSB.hue + (hueDiff * progress)

        // Normalize hue to [0.0, 1.0] range
        if interpolatedHue < 0.0 { interpolatedHue += 1.0 }
        if interpolatedHue > 1.0 { interpolatedHue -= 1.0 }

        // SATURATION AND BRIGHTNESS: Simple linear interpolation
        // Formula: start + (end - start) × progress
        let interpolatedSaturation = startHSB.saturation + (endHSB.saturation - startHSB.saturation) * progress
        let interpolatedBrightness = startHSB.brightness + (endHSB.brightness - startHSB.brightness) * progress

        return Color(
            hue: interpolatedHue,
            saturation: interpolatedSaturation,
            brightness: interpolatedBrightness
        )
    }
    
    /// Returns a new color with the hue offset by the specified amount (in 0-1 scale)
    /// - Parameter offset: The amount to offset the hue (e.g., 1/6 for 60 degrees)
    /// - Returns: A new color with the same saturation and brightness but offset hue
    func hueOffset(by offset: Double) -> Color {
        let hsbComponents = self.hsb
        var newHue = (hsbComponents.hue + offset)
            .truncatingRemainder(dividingBy: 1.0)
        if newHue < 0.0 { newHue += 1.0 }
        
        return Color(hue: newHue, saturation: hsbComponents.saturation, brightness: hsbComponents.brightness)
    }
}
