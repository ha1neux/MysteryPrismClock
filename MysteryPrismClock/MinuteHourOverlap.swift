//
//  MinuteHourOverlap.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

func MinuteHourOverlap(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat,
    colors: ClockColors
) -> some View {
    MinuteHourOverlapView(
        timeComponents: timeComponents,
        clockSize: clockSize,
        inset: inset,
        overlapColor: colors.hmColor,
        borderColor: colors.hmColor.hueOffset(by: 1.0/6.0)
    )
}


struct MinuteHourOverlapView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: CGFloat
    let inset: CGFloat
    let overlapColor: Color
    let borderColor: Color
    
    var body: some View {
        // Create paths for both hands using the helper functions
        let minuteHandPath = minutePath(
            timeComponents: (seconds: 0.0, minutes: timeComponents.minutes, hours: 0.0),
            clockSize: clockSize,
            inset: inset
        )
        let hourHandPath = hourPath(
            timeComponents: (seconds: 0.0, minutes: 0.0, hours: timeComponents.hours),
            clockSize: clockSize,
            inset: inset
        )
        
        // Create intersection using blend mode
        ZStack {
            // Pinstripe border
            minuteHandPath
                .stroke(borderColor, lineWidth: 1)
                .mask(hourHandPath)
            
            minuteHandPath
                .fill(overlapColor.opacity(0.0)) // Invisible base
            
            hourHandPath
                .fill(overlapColor)
                .blendMode(.sourceAtop) // Only show where it overlaps with minute path
                .mask(minuteHandPath) // Mask with minute hand shape
        }
        .frame(width: clockSize, height: clockSize)
    }
}

