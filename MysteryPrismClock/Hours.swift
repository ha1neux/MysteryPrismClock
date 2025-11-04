//
//  Hours.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

func HourHand(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat,
    colors: ClockColors
) -> some View {
    HourHandView(
        timeComponents: timeComponents,
        clockSize: clockSize,
        inset: inset,
        insideColor: colors.hColor,
        outsideColor: colors.hPrimeColor
    )
}

struct HourHandView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: CGFloat
    let inset: CGFloat
    let insideColor: Color
    let outsideColor: Color
    
    var body: some View {
        ZStack {
            // Draw the full hour hand in outsideColor
            hourPath(
                timeComponents: (seconds: 0.0, minutes: 0.0, hours: timeComponents.hours),
                clockSize: clockSize,
                inset: inset
            )
            .fill(outsideColor)
            
            // Draw the overlapping area with seconds disk in insideColor
            hourPath(
                timeComponents: (seconds: 0.0, minutes: 0.0, hours: timeComponents.hours),
                clockSize: clockSize,
                inset: inset
            )
            .fill(insideColor)
            .mask(
                // Create seconds disk path for masking
                secondsPath(
                    timeComponents: timeComponents,
                    clockSize: clockSize,
                    inset: inset
                )
            )
        }
        .frame(width: clockSize, height: clockSize)
    }
}

func hourPath(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat
) -> Path {
    let angle = (.pi / 6.0) * timeComponents.hours
    let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
    let radius = clockSize * inset / 2.5

    return Path { path in
        let radius1 = radius
        let radius2 = radius / 2
        
        let point1 = CGPoint(
            x: center.x + radius1 * Foundation.sin(angle),
            y: center.y - radius1 * Foundation.cos(angle)
        )
        let point2 = CGPoint(
            x: center.x + radius2 * Foundation.sin(angle + .pi/2),
            y: center.y - radius2 * Foundation.cos(angle + .pi/2)
        )
        let point3 = CGPoint(
            x: center.x + radius2 * Foundation.sin(angle - .pi/2),
            y: center.y - radius2 * Foundation.cos(angle - .pi/2)
        )
        
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.closeSubpath()
    }
}
