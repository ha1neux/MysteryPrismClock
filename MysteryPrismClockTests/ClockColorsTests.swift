//
//  ClockColorsTests.swift
//  MysteryPrismClockTests
//
//  Created by Claude on 11/15/25.
//

import Testing
import SwiftUI

struct ClockColorsTests {

    // MARK: - Basic Color Calculation Tests

    @Test func colorInitialization() {
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 30.0, minutes: 15.0, hours: 3.0)

        // All color properties are non-optional; just verify construction succeeds
        _ = ClockColors(baseColor: baseColor, timeComponents: timeComponents)
    }

    // MARK: - Seconds Color Tests

    @Test func secondsColorCalculation() {
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 30.0, minutes: 0.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // Expected hue: 0.5 + 30/60 = 1.0 (wraps to 0.0)
        let sColorHSB = colors.sColor.hsb
        #expect(sColorHSB.hue < 0.01 || sColorHSB.hue > 0.99,
                "sColor hue should be 1.0 or wrap to 0.0, got \(sColorHSB.hue)")
        #expect(abs(sColorHSB.saturation - 1.0) <= 0.01)
        #expect(abs(sColorHSB.brightness - 1.0) <= 0.01)
    }

    @Test func secondsColorWithoutWrap() {
        let baseColor = Color(hue: 0.3, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 15.0, minutes: 0.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // sColor hue = 0.3 + 15/60 = 0.55
        let sColorHSB = colors.sColor.hsb
        #expect(abs(sColorHSB.hue - 0.55) <= 0.01)
    }

    // MARK: - Prime Color Tests

    @Test func primeColorOffset() {
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // sPrimeColor hue = 0.5 - 1/6 = 0.3333
        let sPrimeHSB = colors.sPrimeColor.hsb
        #expect(abs(sPrimeHSB.hue - 0.3333) <= 0.01)
    }

    @Test func primeColorWrapAround() {
        let baseColor = Color(hue: 0.1, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // sPrimeColor hue = 0.1 - 1/6 = -0.0667 -> wraps to 0.9333
        let sPrimeHSB = colors.sPrimeColor.hsb
        #expect(abs(sPrimeHSB.hue - 0.9333) <= 0.01)
    }

    // MARK: - Minutes Color Tests

    @Test func minutesColorCalculation() {
        let baseColor = Color(hue: 0.2, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 30.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // mColor hue = 0.2 + 30/60 = 0.7
        let mColorHSB = colors.mColor.hsb
        #expect(abs(mColorHSB.hue - 0.7) <= 0.01)
    }

    @Test func minutesPrimeColorCalculation() {
        let baseColor = Color(hue: 0.3, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 20.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // mPrimeColor = 0.1333 + 20/60 = 0.4666
        let mPrimeHSB = colors.mPrimeColor.hsb
        #expect(abs(mPrimeHSB.hue - 0.4666) <= 0.01)
    }

    // MARK: - Hours Color Tests

    @Test func hoursColorCalculation() {
        let baseColor = Color(hue: 0.4, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 6.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // hColor hue = 0.4 + 6/12 = 0.9
        let hColorHSB = colors.hColor.hsb
        #expect(abs(hColorHSB.hue - 0.9) <= 0.01)
    }

    @Test func hoursPrimeColorCalculation() {
        let baseColor = Color(hue: 0.6, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 3.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // hPrimeColor = 0.4333 + 3/12 = 0.6833
        let hPrimeHSB = colors.hPrimeColor.hsb
        #expect(abs(hPrimeHSB.hue - 0.6833) <= 0.01)
    }

    // MARK: - Overlap Color Tests

    @Test func overlapColors() {
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 10.0, minutes: 25.0, hours: 8.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        let hmColorHSB = colors.hmColor.hsb
        let mColorHSB = colors.mColor.hsb
        #expect(abs(hmColorHSB.hue - mColorHSB.hue) <= 0.001)

        let hmPrimeColorHSB = colors.hmPrimeColor.hsb
        let mPrimeColorHSB = colors.mPrimeColor.hsb
        #expect(abs(hmPrimeColorHSB.hue - mPrimeColorHSB.hue) <= 0.001)
    }

    // MARK: - Complex Scenario Tests

    @Test func fullTimeComponents() {
        let baseColor = Color(hue: 0.0, saturation: 0.8, brightness: 0.9)
        let timeComponents = (seconds: 30.0, minutes: 45.0, hours: 11.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        // sColor = 0.0 + 30/60 = 0.5
        let sColorHSB = colors.sColor.hsb
        #expect(abs(sColorHSB.hue - 0.5) <= 0.01)

        // mColor = 0.5 + 45/60 = 1.25 -> wraps to 0.25
        let mColorHSB = colors.mColor.hsb
        #expect(abs(mColorHSB.hue - 0.25) <= 0.01)

        // hColor = 0.5 + 11/12 = 1.4167 -> wraps to 0.4167
        let hColorHSB = colors.hColor.hsb
        #expect(abs(hColorHSB.hue - 0.4167) <= 0.01)
    }

    // MARK: - Saturation and Brightness Preservation Tests

    @Test func saturationPreservation() {
        let baseColor = Color(hue: 0.5, saturation: 0.6, brightness: 1.0)
        let timeComponents = (seconds: 15.0, minutes: 30.0, hours: 6.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        #expect(abs(colors.sColor.hsb.saturation - 0.6) <= 0.01)
        #expect(abs(colors.mColor.hsb.saturation - 0.6) <= 0.01)
        #expect(abs(colors.hColor.hsb.saturation - 0.6) <= 0.01)
    }

    @Test func brightnessPreservation() {
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 0.7)
        let timeComponents = (seconds: 15.0, minutes: 30.0, hours: 6.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        #expect(abs(colors.sColor.hsb.brightness - 0.7) <= 0.01)
        #expect(abs(colors.mColor.hsb.brightness - 0.7) <= 0.01)
        #expect(abs(colors.hColor.hsb.brightness - 0.7) <= 0.01)
    }

    // MARK: - Edge Cases

    @Test func midnightTime() {
        let baseColor = Color(hue: 0.5, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 0.0, minutes: 0.0, hours: 0.0)

        let colors = ClockColors(baseColor: baseColor, timeComponents: timeComponents)

        #expect(abs(colors.sColor.hsb.hue - 0.5) <= 0.01)
    }

    @Test func almostMidnight() {
        let baseColor = Color(hue: 0.0, saturation: 1.0, brightness: 1.0)
        let timeComponents = (seconds: 59.0, minutes: 59.0, hours: 11.0)

        // Should calculate without issues
        _ = ClockColors(baseColor: baseColor, timeComponents: timeComponents)
    }
}
