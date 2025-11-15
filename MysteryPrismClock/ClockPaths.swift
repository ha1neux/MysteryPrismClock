//
//  ClockPaths.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

/// Utility struct for generating clock hand paths
/// All paths are triangular, with the tip pointing outward and the base at the center
struct ClockPaths {

    /// Creates a path for a clock minute hand
    ///
    /// Geometry:
    /// - Creates an isosceles triangle with the tip pointing in the direction of the angle
    /// - Base width is radius/2.5 (narrower than hour hand)
    /// - Tip extends to the full radius length
    ///
    /// Coordinate System:
    /// - Angle 0 points to 12 o'clock (upward, -Y direction)
    /// - Angles increase clockwise
    /// - Y-axis is inverted (positive Y is down) per standard screen coordinates
    ///
    /// - Parameters:
    ///   - center: The center point of the clock (origin of the hand)
    ///   - radius: Length from center to tip of the hand
    ///   - angle: Rotation angle in radians (0 = 12 o'clock, π/2 = 3 o'clock)
    /// - Returns: A triangular Path representing the minute hand
    static func minuteHandPath(center: CGPoint, radius: CGFloat, angle: Double) -> Path {
        Path { path in
            // Tip radius (full length of the hand)
            let radius1 = radius

            // Base radius (perpendicular distance from center to base vertices)
            // Smaller value = narrower hand
            let radius2 = radius / 2.5

            // TIP POINT: Point at the end of the clock hand
            // Formula: Convert polar coordinates (angle, radius) to Cartesian (x, y)
            //   x = center.x + radius * sin(angle)
            //   y = center.y - radius * cos(angle)  [negative because Y is inverted on screen]
            //
            // When angle = 0 (12 o'clock): sin(0)=0, cos(0)=1 -> point is directly above center
            // When angle = π/2 (3 o'clock): sin(π/2)=1, cos(π/2)=0 -> point is to the right
            let point1 = CGPoint(
                x: center.x + radius1 * Foundation.sin(angle),
                y: center.y - radius1 * Foundation.cos(angle)
            )

            // BASE LEFT POINT: Left vertex of the triangle base
            // Perpendicular to the hand direction (angle + π/2 = 90° clockwise)
            // Using smaller radius2 to create the base width
            let point2 = CGPoint(
                x: center.x + radius2 * Foundation.sin(angle + .pi/2),
                y: center.y - radius2 * Foundation.cos(angle + .pi/2)
            )

            // BASE RIGHT POINT: Right vertex of the triangle base
            // Perpendicular to the hand direction (angle - π/2 = 90° counter-clockwise)
            let point3 = CGPoint(
                x: center.x + radius2 * Foundation.sin(angle - .pi/2),
                y: center.y - radius2 * Foundation.cos(angle - .pi/2)
            )

            // Draw the triangle: tip -> base-left -> base-right -> tip
            path.move(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.closeSubpath()
        }
    }

    /// Creates a path for a clock hour hand
    ///
    /// Geometry:
    /// - Creates an isosceles triangle similar to minute hand but wider
    /// - Base width is radius/2 (wider than minute hand for visual distinction)
    /// - Typically drawn with a shorter radius than the minute hand
    ///
    /// Coordinate System:
    /// - Same as minuteHandPath (0 = 12 o'clock, angles increase clockwise)
    ///
    /// - Parameters:
    ///   - center: The center point of the clock (origin of the hand)
    ///   - radius: Length from center to tip of the hand
    ///   - angle: Rotation angle in radians (0 = 12 o'clock, π/2 = 3 o'clock)
    /// - Returns: A triangular Path representing the hour hand
    static func hourHandPath(center: CGPoint, radius: CGFloat, angle: Double) -> Path {
        Path { path in
            // Tip radius (full length of the hand)
            let radius1 = radius

            // Base radius (perpendicular distance from center to base vertices)
            // Larger value than minute hand = wider appearance
            let radius2 = radius / 2

            // TIP POINT: Point at the end of the clock hand
            // Same trigonometric formula as minute hand
            let point1 = CGPoint(
                x: center.x + radius1 * Foundation.sin(angle),
                y: center.y - radius1 * Foundation.cos(angle)
            )

            // BASE LEFT POINT: Left vertex of the triangle base
            let point2 = CGPoint(
                x: center.x + radius2 * Foundation.sin(angle + .pi/2),
                y: center.y - radius2 * Foundation.cos(angle + .pi/2)
            )

            // BASE RIGHT POINT: Right vertex of the triangle base
            let point3 = CGPoint(
                x: center.x + radius2 * Foundation.sin(angle - .pi/2),
                y: center.y - radius2 * Foundation.cos(angle - .pi/2)
            )

            // Draw the triangle: tip -> base-left -> base-right -> tip
            path.move(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.closeSubpath()
        }
    }
}
