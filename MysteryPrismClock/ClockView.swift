//
//  ClockView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

// This does all the work of drawing the clock.

import SwiftUI

struct ClockView: View {
    let time: Date
    let clockBaseColor: Color
    let clockSize: CGFloat
    let inset: CGFloat
    let insetPrime: CGFloat
    var opacity: CGFloat = 1.0  // Add opacity parameter with default value
    
    private var timeComponents: (seconds: Double, minutes: Double, hours: Double) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        let intHours = components.hour ?? 0
        let intMinutes = components.minute ?? 0
        let intSeconds = components.second ?? 0
        
        // Get fractional seconds for smooth animation
        let timeInterval = time.timeIntervalSince1970
        let fractionalSeconds = timeInterval - floor(timeInterval)
        
        var seconds = Double(intSeconds) + fractionalSeconds
        if seconds >= 60.0 { seconds -= 60.0 }
        
        var minutes = Double(intMinutes) + (seconds / 60.0)
        if minutes >= 60.0 { minutes -= 60.0 }
        
        var hours = Double(intHours) + (minutes / 60.0)
        if hours >= 12.0 { hours -= 12.0 }
        
        return (seconds, minutes, hours)
    }
    
    var body: some View {
        let tc = timeComponents
        let c = ClockColors(baseColor: clockBaseColor, timeComponents: tc)

        ZStack {
            Group {
                // Clock frame with gray border and filled with clockBaseColor
                RoundedRectangle(cornerRadius: clockSize * insetPrime)
                    .fill(clockBaseColor)
                    .stroke(Color.gray, lineWidth: clockSize * insetPrime / 6.5)
                    .frame(width: clockSize, height: clockSize)
                
                // Clock face
                Circle()
                    .fill(c.sPrimeColor)
                    .stroke(c.sPrimeBorderColor, lineWidth: 1)
                    .frame(width: clockSize * inset, height: clockSize * inset)
                
                // Seconds disk
                SecondsDisk(
                    timeSeconds: tc.seconds,
                    clockSize: clockSize,
                    inset: inset,
                    color: c.sColor,
                    borderColor: c.sBorderColor
                )
                
                // Clock hands
                MinuteHandView(
                    timeComponents: tc,
                    clockSize: clockSize,
                    inset: inset,
                    insideColor: c.mColor,
                    outsideColor: c.mPrimeColor,
                    borderColor: c.mBorderColor
                )
                
                HourHandView(
                    timeComponents: tc,
                    clockSize: clockSize,
                    inset: inset,
                    insideColor: c.hColor,
                    outsideColor: c.hPrimeColor,
                    borderColor: c.hBorderColor
                )
                
                MinuteHourOverlapView(
                    timeComponents: tc,
                    clockSize: clockSize,
                    inset: inset,
                    overlapColor: c.hmColor,
                    borderColor: c.hmBorderColor
                )
                
                MinuteHourSecondsOverlapView(
                    timeComponents: tc,
                    clockSize: clockSize,
                    inset: inset,
                    overlapColor: c.hmPrimeColor,
                    borderColor: c.hmPrimeBorderColor
                )
            }
            .opacity(opacity)
            
            // Center dot - always fully opaque
            Circle()
                .fill(Color.black)
                .frame(width: clockSize / 3.0, height: clockSize / 3.0)
        }
    }
}
