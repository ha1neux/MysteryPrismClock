//
//  MinuteHourOverlap.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

struct MinuteHourOverlapView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: Double
    let inset: Double
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
        
        ZStack {
            // Pinstripe border
            minuteHandPath
                .stroke(borderColor, lineWidth: 1)
                .mask(hourHandPath)
            
            hourHandPath
                .fill(overlapColor)
                .mask(minuteHandPath)
        }
        .frame(width: clockSize, height: clockSize)
    }
}

