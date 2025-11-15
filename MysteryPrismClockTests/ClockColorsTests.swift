//
//  ClockColorsTests.swift
//  MysteryPrismClockTests
//
//  Created by Claude on 11/15/25.
//

import XCTest
import SwiftUI

final class ClockColorsTests: XCTestCase {

    // MARK: - Basic Color Calculation Tests

    func testColorInitialization() {
        // Given: A base color and time components
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0) // Cyan
        let timeComponents = (seconds: 30.0, minutes: 15.0, hours: 3.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: All color properties should be initialized
        XCTAssertNotNil(colors.sColor)
        XCTAssertNotNil(colors.sPrimeColor)
        XCTAssertNotNil(colors.mColor)
        XCTAssertNotNil(colors.mPrimeColor)
        XCTAssertNotNil(colors.hColor)
        XCTAssertNotNil(colors.hPrimeColor)
        XCTAssertNotNil(colors.hmColor)
        XCTAssertNotNil(colors.hmPrimeColor)
    }

    // MARK: - Seconds Color Tests

    func testSecondsColorCalculation() {
        // Given: Base color at hue 0.5 (cyan) and 30 seconds
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 30.0, minutes: 0.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: sColor hue should be baseHue + (seconds/60)
        // Expected hue: 0.5 + 30/60 = 0.5 + 0.5 = 1.0 (or wraps to 0.0)
        // Both 0.0 and 1.0 represent the same color (red) on the color wheel
        let sColorHSB = colors.sColor.hsb
        XCTAssertTrue(sColorHSB.hue == 0.0 || sColorHSB.hue == 1.0 || abs(sColorHSB.hue - 1.0) < 0.01 || abs(sColorHSB.hue - 0.0) < 0.01,
                      "sColor hue should be 1.0 or wrap to 0.0, got \(sColorHSB.hue)")
        XCTAssertEqual(sColorHSB.saturation, 1.0, accuracy: 0.01)
        XCTAssertEqual(sColorHSB.brightness, 1.0, accuracy: 0.01)
    }

    func testSecondsColorWithoutWrap() {
        // Given: Base color and 15 seconds (should not wrap)
        let baseColor = Color(hue: 0.3, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 15.0, minutes: 0.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: sColor hue should be 0.3 + 15/60 = 0.55
        let sColorHSB = colors.sColor.hsb
        XCTAssertEqual(sColorHSB.hue, 0.55, accuracy: 0.01)
    }

    // MARK: - Prime Color Tests

    func testPrimeColorOffset() {
        // Given: Base color
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: sPrimeColor should be sColor hue - 1/6 (60 degrees)
        // sColor hue = 0.5 + 0 = 0.5
        // sPrimeColor hue = 0.5 - 1/6 = 0.5 - 0.1667 = 0.3333
        let sPrimeHSB = colors.sPrimeColor.hsb
        XCTAssertEqual(sPrimeHSB.hue, 0.3333, accuracy: 0.01)
    }

    func testPrimeColorWrapAround() {
        // Given: Base color that will cause prime to wrap
        let baseColor = Color(hue: 0.1, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: sPrimeColor should wrap around
        // sColor hue = 0.1
        // sPrimeColor hue = 0.1 - 1/6 = -0.0667 -> wraps to 0.9333
        let sPrimeHSB = colors.sPrimeColor.hsb
        XCTAssertEqual(sPrimeHSB.hue, 0.9333, accuracy: 0.01)
    }

    // MARK: - Minutes Color Tests

    func testMinutesColorCalculation() {
        // Given: Base color and 30 minutes
        let baseColor = Color(hue: 0.2, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 30.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: mColor hue should be sColor hue + minutes/60
        // sColor hue = 0.2 + 0 = 0.2
        // mColor hue = 0.2 + 30/60 = 0.2 + 0.5 = 0.7
        let mColorHSB = colors.mColor.hsb
        XCTAssertEqual(mColorHSB.hue, 0.7, accuracy: 0.01)
    }

    func testMinutesPrimeColorCalculation() {
        // Given: Base color and 20 minutes
        let baseColor = Color(hue: 0.3, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 20.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: mPrimeColor should be based on sPrimeColor + minutes/60
        // sColor = 0.3, sPrimeColor = 0.3 - 1/6 = 0.1333
        // mPrimeColor = 0.1333 + 20/60 = 0.1333 + 0.3333 = 0.4666
        let mPrimeHSB = colors.mPrimeColor.hsb
        XCTAssertEqual(mPrimeHSB.hue, 0.4666, accuracy: 0.01)
    }

    // MARK: - Hours Color Tests

    func testHoursColorCalculation() {
        // Given: Base color and 6 hours
        let baseColor = Color(hue: 0.4, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 6.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: hColor hue should be sColor hue + hours/12
        // sColor hue = 0.4
        // hColor hue = 0.4 + 6/12 = 0.4 + 0.5 = 0.9
        let hColorHSB = colors.hColor.hsb
        XCTAssertEqual(hColorHSB.hue, 0.9, accuracy: 0.01)
    }

    func testHoursPrimeColorCalculation() {
        // Given: Base color and 3 hours
        let baseColor = Color(hue: 0.6, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 3.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: hPrimeColor should be based on sPrimeColor + hours/12
        // sColor = 0.6, sPrimeColor = 0.6 - 1/6 = 0.4333
        // hPrimeColor = 0.4333 + 3/12 = 0.4333 + 0.25 = 0.6833
        let hPrimeHSB = colors.hPrimeColor.hsb
        XCTAssertEqual(hPrimeHSB.hue, 0.6833, accuracy: 0.01)
    }

    // MARK: - Overlap Color Tests

    func testOverlapColors() {
        // Given: Any time components
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 10.0, minutes: 25.0, hours: 8.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: Overlap colors should match mColor and mPrimeColor
        let hmColorHSB = colors.hmColor.hsb
        let mColorHSB = colors.mColor.hsb
        XCTAssertEqual(hmColorHSB.hue, mColorHSB.hue, accuracy: 0.001)

        let hmPrimeColorHSB = colors.hmPrimeColor.hsb
        let mPrimeColorHSB = colors.mPrimeColor.hsb
        XCTAssertEqual(hmPrimeColorHSB.hue, mPrimeColorHSB.hue, accuracy: 0.001)
    }

    // MARK: - Complex Scenario Tests

    func testFullTimeComponents() {
        // Given: Complete time (11:45:30)
        let baseColor = Color(hue: 0.0, saturation: 0.8, brightness: 0.9)
        let timeComponents = (seconds: 30.0, minutes: 45.0, hours: 11.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: All colors should be calculated correctly
        // sColor = 0.0 + 30/60 = 0.5
        let sColorHSB = colors.sColor.hsb
        XCTAssertEqual(sColorHSB.hue, 0.5, accuracy: 0.01)

        // mColor = 0.5 + 45/60 = 0.5 + 0.75 = 1.25 -> wraps to 0.25
        let mColorHSB = colors.mColor.hsb
        XCTAssertEqual(mColorHSB.hue, 0.25, accuracy: 0.01)

        // hColor = 0.5 + 11/12 = 0.5 + 0.9167 = 1.4167 -> wraps to 0.4167
        let hColorHSB = colors.hColor.hsb
        XCTAssertEqual(hColorHSB.hue, 0.4167, accuracy: 0.01)
    }

    // MARK: - Saturation and Brightness Preservation Tests

    func testSaturationPreservation() {
        // Given: Base color with specific saturation
        let baseColor = Color(hue: 0.5, saturation: 0.6, brightness: 1.0)
        let timeComponents = (seconds: 15.0, minutes: 30.0, hours: 6.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: All colors should preserve saturation
        XCTAssertEqual(colors.sColor.hsb.saturation, 0.6, accuracy: 0.01)
        XCTAssertEqual(colors.mColor.hsb.saturation, 0.6, accuracy: 0.01)
        XCTAssertEqual(colors.hColor.hsb.saturation, 0.6, accuracy: 0.01)
    }

    func testBrightnessPreservation() {
        // Given: Base color with specific brightness
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 0.7)
        let timeComponents = (seconds: 15.0, minutes: 30.0, hours: 6.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: All colors should preserve brightness
        XCTAssertEqual(colors.sColor.hsb.brightness, 0.7, accuracy: 0.01)
        XCTAssertEqual(colors.mColor.hsb.brightness, 0.7, accuracy: 0.01)
        XCTAssertEqual(colors.hColor.hsb.brightness, 0.7, accuracy: 0.01)
    }

    // MARK: - Edge Cases

    func testMidnightTime() {
        // Given: Midnight (00:00:00)
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 0.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: sColor should match base color
        XCTAssertEqual(colors.sColor.hsb.hue, 0.5, accuracy: 0.01)
    }

    func testAlmostMidnight() {
        // Given: 11:59:59
        let baseColor = Color(hue: 0.0, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 59.0, minutes: 59.0, hours: 11.0)

        // When: Creating ClockColors
        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Then: Should calculate correctly without issues
        XCTAssertNotNil(colors.sColor)
        XCTAssertNotNil(colors.mColor)
        XCTAssertNotNil(colors.hColor)
    }
}
