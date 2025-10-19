//
//  MysteryPrismClockView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct MysteryPrismClockView: View {
    @State private var currentTime = Date()
    @State private var clockPosition = CGPoint.zero
    @State private var clockBaseColor = Color.random
    @State private var screenSize = CGSize.zero
    
    @State private var timer: Timer?
    @State private var repositionTimer: Timer?
    
    // Constants
    private let clockSizeFactor: CGFloat = 2.0
    private let inset: CGFloat = 0.8
    private let insetPrime: CGFloat = (1.0 - 0.8) / 2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()
                
                // Clock
                ClockView(
                    time: currentTime,
                    clockBaseColor: clockBaseColor,
                    clockSize: geometry.size.height / clockSizeFactor,
                    inset: inset,
                    insetPrime: insetPrime
                )
                .position(clockPosition == .zero ? CGPoint(x: geometry.size.width/2, y: geometry.size.height/2) : clockPosition)
            }
            .onAppear {
                screenSize = geometry.size
                setupInitialClock()
                startTimers()
            }
            .onDisappear {
                stopTimers()
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                screenSize = newSize
                if clockPosition == .zero {
                    repositionClock()
                }
            }
        }
    }
    
    private func setupInitialClock() {
        clockBaseColor = Color.random
        repositionClock()
    }
    
    private func startTimers() {
        timer = Timer.scheduledTimer(withTimeInterval: 1/30.0, repeats: true) { _ in
            Task { @MainActor in
                currentTime = Date()
            }
        }
        
        repositionTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task { @MainActor in
                repositionClock()
            }
        }
    }
    
    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        repositionTimer?.invalidate()
        repositionTimer = nil
    }
    
    private func repositionClock() {
        guard screenSize != .zero else { return }
        
        // Calculate clock size and ensure it stays on screen
        let clockSize = screenSize.height / clockSizeFactor
        let margin = clockSize / 2
        
        // Move clock to a new random position, keeping it fully visible
        clockPosition = CGPoint(
            x: CGFloat.random(in: margin...(screenSize.width - margin)),
            y: CGFloat.random(in: margin...(screenSize.height - margin))
        )
        clockBaseColor = Color.random
    }
}

struct ClockView: View {
    let time: Date
    let clockBaseColor: Color
    let clockSize: CGFloat
    let inset: CGFloat
    let insetPrime: CGFloat
    
    private var timeComponents: (seconds: Double, minutes: Double, hours: Double) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        let intHours = components.hour ?? 0
        let intMinutes = components.minute ?? 0
        let intSeconds = components.second ?? 0
        
        // Get fractional seconds for smooth animation
        let timeInterval = time.timeIntervalSince1970
        let fractionalSeconds = timeInterval - floor(timeInterval)
        
        var seconds = Double(intSeconds) + fractionalSeconds
        if seconds >= 60.0 { seconds -= 60.0 }
        
        var minutes = Double(intMinutes) + (seconds / 60.0)
        if minutes >= 60.0 { minutes -= 60.0 }
        
        var hours = Double(intHours) + (minutes / 60.0)
        if hours >= 12.0 { hours -= 12.0 }
        
        return (seconds, minutes, hours)
    }
    
    private var colors: ClockColors {
        ClockColors(baseColor: clockBaseColor, timeComponents: timeComponents)
    }
        
    var body: some View {
        ZStack {
            // Clock frame with gray border
            RoundedRectangle(cornerRadius: clockSize * insetPrime)
                .fill(clockBaseColor)
                .stroke(Color.gray, lineWidth: clockSize * insetPrime / 6.5)
                .frame(width: clockSize, height: clockSize)
            
            // Clock face
            Circle()
                .fill(colors.sPrimeColor)
                .frame(width: clockSize * inset, height: clockSize * inset)
            
            // Seconds disk
            SecondsDisk(
                timeSeconds: timeComponents.seconds,
                clockSize: clockSize,
                inset: inset,
                color: colors.sColor
            )
            
            // Clock hands
            MinuteHand(
                timeComponents: timeComponents,
                clockSize: clockSize,
                inset: inset,
                colors: colors
            )
            
            HourHand(
                timeComponents: timeComponents,
                clockSize: clockSize,
                inset: inset,
                colors: colors
            )
            
            // Minute-hour overlap
            MinuteHourOverlap(
                timeComponents: timeComponents,
                clockSize: clockSize,
                inset: inset,
                colors: colors
            )
            
            // Minute-hour-seconds overlap
            MinuteHourSecondsOverlap(
                timeComponents: timeComponents,
                clockSize: clockSize,
                inset: inset,
                colors: colors
            )
            
            // Center dot
            Circle()
                .fill(Color.black)
                .frame(width: clockSize / 3.0, height: clockSize / 3.0)
        }
    }
}

struct SecondsDisk: View {
    let timeSeconds: Double
    let clockSize: CGFloat
    let inset: CGFloat
    let color: Color
    
    var body: some View {
        let radius = clockSize * inset / 3.0
        let angle = 2.0 * .pi * timeSeconds / 60.0
        let offset = CGPoint(
            x: radius * sin(angle) / 2.0,
            y: radius * cos(angle) / 2.0
        )
        
        Circle()
            .fill(color)
            .frame(width: radius * 2, height: radius * 2)
            .offset(x: offset.x, y: -offset.y) // Flip y for SwiftUI coordinate system
    }
}

// Function to create minute hand view
func MinuteHand(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat,
    colors: ClockColors
) -> some View {
    MinuteHandView(
        timeComponents: timeComponents,
        clockSize: clockSize,
        inset: inset,
        insideColor: colors.mColor,
        outsideColor: colors.mPrimeColor
    )
}

// Function to create hour hand view
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

// Function to create minute-hour overlap view
func MinuteHourOverlap(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat,
    colors: ClockColors
) -> some View {
    MinuteHourOverlapView(
        timeComponents: timeComponents,
        clockSize: clockSize,
        inset: inset,
        overlapColor: colors.hmColor
    )
}

// Function to create minute-hour-seconds overlap view
func MinuteHourSecondsOverlap(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat,
    colors: ClockColors
) -> some View {
    MinuteHourSecondsOverlapView(
        timeComponents: timeComponents,
        clockSize: clockSize,
        inset: inset,
        overlapColor: colors.hmPrimeColor
    )
}

struct MinuteHandView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: CGFloat
    let inset: CGFloat
    let insideColor: Color
    let outsideColor: Color
    
    var body: some View {
        ZStack {
            // Draw the full minute hand in outsideColor
            minutePath(
                timeComponents: (seconds: 0.0, minutes: timeComponents.minutes, hours: 0.0),
                clockSize: clockSize,
                inset: inset
            )
            .fill(outsideColor)
            
            // Draw the overlapping area with seconds disk in insideColor
            minutePath(
                timeComponents: (seconds: 0.0, minutes: timeComponents.minutes, hours: 0.0),
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

struct MinuteHourOverlapView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: CGFloat
    let inset: CGFloat
    let overlapColor: Color
    
    var body: some View {
        let minuteAngle = (.pi / 30.0) * timeComponents.minutes
        let hourAngle = (.pi / 6.0) * timeComponents.hours
        let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
        
        // Create paths for both hands
        let minutePath = ClockPaths.minuteHandPath(
            center: center,
            radius: max(10, min(200, clockSize * inset / 2.0)),
            angle: minuteAngle
        )
        let hourPath = ClockPaths.hourHandPath(
            center: center,
            radius: clockSize * inset / 2.5,
            angle: hourAngle
        )
        
        // Create intersection using blend mode
        ZStack {
            minutePath
                .fill(overlapColor.opacity(0.0)) // Invisible base
            
            hourPath
                .fill(overlapColor)
                .blendMode(.sourceAtop) // Only show where it overlaps with minute path
                .mask(minutePath) // Mask with minute hand shape
        }
        .frame(width: clockSize, height: clockSize)
    }
}

struct MinuteHourSecondsOverlapView: View {
    let timeComponents: (seconds: Double, minutes: Double, hours: Double)
    let clockSize: CGFloat
    let inset: CGFloat
    let overlapColor: Color
    
    var body: some View {
        // Create paths using the path functions
        let minuteHandPath = minutePath(
            timeComponents: timeComponents,
            clockSize: clockSize,
            inset: inset
        )
        let hourHandPath = hourPath(
            timeComponents: timeComponents,
            clockSize: clockSize,
            inset: inset
        )
        let secondsHandPath = secondsPath(
            timeComponents: timeComponents,
            clockSize: clockSize,
            inset: inset
        )
        
        // Create three-way intersection using multiple masks
        ZStack {
            // Start with minute hand as base (invisible)
            minuteHandPath
                .fill(overlapColor.opacity(0.0))
            
            // Hour hand masked by minute hand
            hourHandPath
                .fill(overlapColor)
                .mask(minuteHandPath)
                .mask(secondsHandPath) // Additionally mask by seconds path for triple intersection
        }
        .frame(width: clockSize, height: clockSize)
    }
}

struct ClockColors {
    let sColor: Color
    let sPrimeColor: Color
    let mColor: Color
    let mPrimeColor: Color
    let hColor: Color
    let hPrimeColor: Color
    let hmColor: Color
    let hmPrimeColor: Color
    
    init(baseColor: Color, timeComponents: (seconds: Double, minutes: Double, hours: Double)) {
        // Convert base color to HSB components
        let baseHSB = baseColor.hsb
        
        // Calculate colors based on time (similar to original logic)
        var hue = baseHSB.hue + timeComponents.seconds / 60.0
        if hue > 1.0 { hue -= 1.0 }
        sColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sColor.hsb.hue - 1.0 / 6.0
        if hue < 0.0 { hue += 1.0 }
        sPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sColor.hsb.hue + timeComponents.minutes / 60.0
        if hue > 1.0 { hue -= 1.0 }
        mColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sPrimeColor.hsb.hue + timeComponents.minutes / 60.0
        if hue > 1.0 { hue -= 1.0 }
        mPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sColor.hsb.hue + timeComponents.hours / 12.0
        if hue > 1.0 { hue -= 1.0 }
        hColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        hue = sPrimeColor.hsb.hue + timeComponents.hours / 12.0
        if hue > 1.0 { hue -= 1.0 }
        hPrimeColor = Color(hue: hue, saturation: baseHSB.saturation, brightness: baseHSB.brightness)
        
        // Overlapped colors (simplified)
        hmColor = mColor
        hmPrimeColor = mPrimeColor
    }
}

// Extensions for color manipulation
extension Color {
    static var random: Color {
        Color(
            hue: Double.random(in: 0...1),
            saturation: 0.9,
            brightness: 0.8
        )
    }
    
    var hsb: (hue: Double, saturation: Double, brightness: Double) {
        // Convert SwiftUI Color to UIColor to extract HSB components
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return (Double(hue), Double(saturation), Double(brightness))
        }
        #elseif canImport(AppKit)
        let nsColor = NSColor(self)
        if let hsb = nsColor.usingColorSpace(.deviceRGB) {
            return (Double(hsb.hueComponent), Double(hsb.saturationComponent), Double(hsb.brightnessComponent))
        }
        #endif
        
        // Fallback values
        return (0.5, 0.9, 0.8)
    }
    

}

// Function to create minute hand path
func minutePath(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat
) -> Path {
    let angle = (.pi / 30.0) * timeComponents.minutes
    let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
    let radius = max(10, min(200, clockSize * inset / 2.0))
    
    return ClockPaths.minuteHandPath(center: center, radius: radius, angle: angle)
}

// Function to create hour hand path
func hourPath(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat
) -> Path {
    let angle = (.pi / 6.0) * timeComponents.hours
    let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
    let radius = clockSize * inset / 2.5
    
    return ClockPaths.hourHandPath(center: center, radius: radius, angle: angle)
}

// Function to create seconds disk path
func secondsPath(
    timeComponents: (seconds: Double, minutes: Double, hours: Double),
    clockSize: CGFloat,
    inset: CGFloat
) -> Path {
    let radius = clockSize * inset / 3.0
    let angle = 2.0 * .pi * timeComponents.seconds / 60.0
    let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
    let offset = CGPoint(
        x: radius * sin(angle) / 2.0,
        y: radius * cos(angle) / 2.0
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

struct ClockPaths {
    static func minuteHandPath(center: CGPoint, radius: CGFloat, angle: Double) -> Path {
        Path { path in
            let radius1 = radius
            let radius2 = radius / 2.5
            
            let point1 = CGPoint(
                x: center.x + radius1 * sin(angle),
                y: center.y - radius1 * cos(angle)
            )
            let point2 = CGPoint(
                x: center.x + radius2 * sin(angle + .pi/2),
                y: center.y - radius2 * cos(angle + .pi/2)
            )
            let point3 = CGPoint(
                x: center.x + radius2 * sin(angle - .pi/2),
                y: center.y - radius2 * cos(angle - .pi/2)
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
                x: center.x + radius1 * sin(angle),
                y: center.y - radius1 * cos(angle)
            )
            let point2 = CGPoint(
                x: center.x + radius2 * sin(angle + .pi/2),
                y: center.y - radius2 * cos(angle + .pi/2)
            )
            let point3 = CGPoint(
                x: center.x + radius2 * sin(angle - .pi/2),
                y: center.y - radius2 * cos(angle - .pi/2)
            )
            
            path.move(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.closeSubpath()
        }
    }
}

#Preview {
    MysteryPrismClockView()
}
