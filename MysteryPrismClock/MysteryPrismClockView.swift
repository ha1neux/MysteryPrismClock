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
    @State private var movementTimer: Timer?
    
    // Movement properties for smooth sliding
    @State private var velocity = CGPoint(x: 1.0, y: 0.5)
    @State private var targetPosition = CGPoint.zero
    @State private var isMoving = false
    
    // Constants
    private let clockSizeFactor: CGFloat = 2.0
    private let minClockSize: CGFloat = 200.0
    private let maxClockSize: CGFloat = 600.0
    private let inset: CGFloat = 0.8
    private var insetPrime: CGFloat { (1.0 - inset) / 2 }
    
    // Movement constants
    private let baseSpeed: CGFloat = 0.16 // Base movement speed (pixels per frame) - 1/5th of original
    private let directionChangeInterval: TimeInterval = 15.0 // Change direction every 15 seconds
    private let colorChangeInterval: TimeInterval = 30.0 // Change color every 30 seconds
    
    private func calculateClockSize(for geometry: CGSize) -> CGFloat {
        // Use the smaller dimension to ensure the clock fits
        let baseDimension = min(geometry.width, geometry.height)
        let calculatedSize = baseDimension / clockSizeFactor
        
        // Clamp the size to reasonable bounds
//        return max(minClockSize, min(maxClockSize, calculatedSize))
        return calculatedSize
    }
    
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
                    clockSize: calculateClockSize(for: geometry.size),
                    inset: inset,
                    insetPrime: insetPrime
                )
                .position(clockPosition == .zero ? CGPoint(x: geometry.size.width/2, y: geometry.size.height/2) : clockPosition)
                .animation(.linear(duration: 1/60.0), value: clockPosition) // Smooth animation for position changes
            }
            .onAppear {
                // Add a small delay to ensure geometry is properly initialized
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    screenSize = geometry.size
                    setupInitialClock()
                    startTimers()
                }
            }
            .onDisappear {
                stopTimers()
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                screenSize = newSize
                if clockPosition == .zero {
                    setupInitialPosition()
                }
                updateBoundaries()
            }
        }
    }
    
    private func setupInitialClock() {
        clockBaseColor = Color.random
        setupInitialPosition()
        setupInitialVelocity()
    }
    
    private func setupInitialPosition() {
        guard screenSize != .zero else { return }
        
        // Start at center of screen
        clockPosition = CGPoint(
            x: screenSize.width / 2,
            y: screenSize.height / 2
        )
    }
    
    private func setupInitialVelocity() {
        // Random initial direction
        let angle = Double.random(in: 0...(2 * .pi))
        velocity = CGPoint(
            x: cos(angle) * baseSpeed,
            y: sin(angle) * baseSpeed
        )
    }
    
    private func startTimers() {
        // Timer for updating the clock time (30 FPS)
        timer = Timer.scheduledTimer(withTimeInterval: 1/30.0, repeats: true) { _ in
            Task { @MainActor in
                currentTime = Date()
            }
        }
        
        // Timer for smooth movement (60 FPS)
        movementTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { _ in
            Task { @MainActor in
                updateClockPosition()
            }
        }
        
        // Timer for periodic direction changes
        Timer.scheduledTimer(withTimeInterval: directionChangeInterval, repeats: true) { _ in
            Task { @MainActor in
                changeDirection()
            }
        }
        
        // Timer for periodic color changes
        Timer.scheduledTimer(withTimeInterval: colorChangeInterval, repeats: true) { _ in
            Task { @MainActor in
                changeColor()
            }
        }
    }
    
    private func stopTimers() {
        timer?.invalidate()
        timer = nil
        movementTimer?.invalidate()
        movementTimer = nil
    }
    
    private func updateClockPosition() {
        guard screenSize != .zero else { return }
        
        let clockSize = calculateClockSize(for: screenSize)
        let margin = clockSize / 2
        
        // Calculate next position
        var newPosition = CGPoint(
            x: clockPosition.x + velocity.x,
            y: clockPosition.y + velocity.y
        )
        
        // Bounce off edges
        if newPosition.x <= margin || newPosition.x >= screenSize.width - margin {
            velocity.x = -velocity.x
            newPosition.x = clockPosition.x + velocity.x
            
            // Add some randomness to prevent predictable bouncing
            velocity.y += CGFloat.random(in: -0.2...0.2)
            velocity.y = max(-baseSpeed * 2, min(baseSpeed * 2, velocity.y))
        }
        
        if newPosition.y <= margin || newPosition.y >= screenSize.height - margin {
            velocity.y = -velocity.y
            newPosition.y = clockPosition.y + velocity.y
            
            // Add some randomness to prevent predictable bouncing
            velocity.x += CGFloat.random(in: -0.2...0.2)
            velocity.x = max(-baseSpeed * 2, min(baseSpeed * 2, velocity.x))
        }
        
        // Ensure position stays within bounds
        newPosition.x = max(margin, min(screenSize.width - margin, newPosition.x))
        newPosition.y = max(margin, min(screenSize.height - margin, newPosition.y))
        
        clockPosition = newPosition
    }
    
    private func changeDirection() {
        // Slightly adjust direction for more organic movement
        let angleChange = Double.random(in: -0.5...0.5) // Radians
        let currentAngle = atan2(velocity.y, velocity.x)
        let newAngle = currentAngle + angleChange
        
        // Vary speed slightly
        let speedVariation = CGFloat.random(in: 0.5...1.5)
        let newSpeed = baseSpeed * speedVariation
        
        velocity = CGPoint(
            x: cos(newAngle) * newSpeed,
            y: sin(newAngle) * newSpeed
        )
    }
    
    private func changeColor() {
        withAnimation(.easeInOut(duration: 2.0)) {
            clockBaseColor = Color.random
        }
    }
    
    private func updateBoundaries() {
        // Ensure clock stays within new bounds if screen size changes
        guard screenSize != .zero else { return }
        
        let clockSize = calculateClockSize(for: screenSize)
        let margin = clockSize / 2
        
        clockPosition.x = max(margin, min(screenSize.width - margin, clockPosition.x))
        clockPosition.y = max(margin, min(screenSize.height - margin, clockPosition.y))
    }
    
    // Legacy function kept for backward compatibility but simplified
    private func repositionClock() {
        setupInitialPosition()
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
