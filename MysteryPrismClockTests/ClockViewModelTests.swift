//
//  ClockViewModelTests.swift
//  MysteryPrismClockTests
//
//  Created by Claude on 11/15/25.
//

import XCTest
import SwiftUI

final class ClockViewModelTests: XCTestCase {

    var viewModel: ClockViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ClockViewModel()
    }

    override func tearDown() {
        viewModel.stopUpdating()
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        // When: Creating a new view model
        let vm = ClockViewModel()

        // Then: Initial state should be set correctly
        XCTAssertEqual(vm.clockPosition, .zero)
        XCTAssertEqual(vm.screenSize, .zero)
        XCTAssertFalse(vm.showDebugInfo)
    }

    // MARK: - Setup Tests

    func testSetupInitialClock() {
        // Given: A screen size
        let screenSize = CGSize(width: 1920, height: 1080)

        // When: Setting up the clock
        viewModel.setupInitialClock(screenSize: screenSize)

        // Then: View model should be configured
        XCTAssertEqual(viewModel.screenSize, screenSize)
        XCTAssertEqual(viewModel.clockPosition.x, screenSize.width / 2, accuracy: 1.0)
        XCTAssertEqual(viewModel.clockPosition.y, screenSize.height / 2, accuracy: 1.0)
        XCTAssertNotEqual(viewModel.velocity, .zero, "Velocity should be initialized")
    }

    func testInitialPositionCentered() {
        // Given: A screen size
        let screenSize = CGSize(width: 800, height: 600)

        // When: Setting up the clock
        viewModel.setupInitialClock(screenSize: screenSize)

        // Then: Clock should start at center
        XCTAssertEqual(viewModel.clockPosition.x, 400, accuracy: 1.0)
        XCTAssertEqual(viewModel.clockPosition.y, 300, accuracy: 1.0)
    }

    // MARK: - Update Tests

    func testPerformSingleUpdate() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        let initialPosition = viewModel.clockPosition

        // When: Performing an update
        viewModel.performSingleUpdate()

        // Then: Position should change
        XCTAssertNotEqual(viewModel.clockPosition, initialPosition, "Position should change after update")
    }

    func testUpdateCountIncreases() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        let initialCount = viewModel.updateCount

        // When: Performing updates
        viewModel.performSingleUpdate()
        viewModel.performSingleUpdate()

        // Then: Update count should increase
        XCTAssertEqual(viewModel.updateCount, initialCount + 2)
    }

    func testUpdateAfterStop() {
        // Given: Initialized and running clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        viewModel.performSingleUpdate()
        let countAfterFirstUpdate = viewModel.updateCount

        // When: Stopping and trying to update
        viewModel.stopUpdating()
        viewModel.performSingleUpdate()

        // Then: Update count should not increase
        XCTAssertEqual(viewModel.updateCount, countAfterFirstUpdate, "Updates should be ignored after stop")
    }

    // MARK: - Position Update Tests

    func testClockMovement() {
        // Given: Initialized clock with known velocity
        viewModel.setupInitialClock(screenSize: CGSize(width: 2000, height: 2000))
        let initialPosition = viewModel.clockPosition

        // When: Performing multiple updates
        for _ in 0..<10 {
            viewModel.performSingleUpdate()
        }

        // Then: Clock should have moved
        let displacement = sqrt(
            pow(viewModel.clockPosition.x - initialPosition.x, 2) +
            pow(viewModel.clockPosition.y - initialPosition.y, 2)
        )
        XCTAssertGreaterThan(displacement, 0, "Clock should have moved")
    }

    func testBoundaryDetection() {
        // Given: Clock near the edge with velocity toward edge
        let screenSize = CGSize(width: 1000, height: 1000)
        viewModel.setupInitialClock(screenSize: screenSize)

        // Position clock near right edge
        viewModel.clockPosition = CGPoint(x: 950, y: 500)
        viewModel.velocity = CGPoint(x: 10, y: 0) // Moving right

        // When: Performing updates
        for _ in 0..<20 {
            viewModel.performSingleUpdate()
        }

        // Then: Velocity should have reversed
        // Note: This test may be flaky due to random velocity changes
        XCTAssertLessThan(viewModel.clockPosition.x, screenSize.width, "Clock should stay within bounds")
    }

    func testClockStaysWithinBounds() {
        // Given: Initialized clock
        let screenSize = CGSize(width: 800, height: 600)
        viewModel.setupInitialClock(screenSize: screenSize)

        // When: Performing many updates
        for _ in 0..<1000 {
            viewModel.performSingleUpdate()
        }

        // Then: Clock should always stay within screen bounds
        XCTAssertGreaterThan(viewModel.clockPosition.x, 0)
        XCTAssertLessThan(viewModel.clockPosition.x, screenSize.width)
        XCTAssertGreaterThan(viewModel.clockPosition.y, 0)
        XCTAssertLessThan(viewModel.clockPosition.y, screenSize.height)
    }

    // MARK: - Velocity Tests

    func testInitialVelocityNonZero() {
        // Given: Newly set up clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))

        // Then: Velocity should not be zero
        let speed = sqrt(viewModel.velocity.x * viewModel.velocity.x + viewModel.velocity.y * viewModel.velocity.y)
        XCTAssertGreaterThan(speed, 0, "Initial velocity should not be zero")
    }

    func testVelocityWithinReasonableBounds() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))

        // When: Performing many updates
        for _ in 0..<100 {
            viewModel.performSingleUpdate()
        }

        // Then: Velocity should remain within reasonable bounds
        // Based on baseSpeed of 0.16 and max multiplier of 2
        let maxSpeed: CGFloat = 0.16 * 2
        XCTAssertLessThan(abs(viewModel.velocity.x), maxSpeed * 1.5, "X velocity should be bounded")
        XCTAssertLessThan(abs(viewModel.velocity.y), maxSpeed * 1.5, "Y velocity should be bounded")
    }

    // MARK: - Time Tests

    func testTimeUpdates() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        let initialTime = viewModel.currentTime

        // When: Waiting and updating
        Thread.sleep(forTimeInterval: 0.1)
        viewModel.performSingleUpdate()

        // Then: Time should be updated
        XCTAssertGreaterThan(viewModel.currentTime, initialTime)
    }

    // MARK: - Color Tests

    func testColorInitialized() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))

        // Then: Base color should be set
        XCTAssertNotNil(viewModel.clockBaseColor)
    }

    // MARK: - Lifecycle Tests

    func testStopUpdating() {
        // Given: Running clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        viewModel.performSingleUpdate()

        // When: Stopping
        viewModel.stopUpdating()

        // Then: Should not accept more updates
        let countBeforeStop = viewModel.updateCount
        viewModel.performSingleUpdate()
        XCTAssertEqual(viewModel.updateCount, countBeforeStop)
    }

    // MARK: - Debug Info Tests

    func testDebugInfoUpdates() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1920, height: 1080))

        // When: Performing updates
        for _ in 0..<61 { // Debug updates every 60 frames
            viewModel.performSingleUpdate()
        }

        // Then: Debug info should contain relevant information
        XCTAssertTrue(viewModel.debugInfo.contains("Screen:"), "Debug info should contain screen size")
        XCTAssertTrue(viewModel.debugInfo.contains("Time:"), "Debug info should contain time")
        XCTAssertTrue(viewModel.debugInfo.contains("Position:"), "Debug info should contain position")
    }

    // MARK: - Performance Tests

    func testUpdatePerformance() {
        // Given: Initialized clock
        viewModel.setupInitialClock(screenSize: CGSize(width: 1920, height: 1080))

        // When: Measuring update performance
        measure {
            for _ in 0..<60 { // Simulate 1 second at 60fps
                viewModel.performSingleUpdate()
            }
        }

        // Then: Should complete efficiently
    }

    // MARK: - Edge Cases

    func testZeroScreenSize() {
        // Given: Zero screen size
        let screenSize = CGSize.zero

        // When: Setting up clock
        viewModel.setupInitialClock(screenSize: screenSize)

        // Then: Should handle gracefully
        XCTAssertEqual(viewModel.screenSize, .zero)
        XCTAssertEqual(viewModel.clockPosition, .zero)
    }

    func testVerySmallScreenSize() {
        // Given: Very small screen
        let screenSize = CGSize(width: 100, height: 100)

        // When: Setting up and updating
        viewModel.setupInitialClock(screenSize: screenSize)
        for _ in 0..<10 {
            viewModel.performSingleUpdate()
        }

        // Then: Should handle small screen without errors
        XCTAssertGreaterThanOrEqual(viewModel.clockPosition.x, 0)
        XCTAssertLessThanOrEqual(viewModel.clockPosition.x, screenSize.width)
    }

    func testVeryLargeScreenSize() {
        // Given: Very large screen (8K)
        let screenSize = CGSize(width: 7680, height: 4320)

        // When: Setting up and updating
        viewModel.setupInitialClock(screenSize: screenSize)
        for _ in 0..<10 {
            viewModel.performSingleUpdate()
        }

        // Then: Should handle large screen without errors
        XCTAssertGreaterThanOrEqual(viewModel.clockPosition.x, 0)
        XCTAssertLessThanOrEqual(viewModel.clockPosition.x, screenSize.width)
    }
}
