//
//  MysteryPrismClockView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

import SwiftUI
import Foundation
import AppKit

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
                // Logging state is already set by screensaver init, but check again as backup
                FileLogger.shared.updateLoggingState()
                let capsLockPressed = NSEvent.modifierFlags.contains(.capsLock)
                
                // Log startup (will only log if CapsLock is pressed)
                FileLogger.shared.logSeparator("VIEW APPEARED")
                FileLogger.shared.info("Clock view appeared - Screen size: \(geometry.size)")
                FileLogger.shared.info("CapsLock on launch: \(capsLockPressed ? "PRESSED (logging enabled)" : "not pressed (logging disabled)")")
                
                // Register this view model with the shared instance
                SharedTimerManager.shared.currentViewModel = viewModel
                
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
            
            MinuteHourOverlap(
                timeComponents: timeComponents,
                clockSize: clockSize,
                inset: inset,
                colors: colors
            )
            
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
    
    // Color transition properties
    private var isTransitioningColor = false
    private var colorTransitionStartTime: Date?
    private var oldClockBaseColor = Color.random
    private var targetClockBaseColor = Color.random
    
    // Add a counter to detect if we're still being updated after stop
    var updateCount: Int = 0
    
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
        guard isRunning else { 
            // Not running anymore - clear ourselves from SharedTimerManager if we're still there
            if SharedTimerManager.shared.currentViewModel === self {
                FileLogger.shared.warning("ClockViewModel: performSingleUpdate called when not running - clearing SharedTimerManager")
                SharedTimerManager.shared.currentViewModel = nil
            }
            return 
        }
        
        updateCount += 1
        frameCount += 1
        let now = Date()
        
        let objectID = ObjectIdentifier(self).hashValue
        
        // Safety check: If we've been stopped for a while, something went wrong
        if updateCount > 0 && !isRunning {
            FileLogger.shared.error("ClockViewModel[\(objectID)]: DETECTED UPDATE AFTER STOP! This should not happen.")
            stopUpdating()
            return
        }
        
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
        
        // Color change (every 30 seconds) - start transition
        if now.timeIntervalSince(lastColorChange) >= colorChangeInterval {
            startColorTransition()
            lastColorChange = now
        }
        
        // Update color transition (only every 3 frames = ~20fps for smooth but efficient updates)
        if isTransitioningColor && frameCount % 3 == 0 {
            if let startTime = colorTransitionStartTime {
                let elapsed = now.timeIntervalSince(startTime)
                let progress = min(elapsed / colorTransitionDuration, 1.0)
                
                clockBaseColor = interpolateColor(
                    from: oldClockBaseColor,
                    to: targetClockBaseColor,
                    progress: progress
                )
                
                if progress >= 1.0 {
                    isTransitioningColor = false
                    colorTransitionStartTime = nil
                }
            }
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
        
        // Stop any ongoing color transition
        isTransitioningColor = false
        colorTransitionStartTime = nil
        
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
    
    private func startColorTransition() {
        guard !isTransitioningColor else { return }
        
        oldClockBaseColor = clockBaseColor
        targetClockBaseColor = Color.random
        
        isTransitioningColor = true
        colorTransitionStartTime = Date()
    }
    
    private func interpolateColor(from startColor: Color, to endColor: Color, progress: Double) -> Color {
        let startHSB = startColor.hsb
        let endHSB = endColor.hsb
        
        // Handle hue wrapping for shortest path
        var hueDiff = endHSB.hue - startHSB.hue
        if hueDiff > 0.5 {
            hueDiff -= 1.0
        } else if hueDiff < -0.5 {
            hueDiff += 1.0
        }
        
        var interpolatedHue = startHSB.hue + (hueDiff * progress)
        if interpolatedHue < 0.0 { interpolatedHue += 1.0 }
        if interpolatedHue > 1.0 { interpolatedHue -= 1.0 }
        
        let interpolatedSaturation = startHSB.saturation + (endHSB.saturation - startHSB.saturation) * progress
        let interpolatedBrightness = startHSB.brightness + (endHSB.brightness - startHSB.brightness) * progress
        
        return Color(
            hue: interpolatedHue,
            saturation: interpolatedSaturation,
            brightness: interpolatedBrightness
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

#Preview {
    MysteryPrismClockView()
}
