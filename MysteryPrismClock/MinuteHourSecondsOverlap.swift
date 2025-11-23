//
//  MinuteHourSecondsOverlapView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

func MinuteHourSecondsOverlap(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat,
    colors: ClockColors
) -> some View {
    MinuteHourSecondsOverlapView(
        timeComponents: timeComponents,
        clockSize: clockSize,
        inset: inset,
        overlapColor: colors.hmPrimeColor,
        borderColor: colors.hmPrimeColor.hueOffset(by: 1.0/6.0)
    )
}

struct MinuteHourSecondsOverlapView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: CGFloat
    let inset: CGFloat
    let overlapColor: Color
    let borderColor: Color
    
    var body: some View {
        // Create paths using the helper functions
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
        let secondsHandPath = secondsPath(
            timeComponents: timeComponents,
            clockSize: clockSize,
            inset: inset
        )
        
        // Create three-way intersection using multiple masks
        ZStack {
            // Pinstripe border
            minuteHandPath
                .stroke(borderColor, lineWidth: 1)
                .mask(hourHandPath)
                .mask(secondsHandPath)
            
            // Start with minute hand as base (invisible)
            minuteHandPath
                .fill(overlapColor.opacity(0.0))
            
            // Hour hand masked by minute hand
            hourHandPath
                .fill(overlapColor)
                .mask(minuteHandPath)
                .mask(secondsHandPath) // Additionally mask by seconds path for triple intersection
        }
        .frame(width: clockSize, height: clockSize)
    }
}
