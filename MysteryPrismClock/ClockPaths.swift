//
//  ClockPaths.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

struct ClockPaths {
    static func minuteHandPath(center: CGPoint, radius: CGFloat, angle: Double) -> Path {
        Path { path in
            let radius1 = radius
            let radius2 = radius / 2.5
            
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
    
    static func hourHandPath(center: CGPoint, radius: CGFloat, angle: Double) -> Path {
        Path { path in
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
}
