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
    
    init(baseColor: Color, timeComponents: (seconds: Double, minutes: Double, hours: Double)) {
        // Convert base color to HSB components
        let baseHSB = baseColor.hsb
        
        // Calculate colors based on time (similar to original logic)
        var hue = baseHSB.hue + timeComponents.seconds / 60.0
        if hue > 1.0 { hue -= 1.0 }
        sColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sColor.hsb.hue - 1.0 / 6.0
        if hue < 0.0 { hue += 1.0 }
        sPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sColor.hsb.hue + timeComponents.minutes / 60.0
        if hue > 1.0 { hue -= 1.0 }
        mColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sPrimeColor.hsb.hue + timeComponents.minutes / 60.0
        if hue > 1.0 { hue -= 1.0 }
        mPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sColor.hsb.hue + timeComponents.hours / 12.0
        if hue > 1.0 { hue -= 1.0 }
        hColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sPrimeColor.hsb.hue + timeComponents.hours / 12.0
        if hue > 1.0 { hue -= 1.0 }
        hPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        // Overlapped colors (simplified)
        hmColor = mColor
        hmPrimeColor = mPrimeColor
    }
}
