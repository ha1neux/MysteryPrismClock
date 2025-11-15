//
//  ClockViewModel.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI
import Combine

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

    // Base constants
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
        let speed = baseSpeed
        velocity = CGPoint(
            x: Foundation.cos(angle) * speed,
            y: Foundation.sin(angle) * speed
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
    
    /// Smoothly interpolates between two colors in HSB color space
    ///
    /// This function performs linear interpolation (lerp) for saturation and brightness,
    /// but uses special logic for hue to ensure the shortest path around the color wheel.
    ///
    /// Color Wheel Wrapping Logic:
    /// The hue component represents a circular color wheel (0.0 to 1.0, wrapping around).
    /// When transitioning from one hue to another, there are two possible paths:
    /// - Clockwise path
    /// - Counter-clockwise path
    ///
    /// This function chooses the shorter path to create more natural color transitions.
    ///
    /// Example:
    /// - From hue 0.1 (red) to 0.9 (purple):
    ///   - Direct path: 0.1 -> 0.9 (distance = 0.8, goes through green/blue)
    ///   - Wrapped path: 0.1 -> 0.0 -> 1.0 -> 0.9 (distance = 0.2, stays in red/purple range)
    ///   - We choose the wrapped path (shorter)
    ///
    /// - Parameters:
    ///   - startColor: The initial color
    ///   - endColor: The target color
    ///   - progress: Interpolation progress from 0.0 (startColor) to 1.0 (endColor)
    /// - Returns: Interpolated color at the given progress
    private func interpolateColor(from startColor: Color, to endColor: Color, progress: Double) -> Color {
        let startHSB = startColor.hsb
        let endHSB = endColor.hsb

        // HUE INTERPOLATION with shortest path wrapping
        // Calculate the hue difference (range: -1.0 to 1.0)
        var hueDiff = endHSB.hue - startHSB.hue

        // Adjust for shortest path around the color wheel
        // If difference > 0.5 (more than halfway), wrap backwards (counter-clockwise)
        // Example: 0.9 - 0.1 = 0.8 -> adjust to 0.8 - 1.0 = -0.2 (go backwards instead)
        if hueDiff > 0.5 {
            hueDiff -= 1.0
        }
        // If difference < -0.5 (more than halfway backwards), wrap forwards (clockwise)
        // Example: 0.1 - 0.9 = -0.8 -> adjust to -0.8 + 1.0 = 0.2 (go forwards instead)
        else if hueDiff < -0.5 {
            hueDiff += 1.0
        }

        // Linear interpolation: start + (difference × progress)
        // Example: start=0.1, diff=-0.2, progress=0.5 -> 0.1 + (-0.1) = 0.0
        var interpolatedHue = startHSB.hue + (hueDiff * progress)

        // Normalize hue to [0.0, 1.0] range
        if interpolatedHue < 0.0 { interpolatedHue += 1.0 }
        if interpolatedHue > 1.0 { interpolatedHue -= 1.0 }

        // SATURATION AND BRIGHTNESS: Simple linear interpolation
        // Formula: start + (end - start) × progress
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
        
        // Get version information from the screen saver bundle (not Bundle.main which is the screen saver engine)
        let bundle = Bundle(for: type(of: self))
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        
        debugInfo = """
        Version: \(version) (\(build))
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
