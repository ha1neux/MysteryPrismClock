//
//  ClockColors.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

struct ClockColors {
    let sColor: Color
    let sPrimeColor: Color
    let mColor: Color
    let mPrimeColor: Color
    let hColor: Color
    let hPrimeColor: Color
    let hmColor: Color
    let hmPrimeColor: Color
    
    /// Initializes clock colors based on a base color and current time components
    /// Colors are calculated in HSB (Hue-Saturation-Brightness) space, where hue values range from 0.0 to 1.0 representing the full color wheel
    ///
    /// - Parameters:
    ///   - baseColor: The starting color for color calculations
    ///   - timeComponents: Tuple containing (seconds, minutes, hours) as Double values
    ///
    /// Color Calculation Strategy:
    /// - All colors derive from the base color by rotating the hue value
    /// - Seconds advance the hue by seconds/60 (one full rotation per minute)
    /// - Minutes advance the hue by minutes/60 (one full rotation per hour)
    /// - Hours advance the hue by hours/12 (one full rotation per 12 hours)
    /// - Prime colors are offset by 1/6 (60 degrees or one color wheel segment) for visual contrast
    init(baseColor: Color, timeComponents: (seconds: Double, minutes: Double, hours: Double)) {
        // Convert base color to HSB components (Hue, Saturation, Brightness)
        let baseHSB = baseColor.hsb

        // SECONDS COLOR: Base hue + seconds offset
        // Calculation: hue advances by 1/60th per second, completing full rotation in 60 seconds
        // Example: At 30 seconds with base hue 0.5 -> 0.5 + 0.5 = 1.0 (wraps to 0.0)
        var hue = baseHSB.hue + timeComponents.seconds / 60.0
        if hue > 1.0 { hue -= 1.0 }  // Wrap around the color wheel (modulo 1.0)
        sColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)

        // SECONDS PRIME COLOR: Offset by 60 degrees (1/6 of color wheel) for complementary appearance
        // Calculation: Subtract 1/6 from seconds color hue
        // Example: If sColor hue is 0.5 -> 0.5 - 0.1667 = 0.3333
        hue = sColor.hsb.hue - 1.0 / 6.0
        if hue < 0.0 { hue += 1.0 }  // Wrap around if negative
        sPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)

        // MINUTES COLOR: Seconds color + minutes offset
        // Calculation: hue advances by 1/60th per minute, completing full rotation in 60 minutes
        // Example: At 15 minutes with sColor hue 0.3 -> 0.3 + 0.25 = 0.55
        hue = sColor.hsb.hue + timeComponents.minutes / 60.0
        if hue > 1.0 { hue -= 1.0 }
        mColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)

        // MINUTES PRIME COLOR: Prime version based on sPrimeColor
        // Maintains the 60-degree offset relationship
        hue = sPrimeColor.hsb.hue + timeComponents.minutes / 60.0
        if hue > 1.0 { hue -= 1.0 }
        mPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)

        // HOURS COLOR: Seconds color + hours offset
        // Calculation: hue advances by 1/12th per hour, completing full rotation in 12 hours
        // Example: At 6 hours with sColor hue 0.2 -> 0.2 + 0.5 = 0.7
        hue = sColor.hsb.hue + timeComponents.hours / 12.0
        if hue > 1.0 { hue -= 1.0 }
        hColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)

        // HOURS PRIME COLOR: Prime version based on sPrimeColor
        // Maintains the 60-degree offset relationship
        hue = sPrimeColor.hsb.hue + timeComponents.hours / 12.0
        if hue > 1.0 { hue -= 1.0 }
        hPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)

        // OVERLAP COLORS: Used where clock hands overlap
        // Simplified to use minute colors (could be blended in future)
        hmColor = mColor
        hmPrimeColor = mPrimeColor
    }
}
