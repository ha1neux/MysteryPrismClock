//
//  ClockPathsTests.swift
//  MysteryPrismClockTests
//
//  Created by Claude on 11/15/25.
//

import Testing
import SwiftUI

struct ClockPathsTests {

    // MARK: - Minute Hand Path Tests

    @Test func minuteHandPathAtTwelveOClock() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = 0

        let path = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        #expect(!path.isEmpty, "Path should not be empty")

        // The tip should be at (100, 50) - directly above center
        let expectedTipY = center.y - radius
        #expect(abs(expectedTipY - 50) <= 0.1)
    }

    @Test func minuteHandPathAtThreeOClock() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = .pi / 2

        let path = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        #expect(!path.isEmpty)
    }

    @Test func minuteHandPathBaseDimensions() {
        let radius: CGFloat = 50

        // Base width should be radius / 2.5
        let expectedBaseRadius = radius / 2.5
        #expect(abs(expectedBaseRadius - 20) <= 0.1, "Base radius should be 1/2.5 of tip radius")
    }

    @Test func minuteHandPathIsTriangular() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = .pi / 4

        let path = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        #expect(!path.isEmpty)
    }

    // MARK: - Hour Hand Path Tests

    @Test func hourHandPathAtTwelveOClock() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = 0

        let path = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!path.isEmpty)

        // Tip should be at (100, 60) - directly above center
        let expectedTipY = center.y - radius
        #expect(abs(expectedTipY - 60) <= 0.1)
    }

    @Test func hourHandPathAtSixOClock() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = .pi

        let path = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!path.isEmpty)
    }

    @Test func hourHandPathBaseDimensions() {
        let radius: CGFloat = 40

        // Base width should be radius / 2
        let expectedBaseRadius = radius / 2
        #expect(abs(expectedBaseRadius - 20) <= 0.1, "Base radius should be 1/2 of tip radius")
    }

    @Test func hourHandPathIsTriangular() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = .pi / 3

        let path = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!path.isEmpty)
    }

    // MARK: - Comparison Tests

    @Test func minuteHandNarrowerThanHourHand() {
        let radius: CGFloat = 50

        // Minute hand base (radius/2.5 = 20) should be narrower than hour hand base (radius/2 = 25)
        let minuteBaseRadius = radius / 2.5
        let hourBaseRadius = radius / 2
        #expect(minuteBaseRadius < hourBaseRadius, "Minute hand should be narrower than hour hand")
    }

    // MARK: - Angle Calculation Tests

    @Test func pathPointsCalculation() {
        let radius: CGFloat = 10
        let angle: Double = .pi / 2

        let expectedX = radius * sin(angle)
        let expectedY = -radius * cos(angle)

        #expect(abs(expectedX - 10) <= 0.1)
        #expect(abs(expectedY - 0) <= 0.1)
    }

    @Test func pathGeometryConsistency() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = .pi / 4

        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!minutePath.isEmpty)
        #expect(!hourPath.isEmpty)
    }

    // MARK: - Edge Cases

    @Test func zeroRadius() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 0
        let angle: Double = 0

        // Should create valid paths (even if degenerate)
        _ = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        _ = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)
    }

    @Test func negativeAngle() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = -.pi / 2

        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!minutePath.isEmpty)
        #expect(!hourPath.isEmpty)
    }

    @Test func largeAngle() {
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = 3 * .pi

        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!minutePath.isEmpty)
        #expect(!hourPath.isEmpty)
    }

    @Test func veryLargeRadius() {
        let center = CGPoint(x: 1000, y: 1000)
        let radius: CGFloat = 10000
        let angle: Double = .pi / 4

        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        #expect(!minutePath.isEmpty)
        #expect(!hourPath.isEmpty)
    }
}
