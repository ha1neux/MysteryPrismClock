//
//  MysteryPrismClockView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

#if os(macOS)
import SwiftUI
import Foundation
import AppKit

// Ensure FileLogger and SharedTimerManager are available
// These should be defined in Logger.swift and MysteryPrismScreenSaver.swift

struct MysteryPrismClockView: View {
    @StateObject private var viewModel = ClockViewModel()
    
    // Constants
    private let clockSizeFactor: CGFloat = 2.0
    private let inset: CGFloat = 0.8
    private var insetPrime: CGFloat { (1.0 - inset) / 2 }
    
    // Movement constants
    private let directionChangeInterval: TimeInterval = 15.0
    private let colorChangeInterval: TimeInterval = 30.0
    
    private func calculateClockSize(for geometry: CGSize) -> CGFloat {
        // Use the smaller dimension to ensure the clock fits
        let baseDimension = min(geometry.width, geometry.height)
        let calculatedSize = baseDimension / clockSizeFactor
        
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
                    time: viewModel.currentTime,
                    clockBaseColor: viewModel.clockBaseColor,
                    clockSize: calculateClockSize(for: geometry.size),
                    inset: inset,
                    insetPrime: insetPrime
                )
                .position(viewModel.clockPosition == .zero ? CGPoint(x: geometry.size.width/2, y: geometry.size.height/2) : viewModel.clockPosition)
                
                // Debug information overlay
                if viewModel.showDebugInfo {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(viewModel.debugInfo)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
            .onAppear {
                // Log startup
                FileLogger.shared.logSeparator("VIEW APPEARED")
                FileLogger.shared.info("Clock view appeared - Screen size: \(geometry.size)")
                
                // Register this view model with the shared instance
                SharedTimerManager.shared.currentViewModel = viewModel
                SharedTimerManager.shared.currentTimerManager = nil // Clear old reference
                
                FileLogger.shared.info("Clock view: Registered viewModel[\(ObjectIdentifier(viewModel).hashValue)] with SharedTimerManager")
                
                // Add a small delay to ensure geometry is properly initialized
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak viewModel] in
                    guard let viewModel = viewModel else { 
                        FileLogger.shared.warning("Clock view: viewModel was nil in onAppear delayed block")
                        return 
                    }
                    viewModel.setupInitialClock(screenSize: geometry.size)
                    FileLogger.shared.info("Clock initialized and ready for viewModel[\(ObjectIdentifier(viewModel).hashValue)]")
                }
            }
            .onDisappear {
                // Stop accepting updates immediately and clear references
                FileLogger.shared.logSeparator("VIEW DISAPPEARED")
                FileLogger.shared.info("Clock view disappeared - stopping updates for viewModel[\(ObjectIdentifier(viewModel).hashValue)]")
                
                // First stop the view model from accepting updates
                viewModel.stopUpdating()
                
                // Then immediately clear the shared references so animateOneFrame stops calling it
                FileLogger.shared.info("Clock view: Clearing SharedTimerManager.currentViewModel to prevent further animateOneFrame calls")
                SharedTimerManager.shared.currentViewModel = nil
                SharedTimerManager.shared.currentTimerManager = nil
                
                FileLogger.shared.info("Clock view: Cleared SharedTimerManager references")
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                FileLogger.shared.debug("Screen size changed from \(oldSize) to \(newSize)")
                viewModel.screenSize = newSize
            }
        }
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
            // Clock frame with gray border and filled with clockBaseColor
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
            x: radius * Foundation.sin(angle) / 2.0,
            y: radius * Foundation.cos(angle) / 2.0
        )
        
        Circle()
            .fill(color)
            .frame(width: radius * 2, height: radius * 2)
            .offset(x: offset.x, y: -offset.y) // Flip y for SwiftUI coordinate system
    }
}

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
            radius: clockSize * inset / 2.0,
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
            saturation: Double.random(in: 0.3...0.6),
            brightness: Double.random(in: 0.7...0.9)
        )
    }
    
    var hsb: (hue: Double, saturation: Double, brightness: Double) {
        let nsColor = NSColor(self)
        if let hsb = nsColor.usingColorSpace(.deviceRGB) {
            return (Double(hsb.hueComponent), Double(hsb.saturationComponent), Double(hsb.brightnessComponent))
        }
        
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
    let radius = clockSize * inset / 2.0
    
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
        x: radius * Foundation.sin(angle) / 2.0,
        y: radius * Foundation.cos(angle) / 2.0
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

// Simple file logger for debugging
// Observable object to manage timer lifecycle and state
class ClockViewModel: ObservableObject {
    @Published var currentTime = Date()
    @Published var clockPosition = CGPoint.zero
    @Published var clockBaseColor = Color.random
    @Published var screenSize = CGSize.zero
    @Published var velocity = CGPoint(x: 1.0, y: 0.5)
    @Published var debugInfo: String = "Debug mode active - waiting for data..."
    @Published var showDebugInfo = false
    
    private var lastDirectionChange: Date = Date()
    private var lastColorChange: Date = Date()
    private var lastDebugUpdate: Date = Date()
    private var frameCount: Int = 0
    private var isRunning = false
    
    // Add a counter to detect if we're still being updated after stop
    private var updateCount: Int = 0
    
    private let baseSpeed: CGFloat = 0.16
    private let inset: CGFloat = 0.8
    private let clockSizeFactor: CGFloat = 2.0
    private let directionChangeInterval: TimeInterval = 15.0
    private let colorChangeInterval: TimeInterval = 30.0
    private let colorTransitionDuration: TimeInterval = 2.0
    
    func setupInitialClock(screenSize: CGSize) {
        self.screenSize = screenSize
        clockBaseColor = Color.random
        setupInitialPosition()
        setupInitialVelocity()
        isRunning = true // Start accepting updates
        FileLogger.shared.info("ClockViewModel[\(ObjectIdentifier(self).hashValue)]: Ready to accept updates from animateOneFrame")
    }
    
    // Called from the screensaver's animateOneFrame() method
    func performSingleUpdate() {
        guard isRunning else { return }
        
        updateCount += 1
        frameCount += 1
        let now = Date()
        
        let objectID = ObjectIdentifier(self).hashValue
        
        // Log every 120 frames (every 2 seconds at 60fps) to track activity
        if updateCount % 120 == 0 {
            FileLogger.shared.logTimerActivity(
                source: "ClockViewModel[\(objectID)].performSingleUpdate",
                updateCount: updateCount,
                isRunning: isRunning
            )
        }
        
        // Update time
        currentTime = now
        
        // Update position
        updateClockPosition()
        
        // Update caps lock state
        updateCapsLockState()
        
        // Direction change (every 15 seconds)
        if now.timeIntervalSince(lastDirectionChange) >= directionChangeInterval {
            changeDirection()
            lastDirectionChange = now
        }
        
        // Color change (every 30 seconds) - simple instant change
        if now.timeIntervalSince(lastColorChange) >= colorChangeInterval {
            clockBaseColor = Color.random
            lastColorChange = now
        }
        
        // Debug info (every second, ~60 frames)
        if frameCount % 60 == 0 || now.timeIntervalSince(lastDebugUpdate) >= 1.0 {
            updateDebugInfo()
            lastDebugUpdate = now
        }
    }
    
    // Stop accepting updates
    func stopUpdating() {
        let objectID = ObjectIdentifier(self).hashValue
        FileLogger.shared.logSeparator("STOP UPDATING")
        FileLogger.shared.info("ClockViewModel[\(objectID)]: stopUpdating called - will stop accepting animateOneFrame updates")
        isRunning = false
        FileLogger.shared.info("ClockViewModel[\(objectID)]: Stopped at updateCount=\(updateCount)")
    }
    
    private func setupInitialPosition() {
        guard screenSize != .zero else { return }
        clockPosition = CGPoint(
            x: screenSize.width / 2,
            y: screenSize.height / 2
        )
    }
    
    private func setupInitialVelocity() {
        let angle = Double.random(in: 0...(2 * .pi))
        velocity = CGPoint(
            x: Foundation.cos(angle) * baseSpeed,
            y: Foundation.sin(angle) * baseSpeed
        )
    }
    

    
    private func calculateClockSize(for size: CGSize) -> CGFloat {
        let baseDimension = min(size.width, size.height)
        return baseDimension / clockSizeFactor
    }
    
    private func updateClockPosition() {
        guard screenSize != .zero else { return }
        
        let clockSize = calculateClockSize(for: screenSize)
        let margin = clockSize / 2
        
        var newPosition = CGPoint(
            x: clockPosition.x + velocity.x,
            y: clockPosition.y + velocity.y
        )
        
        if newPosition.x <= margin || newPosition.x >= screenSize.width - margin {
            velocity.x = -velocity.x
            newPosition.x = clockPosition.x + velocity.x
            velocity.y += CGFloat.random(in: -0.2...0.2)
            velocity.y = max(-baseSpeed * 2, min(baseSpeed * 2, velocity.y))
        }
        
        if newPosition.y <= margin || newPosition.y >= screenSize.height - margin {
            velocity.y = -velocity.y
            newPosition.y = clockPosition.y + velocity.y
            velocity.x += CGFloat.random(in: -0.2...0.2)
            velocity.x = max(-baseSpeed * 2, min(baseSpeed * 2, velocity.x))
        }
        
        newPosition.x = max(margin, min(screenSize.width - margin, newPosition.x))
        newPosition.y = max(margin, min(screenSize.height - margin, newPosition.y))
        
        clockPosition = newPosition
    }
    
    private func changeDirection() {
        let angleChange = Double.random(in: -0.5...0.5)
        let currentAngle = atan2(velocity.y, velocity.x)
        let newAngle = currentAngle + angleChange
        let speedVariation = CGFloat.random(in: 0.5...1.5)
        let newSpeed = baseSpeed * speedVariation
        
        velocity = CGPoint(
            x: Foundation.cos(newAngle) * newSpeed,
            y: Foundation.sin(newAngle) * newSpeed
        )
    }
    
    private func updateDebugInfo() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: currentTime)
        let intHours = components.hour ?? 0
        let intMinutes = components.minute ?? 0
        let intSeconds = components.second ?? 0
        
        let timeInterval = currentTime.timeIntervalSince1970
        let fractionalSeconds = timeInterval - floor(timeInterval)
        
        var seconds = Double(intSeconds) + fractionalSeconds
        if seconds >= 60.0 { seconds -= 60.0 }
        
        var minutes = Double(intMinutes) + (seconds / 60.0)
        if minutes >= 60.0 { minutes -= 60.0 }
        
        var hours = Double(intHours) + (minutes / 60.0)
        if hours >= 12.0 { hours -= 12.0 }
        
        let clockSize = calculateClockSize(for: screenSize)
        let angle = (.pi / 6.0) * hours
        let center = CGPoint(x: clockSize / 2, y: clockSize / 2)
        let radius = clockSize * inset / 2.5
        
        let tipPoint = CGPoint(
            x: center.x + radius * Foundation.sin(angle),
            y: center.y - radius * Foundation.cos(angle)
        )
        
        let clockRadius = clockSize * inset / 2
        
        debugInfo = """
        Screen: \(String(format: "%.0f", screenSize.width)) x \(String(format: "%.0f", screenSize.height))
        Time: \(String(format: "%02d", intHours)):\(String(format: "%02d", intMinutes)):\(String(format: "%02d", intSeconds))
        Position: (\(String(format: "%.1f", clockPosition.x)), \(String(format: "%.1f", clockPosition.y)))
        Velocity: (\(String(format: "%.3f", velocity.x)), \(String(format: "%.3f", velocity.y))
        Hour Hand: \(String(format: "%.3f", hours))h, \(String(format: "%.1f", angle * 180 / .pi))°
        Hour hand Tip: (\(String(format: "%.1f", tipPoint.x)), \(String(format: "%.1f", tipPoint.y)))
        Hour hand radius: \(String(format: "%.1f",radius))
        Clock radius: \(String(format: "%.1f", clockRadius))
        """
    }
    
    private func updateCapsLockState() {
        showDebugInfo = NSEvent.modifierFlags.contains(.capsLock)
    }
    
    deinit {
        let objectID = ObjectIdentifier(self).hashValue
        FileLogger.shared.logLifecycle(
            object: "ClockViewModel[\(objectID)]",
            event: "deinit",
            details: "finalUpdateCount=\(updateCount), isRunning=\(isRunning)"
        )
        stopUpdating()
    }
}

// Legacy timer manager for compatibility
class TimerManager: ObservableObject {
    var timers: [Timer] = []
    var isActive = true
    
    func addTimer(_ timer: Timer) {
        timers.append(timer)
    }
    
    func invalidateAll() {
        isActive = false
        for timer in timers {
            timer.invalidate()
        }
        timers.removeAll()
    }
    
    deinit {
        invalidateAll()
    }
}

#Preview {
    MysteryPrismClockView()
}

#endif // os(macOS)
