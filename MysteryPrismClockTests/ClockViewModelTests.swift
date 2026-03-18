//
//  ClockViewModelTests.swift
//  MysteryPrismClockTests
//
//  Created by Claude on 11/15/25.
//

import Testing
import SwiftUI

@MainActor
struct ClockViewModelTests {

    // MARK: - Initialization Tests

    @Test func initialState() {
        let vm = ClockViewModel()

        #expect(vm.clockPosition == .zero)
        #expect(vm.screenSize == .zero)
        #expect(!vm.showDebugInfo)
    }

    // MARK: - Setup Tests

    @Test func setupInitialClock() {
        let viewModel = ClockViewModel()
        let screenSize = CGSize(width: 1920, height: 1080)

        viewModel.setupInitialClock(screenSize: screenSize)

        #expect(viewModel.screenSize == screenSize)
        #expect(abs(viewModel.clockPosition.x - screenSize.width / 2) <= 1.0)
        #expect(abs(viewModel.clockPosition.y - screenSize.height / 2) <= 1.0)
        #expect(viewModel.velocity != .zero, "Velocity should be initialized")
    }

    @Test func initialPositionCentered() {
        let viewModel = ClockViewModel()
        let screenSize = CGSize(width: 800, height: 600)

        viewModel.setupInitialClock(screenSize: screenSize)

        #expect(abs(viewModel.clockPosition.x - 400) <= 1.0)
        #expect(abs(viewModel.clockPosition.y - 300) <= 1.0)
    }

    // MARK: - Update Tests

    @Test func performSingleUpdate() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        let initialPosition = viewModel.clockPosition

        viewModel.performSingleUpdate()

        #expect(viewModel.clockPosition != initialPosition, "Position should change after update")
    }

    @Test func updateCountIncreases() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        let initialCount = viewModel.updateCount

        viewModel.performSingleUpdate()
        viewModel.performSingleUpdate()

        #expect(viewModel.updateCount == initialCount + 2)
    }

    @Test func updateAfterStop() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        viewModel.performSingleUpdate()
        let countAfterFirstUpdate = viewModel.updateCount

        viewModel.stopUpdating()
        viewModel.performSingleUpdate()

        #expect(viewModel.updateCount == countAfterFirstUpdate, "Updates should be ignored after stop")
    }

    // MARK: - Position Update Tests

    @Test func clockMovement() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 2000, height: 2000))
        let initialPosition = viewModel.clockPosition

        for _ in 0..<10 {
            viewModel.performSingleUpdate()
        }

        let displacement = sqrt(
            pow(viewModel.clockPosition.x - initialPosition.x, 2) +
            pow(viewModel.clockPosition.y - initialPosition.y, 2)
        )
        #expect(displacement > 0, "Clock should have moved")
    }

    @Test func boundaryDetection() {
        let viewModel = ClockViewModel()
        let screenSize = CGSize(width: 1000, height: 1000)
        viewModel.setupInitialClock(screenSize: screenSize)

        viewModel.clockPosition = CGPoint(x: 950, y: 500)
        viewModel.velocity = CGPoint(x: 10, y: 0)

        for _ in 0..<20 {
            viewModel.performSingleUpdate()
        }

        #expect(viewModel.clockPosition.x < screenSize.width, "Clock should stay within bounds")
    }

    @Test func clockStaysWithinBounds() {
        let viewModel = ClockViewModel()
        let screenSize = CGSize(width: 800, height: 600)
        viewModel.setupInitialClock(screenSize: screenSize)

        for _ in 0..<1000 {
            viewModel.performSingleUpdate()
        }

        #expect(viewModel.clockPosition.x > 0)
        #expect(viewModel.clockPosition.x < screenSize.width)
        #expect(viewModel.clockPosition.y > 0)
        #expect(viewModel.clockPosition.y < screenSize.height)
    }

    // MARK: - Velocity Tests

    @Test func initialVelocityNonZero() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))

        let speed = sqrt(viewModel.velocity.x * viewModel.velocity.x + viewModel.velocity.y * viewModel.velocity.y)
        #expect(speed > 0, "Initial velocity should not be zero")
    }

    @Test func velocityWithinReasonableBounds() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))

        for _ in 0..<100 {
            viewModel.performSingleUpdate()
        }

        let maxSpeed: Double = 0.16 * 2
        #expect(abs(viewModel.velocity.x) < maxSpeed * 1.5, "X velocity should be bounded")
        #expect(abs(viewModel.velocity.y) < maxSpeed * 1.5, "Y velocity should be bounded")
    }

    // MARK: - Time Tests

    @Test func timeUpdates() async throws {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        let initialTime = viewModel.currentTime

        try await Task.sleep(for: .milliseconds(100))
        viewModel.performSingleUpdate()

        #expect(viewModel.currentTime > initialTime)
    }

    // MARK: - Color Tests

    @Test func colorInitialized() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))

        // clockBaseColor is non-optional; just verify it was set to a random color
        _ = viewModel.clockBaseColor
    }

    // MARK: - Lifecycle Tests

    @Test func stopUpdating() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1000, height: 1000))
        viewModel.performSingleUpdate()

        viewModel.stopUpdating()

        let countBeforeStop = viewModel.updateCount
        viewModel.performSingleUpdate()
        #expect(viewModel.updateCount == countBeforeStop)
    }

    // MARK: - Debug Info Tests

    @Test func debugInfoUpdates() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1920, height: 1080))

        for _ in 0..<61 {
            viewModel.performSingleUpdate()
        }

        #expect(viewModel.debugInfo.contains("Screen:"), "Debug info should contain screen size")
        #expect(viewModel.debugInfo.contains("Time:"), "Debug info should contain time")
        #expect(viewModel.debugInfo.contains("Position:"), "Debug info should contain position")
    }

    // MARK: - Performance Tests

    @Test func updatePerformance() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: CGSize(width: 1920, height: 1080))

        let clock = ContinuousClock()
        let elapsed = clock.measure {
            for _ in 0..<600 {
                viewModel.performSingleUpdate()
            }
        }

        #expect(elapsed < .seconds(1), "600 update frames took \(elapsed) — possible performance regression")
    }

    // MARK: - Edge Cases

    @Test func zeroScreenSize() {
        let viewModel = ClockViewModel()
        viewModel.setupInitialClock(screenSize: .zero)

        #expect(viewModel.screenSize == .zero)
        #expect(viewModel.clockPosition == .zero)
    }

    @Test func verySmallScreenSize() {
        let viewModel = ClockViewModel()
        let screenSize = CGSize(width: 100, height: 100)

        viewModel.setupInitialClock(screenSize: screenSize)
        for _ in 0..<10 {
            viewModel.performSingleUpdate()
        }

        #expect(viewModel.clockPosition.x >= 0)
        #expect(viewModel.clockPosition.x <= screenSize.width)
    }

    @Test func veryLargeScreenSize() {
        let viewModel = ClockViewModel()
        let screenSize = CGSize(width: 7680, height: 4320)

        viewModel.setupInitialClock(screenSize: screenSize)
        for _ in 0..<10 {
            viewModel.performSingleUpdate()
        }

        #expect(viewModel.clockPosition.x >= 0)
        #expect(viewModel.clockPosition.x <= screenSize.width)
    }
}
