//
//  SecondsDisk.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

struct SecondsDisk: View {
    let timeSeconds: Double
    let clockSize: CGFloat
    let inset: CGFloat
    let color: Color
    let borderColor: Color
    
    var body: some View {
        let radius = clockSize * inset / 3.0
        let angle = 2.0 * .pi * timeSeconds / 60.0
        let offset = CGPoint(
            x: radius * Foundation.sin(angle) / 2.0,
            y: radius * Foundation.cos(angle) / 2.0
        )
        
        ZStack {
            // Pinstripe border
            Circle()
                .stroke(borderColor, lineWidth: 1)
                .frame(width: radius * 2, height: radius * 2)
                .offset(x: offset.x, y: -offset.y)
            
            // Fill
            Circle()
                .fill(color)
                .frame(width: radius * 2, height: radius * 2)
                .offset(x: offset.x, y: -offset.y) // Flip y for SwiftUI coordinate system
        }
    }
}

func secondsPath(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat
) -> Path {
    let radius = clockSize * inset / 3.0
    let angle = 2.0 * .pi * timeComponents.seconds / 60.0
    let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
    let offset = CGPoint(
        x: radius * Foundation.sin(angle) / 2.0,
        y: radius * Foundation.cos(angle) / 2.0
    )
    
    let circleCenter = CGPoint(
        x: center.x + offset.x,
        y: center.y - offset.y // Flip y for SwiftUI coordinate system
    )
    
    return Path { path in
        path.addEllipse(in: CGRect(
            x: circleCenter.x - radius,
            y: circleCenter.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
    }
}
