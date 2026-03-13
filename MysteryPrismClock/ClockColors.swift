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
    let sPrimeBorderColor: Color
    let sBorderColor: Color
    let mBorderColor: Color
    let hBorderColor: Color
    let hmBorderColor: Color
    let hmPrimeBorderColor: Color
    
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
        // Convert base color to HSB components once (only NSColor round-trip)
        let baseHSB = baseColor.hsb
        let sat = baseHSB.saturation
        let brt = baseHSB.brightness

        // Seconds hue: base + seconds/60 (one full rotation per minute)
        let sHue = (baseHSB.hue + timeComponents.seconds / 60.0)
            .truncatingRemainder(dividingBy: 1.0)
        sColor = Color(hue: sHue, saturation: sat, brightness: brt)

        // Seconds prime: 60° behind seconds for visual contrast
        var sPrimeHue = sHue - 1.0 / 6.0
        if sPrimeHue < 0.0 { sPrimeHue += 1.0 }
        sPrimeColor = Color(hue: sPrimeHue, saturation: sat, brightness: brt)

        // Minutes: seconds hue + minutes/60 (one full rotation per hour)
        let mHue = (sHue + timeComponents.minutes / 60.0)
            .truncatingRemainder(dividingBy: 1.0)
        mColor = Color(hue: mHue, saturation: sat, brightness: brt)

        // Minutes prime: sPrime hue + minutes/60
        let mPrimeHue = (sPrimeHue + timeComponents.minutes / 60.0)
            .truncatingRemainder(dividingBy: 1.0)
        mPrimeColor = Color(hue: mPrimeHue, saturation: sat, brightness: brt)

        // Hours: seconds hue + hours/12 (one full rotation per 12 hours)
        let hHue = (sHue + timeComponents.hours / 12.0)
            .truncatingRemainder(dividingBy: 1.0)
        hColor = Color(hue: hHue, saturation: sat, brightness: brt)

        // Hours prime: sPrime hue + hours/12
        let hPrimeHue = (sPrimeHue + timeComponents.hours / 12.0)
            .truncatingRemainder(dividingBy: 1.0)
        hPrimeColor = Color(hue: hPrimeHue, saturation: sat, brightness: brt)

        // Overlap colors: used where clock hands overlap
        hmColor = mColor
        hmPrimeColor = mPrimeColor

        // Border colors: 60° ahead for pinstripe contrast
        sPrimeBorderColor = Color(hue: (sPrimeHue + 1.0 / 6.0).truncatingRemainder(dividingBy: 1.0),
                                  saturation: sat, brightness: brt)
        sBorderColor = Color(hue: (sHue + 1.0 / 6.0).truncatingRemainder(dividingBy: 1.0),
                             saturation: sat, brightness: brt)
        mBorderColor = Color(hue: (mHue + 1.0 / 6.0).truncatingRemainder(dividingBy: 1.0),
                             saturation: sat, brightness: brt)
        hBorderColor = Color(hue: (hHue + 1.0 / 6.0).truncatingRemainder(dividingBy: 1.0),
                             saturation: sat, brightness: brt)
        hmBorderColor = Color(hue: (mHue + 1.0 / 6.0).truncatingRemainder(dividingBy: 1.0),
                              saturation: sat, brightness: brt)
        hmPrimeBorderColor = Color(hue: (mPrimeHue + 1.0 / 6.0).truncatingRemainder(dividingBy: 1.0),
                                   saturation: sat, brightness: brt)
    }
}
