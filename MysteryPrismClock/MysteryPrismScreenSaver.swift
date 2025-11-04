//
//  MysteryPrismScreenSaver.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

import ScreenSaver
import SwiftUI

// Shared timer manager that can be accessed from the screensaver wrapper
public class SharedTimerManager {
    public static let shared = SharedTimerManager()
    
    weak var currentTimerManager: TimerManager? {
        didSet {
            if currentTimerManager != nil {
                FileLogger.shared.info("SharedTimerManager: currentTimerManager SET (not nil)")
            } else {
                FileLogger.shared.info("SharedTimerManager: currentTimerManager CLEARED (nil)")
            }
        }
    }
    
    weak var currentViewModel: ClockViewModel? {
        didSet {
            if let vm = currentViewModel {
                FileLogger.shared.info("SharedTimerManager: currentViewModel SET to [\(ObjectIdentifier(vm).hashValue)]")
            } else {
                FileLogger.shared.info("SharedTimerManager: currentViewModel CLEARED (nil)")
            }
        }
    }
    
    private init() {
        FileLogger.shared.info("SharedTimerManager: Singleton initialized")
    }
}

class MysteryPrismScreenSaver: ScreenSaverView {
    private var hostingView: NSHostingView<MysteryPrismClockView>!
    private weak var viewModel: ClockViewModel?
    private let instanceID: Int
    private static var instanceCounter = 0
    private var hasStarted = false
    private var hasCleanedUp = false
    private var isStopped = false  // Flag to prevent any updates after stop
    private var hasBeenVisible = false  // Track if window has ever been visible
    private var orphanDetectionTimer: Timer?  // Timer to detect if we're orphaned
    
    override init?(frame: NSRect, isPreview: Bool) {
        Self.instanceCounter += 1
        instanceID = Self.instanceCounter
        super.init(frame: frame, isPreview: isPreview)
        
        // Update logging state based on current CapsLock state
        FileLogger.shared.updateLoggingState()
        let capsLockPressed = NSEvent.modifierFlags.contains(.capsLock)
        
        // Set animation time interval to 60 FPS
        animationTimeInterval = 1.0 / 60.0
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "init",
            details: "isPreview=\(isPreview), frame=\(frame), CapsLock=\(capsLockPressed ? "ENABLED" : "disabled")"
        )
        setupView()
    }
    
    required init?(coder: NSCoder) {
        Self.instanceCounter += 1
        instanceID = Self.instanceCounter
        super.init(coder: coder)
        
        // Update logging state based on current CapsLock state
        FileLogger.shared.updateLoggingState()
        let capsLockPressed = NSEvent.modifierFlags.contains(.capsLock)
        
        // Set animation time interval to 60 FPS
        animationTimeInterval = 1.0 / 60.0
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "init(coder)",
            details: "Initialized from coder, CapsLock=\(capsLockPressed ? "ENABLED" : "disabled")"
        )
        setupView()
    }
    
    private func setupView() {
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "setupView",
            details: "Creating clock view and hosting view"
        )
        let clockView = MysteryPrismClockView()
        hostingView = NSHostingView(rootView: clockView)
        hostingView.frame = bounds
        hostingView.autoresizingMask = [.width, .height]
        addSubview(hostingView)
        
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: Added hosting view to subview hierarchy")
        
        // Store a weak reference to the view model for cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.viewModel = SharedTimerManager.shared.currentViewModel
            if let vm = self.viewModel {
                FileLogger.shared.info("ScreenSaver[\(self.instanceID)]: Stored reference to viewModel[\(ObjectIdentifier(vm).hashValue)]")
            } else {
                FileLogger.shared.warning("ScreenSaver[\(self.instanceID)]: viewModel was nil when trying to store reference")
            }
        }
    }
    
    override func startAnimation() {
        super.startAnimation()
        hasStarted = true
        
        // Re-check Caps Lock state when animation starts (in case it changed since init)
        FileLogger.shared.updateLoggingState()
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "startAnimation",
            details: "Called by system - animation will be driven by animateOneFrame()"
        )
        
        // Start orphan detection - if we don't receive any animateOneFrame calls within 2 seconds,
        // or if our window never becomes visible, we're probably an orphaned instance
        startOrphanDetection()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        
        // Cancel orphan detection since we're stopping normally
        cancelOrphanDetection()
        
        // IMMEDIATELY set flag to stop all updates
        isStopped = true
        
        FileLogger.shared.logSeparator("SCREENSAVER DISMISSED BY USER")
        FileLogger.shared.info("🛑 User dismissed the screensaver (stopAnimation called)")
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "stopAnimation called",
            details: "Thread: \(Thread.isMainThread ? "main" : "background"), isStopped=\(isStopped)"
        )
        
        performCleanup(reason: "stopAnimation")
    }
    
    private func performCleanup(reason: String) {
        // Prevent multiple cleanups
        guard !hasCleanedUp else {
            FileLogger.shared.warning("ScreenSaver[\(instanceID)]: performCleanup called again (reason: \(reason)) but already cleaned up - ignoring")
            return
        }
        
        // Cancel orphan detection timer if it's running
        cancelOrphanDetection()
        
        hasCleanedUp = true
        FileLogger.shared.logSeparator("CLEANUP STARTED")
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: performCleanup called - reason: \(reason)")
        
        // Tell the view model to stop updating FIRST
        if let vm = SharedTimerManager.shared.currentViewModel {
            FileLogger.shared.info("ScreenSaver[\(instanceID)]: Calling stopUpdating on viewModel[\(ObjectIdentifier(vm).hashValue)] due to \(reason)")
            vm.stopUpdating()
        } else {
            FileLogger.shared.warning("ScreenSaver[\(instanceID)]: No currentViewModel to stop")
        }
        
        // Clear references BEFORE removing view to prevent any last-minute updates
        let viewModel = SharedTimerManager.shared.currentViewModel
        let viewModelID = viewModel.map { ObjectIdentifier($0).hashValue }
        
        SharedTimerManager.shared.currentViewModel = nil
        SharedTimerManager.shared.currentTimerManager = nil
        
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: Cleared SharedTimerManager references (viewModel was \(viewModelID.map { String($0) } ?? "nil"))")
        
        // Aggressively clean up the hosting view
        if let hostView = hostingView {
            FileLogger.shared.info("ScreenSaver[\(instanceID)]: Removing hosting view from superview")
            
            // Remove from superview
            hostView.removeFromSuperview()
            
            // Set to nil to release it
            hostingView = nil
            
            FileLogger.shared.info("ScreenSaver[\(instanceID)]: Hosting view removed and deallocated")
        } else {
            FileLogger.shared.warning("ScreenSaver[\(instanceID)]: No hosting view to remove")
        }
        
        // Clear all subviews just to be sure
        let subviewCount = subviews.count
        for subview in subviews {
            subview.removeFromSuperview()
        }
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: Removed \(subviewCount) subviews")
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "cleanup complete",
            details: "hostingView removed and nil'd, all subviews cleared"
        )
        FileLogger.shared.logSeparator("CLEANUP COMPLETE")
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: CPU usage should now drop to 0%")
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: Waiting for post-dismissal checks in 5s and 10s...")
        
        // Check 5 seconds later if there's still CPU usage
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [instanceID] in
            FileLogger.shared.logSeparator("POST-DISMISSAL CHECK (5s)")
            FileLogger.shared.info("⏰ ScreenSaver[\(instanceID)]: 5 seconds after dismissal")
            FileLogger.shared.info("📊 Check Activity Monitor for CPU usage - should be near 0%")
        }
        
        // Check 10 seconds later too
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [instanceID] in
            FileLogger.shared.logSeparator("POST-DISMISSAL CHECK (10s)")
            FileLogger.shared.info("⏰ ScreenSaver[\(instanceID)]: 10 seconds after dismissal - FINAL CHECK")
        }
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        if window == nil {
            // View was removed from window - screen saver dismissed
            FileLogger.shared.info("ScreenSaver[\(instanceID)]: viewDidMoveToWindow called with nil window - dismissed")
            if !isStopped && !hasCleanedUp {
                isStopped = true
                performCleanup(reason: "viewDidMoveToWindow-nil")
            }
        } else {
            FileLogger.shared.info("ScreenSaver[\(instanceID)]: viewDidMoveToWindow called with window: \(window!)")
        }
    }
    
    override func animateOneFrame() {
        // This is called by the system at the interval specified in animationTimeInterval
        
        // Mark that we've received at least one frame (not orphaned)
        if !hasBeenVisible {
            hasBeenVisible = true
            cancelOrphanDetection()  // Cancel the orphan timer since we're active
        }
        
        // FIRST CHECK: Have we explicitly stopped?
        guard !isStopped else {
            // Completely stopped - don't do anything
            return
        }
        
        // SECOND CHECK: Have we cleaned up?
        guard !hasCleanedUp else {
            // Don't update after cleanup
            return 
        }
        
        // THIRD CHECK: Are we hidden? (but only check for NON-preview instances)
        // Preview instances can be hidden when the full-screen saver starts, which is normal
        if !isPreview && (isHidden || isHiddenOrHasHiddenAncestor) {
            FileLogger.shared.info("ScreenSaver[\(instanceID)]: View is hidden - dismissed")
            isStopped = true
            performCleanup(reason: "view-hidden")
            return
        }
        
        // FOURTH CHECK: Detect dismissal by window level change
        // Screen savers use window level -2147483625, normal windows use 0
        // When dismissed, the window level changes to 0 even though nothing else changes
        if let win = window {
            if !isPreview && win.level.rawValue == 0 {
                FileLogger.shared.info("ScreenSaver[\(instanceID)]: Window level changed to 0 (normal window level) - dismissed")
                isStopped = true
                performCleanup(reason: "window-level-changed")
                return
            }
            
            // Log window state periodically for debugging
            if let vm = SharedTimerManager.shared.currentViewModel, vm.updateCount % 120 == 0 {
                FileLogger.shared.info("ScreenSaver[\(instanceID)]: Window state - isVisible:\(win.isVisible), alpha:\(win.alphaValue), level:\(win.level.rawValue), isOnScreen:\(win.isOnActiveSpace), viewHidden:\(isHidden), isPreview:\(isPreview)")
            }
        }
        
        // Update the view model ONLY if it belongs to this instance
        if let vm = SharedTimerManager.shared.currentViewModel {
            // Only update if this is OUR view model
            if vm === viewModel {
                vm.performSingleUpdate()
            } else {
                // This can happen during transitions between preview and full-screen
                FileLogger.shared.info("ScreenSaver[\(instanceID)]: SharedTimerManager has a different viewModel - skipping update")
            }
        }
    }
    
    override func draw(_ rect: NSRect) {
        // Drawing is handled by the SwiftUI hosting view
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
    
    override var configureSheet: NSWindow? {
        return nil
    }
    
    // MARK: - Orphan Detection
    
    /// Start a timer to detect if this instance was orphaned (created but never actually used)
    private func startOrphanDetection() {
        // Cancel any existing timer
        cancelOrphanDetection()
        
        FileLogger.shared.info("ScreenSaver[\(instanceID)]: Starting orphan detection timer (2 seconds)")
        
        // Create a timer that fires after 2 seconds
        orphanDetectionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // If we get here and haven't received any animateOneFrame calls, we're orphaned
            if !self.hasBeenVisible && !self.hasCleanedUp {
                FileLogger.shared.logSeparator("ORPHANED INSTANCE DETECTED")
                FileLogger.shared.warning("🚨 ScreenSaver[\(self.instanceID)]: Instance was created but never received animateOneFrame calls")
                FileLogger.shared.warning("ScreenSaver[\(self.instanceID)]: hasBeenVisible=\(self.hasBeenVisible), hasStarted=\(self.hasStarted), hasCleanedUp=\(self.hasCleanedUp)")
                FileLogger.shared.warning("ScreenSaver[\(self.instanceID)]: This is likely a system-created but abandoned instance")
                FileLogger.shared.warning("ScreenSaver[\(self.instanceID)]: Forcing cleanup to prevent memory leak...")
                
                self.isStopped = true
                self.performCleanup(reason: "orphaned-instance")
                
                FileLogger.shared.info("ScreenSaver[\(self.instanceID)]: Orphaned instance cleaned up")
            }
        }
    }
    
    /// Cancel the orphan detection timer
    private func cancelOrphanDetection() {
        if let timer = orphanDetectionTimer {
            timer.invalidate()
            orphanDetectionTimer = nil
        }
    }
    
    deinit {
        // Cancel timer in case it's still running
        cancelOrphanDetection()
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "deinit",
            details: "ScreenSaver being deallocated - hasCleanedUp=\(hasCleanedUp), hasBeenVisible=\(hasBeenVisible)"
        )
        
        // If we somehow got here without cleanup, force it now
        if !hasCleanedUp {
            FileLogger.shared.error("🚨 ScreenSaver[\(instanceID)]: deinit called but never cleaned up - forcing cleanup now!")
            performCleanup(reason: "deinit")
        }
        
        SharedTimerManager.shared.currentViewModel?.stopUpdating()
        SharedTimerManager.shared.currentViewModel = nil
        SharedTimerManager.shared.currentTimerManager = nil
        hostingView?.removeFromSuperview()
        hostingView = nil
    }
}
