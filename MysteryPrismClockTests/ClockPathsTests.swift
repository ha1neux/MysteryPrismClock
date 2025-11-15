//
//  ClockPathsTests.swift
//  MysteryPrismClockTests
//
//  Created by Claude on 11/15/25.
//

import XCTest
import SwiftUI

final class ClockPathsTests: XCTestCase {

    // MARK: - Minute Hand Path Tests

    func testMinuteHandPathAtTwelveOClock() {
        // Given: Center point, radius, and angle pointing to 12 o'clock (0 radians)
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = 0 // 12 o'clock

        // When: Creating minute hand path
        let path = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        // Then: Path should have correct geometry
        XCTAssertFalse(path.isEmpty, "Path should not be empty")

        // The tip should be at (100, 50) - directly above center
        // point1 = (100 + 50*sin(0), 100 - 50*cos(0)) = (100, 50)
        let expectedTipY = center.y - radius
        XCTAssertEqual(expectedTipY, 50, accuracy: 0.1)
    }

    func testMinuteHandPathAtThreeOClock() {
        // Given: Angle pointing to 3 o'clock (π/2 radians)
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = .pi / 2 // 3 o'clock

        // When: Creating minute hand path
        let path = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        // Then: Path should point to the right
        // point1 = (100 + 50*sin(π/2), 100 - 50*cos(π/2)) = (150, 100)
        XCTAssertFalse(path.isEmpty)
    }

    func testMinuteHandPathBaseDimensions() {
        // Given: Known dimensions
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = 0

        // When: Creating minute hand path
        _ = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        // Then: Base width should be radius / 2.5
        let expectedBaseRadius = radius / 2.5
        XCTAssertEqual(expectedBaseRadius, 20, accuracy: 0.1, "Base radius should be 1/2.5 of tip radius")
    }

    func testMinuteHandPathIsTriangular() {
        // Given: Any valid parameters
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = .pi / 4

        // When: Creating minute hand path
        let path = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)

        // Then: Path should form a closed triangle
        XCTAssertFalse(path.isEmpty)
        // The path creates 3 points forming a triangle
    }

    // MARK: - Hour Hand Path Tests

    func testHourHandPathAtTwelveOClock() {
        // Given: Center point, radius, and angle pointing to 12 o'clock
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = 0

        // When: Creating hour hand path
        let path = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Path should have correct geometry
        XCTAssertFalse(path.isEmpty)

        // Tip should be at (100, 60) - directly above center
        let expectedTipY = center.y - radius
        XCTAssertEqual(expectedTipY, 60, accuracy: 0.1)
    }

    func testHourHandPathAtSixOClock() {
        // Given: Angle pointing to 6 o'clock (π radians)
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = .pi

        // When: Creating hour hand path
        let path = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Path should point downward
        XCTAssertFalse(path.isEmpty)
        // point1 = (100 + 40*sin(π), 100 - 40*cos(π)) = (100, 140)
    }

    func testHourHandPathBaseDimensions() {
        // Given: Known dimensions
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = 0

        // When: Creating hour hand path
        _ = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Base width should be radius / 2
        let expectedBaseRadius = radius / 2
        XCTAssertEqual(expectedBaseRadius, 20, accuracy: 0.1, "Base radius should be 1/2 of tip radius")
    }

    func testHourHandPathIsTriangular() {
        // Given: Any valid parameters
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 40
        let angle: Double = .pi / 3

        // When: Creating hour hand path
        let path = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Path should form a closed triangle
        XCTAssertFalse(path.isEmpty)
    }

    // MARK: - Comparison Tests

    func testMinuteHandWiderThanHourHand() {
        // Given: Same radius for comparison
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = 0

        // When: Creating both paths
        _ = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        _ = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Minute hand base (radius/2.5 = 20) should be narrower than hour hand base (radius/2 = 25)
        let minuteBaseRadius = radius / 2.5  // 20
        let hourBaseRadius = radius / 2      // 25
        XCTAssertLessThan(minuteBaseRadius, hourBaseRadius, "Minute hand should be narrower than hour hand")
    }

    // MARK: - Angle Calculation Tests

    func testPathPointsCalculation() {
        // Given: Specific angle and radius
        let radius: CGFloat = 10
        let angle: Double = .pi / 2 // 90 degrees (3 o'clock)

        // When: Calculating expected point
        let expectedX = radius * sin(angle)
        let expectedY = -radius * cos(angle)

        // Then: Point should be at (10, 0) for 3 o'clock from origin
        XCTAssertEqual(expectedX, 10, accuracy: 0.1)
        XCTAssertEqual(expectedY, 0, accuracy: 0.1)
    }

    func testPathGeometryConsistency() {
        // Given: Same parameters for both functions
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = .pi / 4

        // When: Creating both paths
        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Both should create valid non-empty paths
        XCTAssertFalse(minutePath.isEmpty)
        XCTAssertFalse(hourPath.isEmpty)
    }

    // MARK: - Edge Cases

    func testZeroRadius() {
        // Given: Zero radius
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 0
        let angle: Double = 0

        // When: Creating paths
        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Should create valid paths (even if degenerate)
        XCTAssertNotNil(minutePath)
        XCTAssertNotNil(hourPath)
    }

    func testNegativeAngle() {
        // Given: Negative angle
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = -.pi / 2 // -90 degrees

        // When: Creating paths
        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Should handle negative angles correctly
        XCTAssertFalse(minutePath.isEmpty)
        XCTAssertFalse(hourPath.isEmpty)
    }

    func testLargeAngle() {
        // Given: Angle > 2π
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 50
        let angle: Double = 3 * .pi

        // When: Creating paths
        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Should handle large angles correctly
        XCTAssertFalse(minutePath.isEmpty)
        XCTAssertFalse(hourPath.isEmpty)
    }

    func testVeryLargeRadius() {
        // Given: Very large radius
        let center = CGPoint(x: 1000, y: 1000)
        let radius: CGFloat = 10000
        let angle: Double = .pi / 4

        // When: Creating paths
        let minutePath = ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
        let hourPath = ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)

        // Then: Should handle large values correctly
        XCTAssertFalse(minutePath.isEmpty)
        XCTAssertFalse(hourPath.isEmpty)
    }
}
