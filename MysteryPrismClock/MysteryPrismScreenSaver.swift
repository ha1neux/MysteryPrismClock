//
//  MysteryPrismScreenSaver.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

#if os(macOS)
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
    
    override init?(frame: NSRect, isPreview: Bool) {
        Self.instanceCounter += 1
        instanceID = Self.instanceCounter
        super.init(frame: frame, isPreview: isPreview)
        
        // Set animation time interval to 60 FPS
        animationTimeInterval = 1.0 / 60.0
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "init",
            details: "isPreview=\(isPreview), frame=\(frame)"
        )
        setupView()
    }
    
    required init?(coder: NSCoder) {
        Self.instanceCounter += 1
        instanceID = Self.instanceCounter
        super.init(coder: coder)
        
        // Set animation time interval to 60 FPS
        animationTimeInterval = 1.0 / 60.0
        
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "init(coder)",
            details: "Initialized from coder"
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
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "startAnimation",
            details: "Called by system - animation will be driven by animateOneFrame()"
        )
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        
        FileLogger.shared.logSeparator("SCREENSAVER DISMISSED BY USER")
        FileLogger.shared.info("🛑 User dismissed the screensaver (mouse moved, key pressed, etc.)")
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "stopAnimation called",
            details: "Thread: \(Thread.isMainThread ? "main" : "background")"
        )
        
        performCleanup(reason: "stopAnimation")
    }
    
    private func performCleanup(reason: String) {
        // Prevent multiple cleanups
        guard !hasCleanedUp else {
            FileLogger.shared.warning("ScreenSaver[\(instanceID)]: performCleanup called again (reason: \(reason)) but already cleaned up - ignoring")
            return
        }
        
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
    
    override func animateOneFrame() {
        // This is called by the system at the interval specified in animationTimeInterval
        
        // Check if we should still be running
        // If the window is nil or not visible, we've been dismissed
        if window == nil || window?.isVisible == false {
            if !hasCleanedUp {
                FileLogger.shared.info("ScreenSaver[\(instanceID)]: Detected dismissal in animateOneFrame (window nil or not visible)")
                performCleanup(reason: "window-dismissed")
            }
            return
        }
        
        // Only update if we haven't cleaned up yet
        guard !hasCleanedUp else {
            // Don't update after cleanup - log occasionally to verify we stopped
            return 
        }
        
        // Tell the view model to update once
        if let vm = SharedTimerManager.shared.currentViewModel {
            vm.performSingleUpdate()
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
    
    deinit {
        FileLogger.shared.logLifecycle(
            object: "ScreenSaver[\(instanceID)]",
            event: "deinit",
            details: "ScreenSaver being deallocated - hasCleanedUp=\(hasCleanedUp)"
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
#endif // os(macOS)
