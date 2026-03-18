//
//  MinuteHourSecondsOverlapView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

struct MinuteHourSecondsOverlapView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: Double
    let inset: Double
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
        
        ZStack {
            // Pinstripe border
            minuteHandPath
                .stroke(borderColor, lineWidth: 1)
                .mask(hourHandPath)
                .mask(secondsHandPath)
            
            hourHandPath
                .fill(overlapColor)
                .mask(minuteHandPath)
                .mask(secondsHandPath)
        }
        .frame(width: clockSize, height: clockSize)
    }
}
