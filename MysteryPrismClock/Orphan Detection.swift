//
//  Orphan Detection.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import SwiftUI

extension MysteryPrismScreenSaver {
    // MARK: - Orphan Detection
    
    /// Start a timer to detect if this instance was orphaned (created but never actually used)
    func startOrphanDetection() {
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
    func cancelOrphanDetection() {
        if let timer = orphanDetectionTimer {
            timer.invalidate()
            orphanDetectionTimer = nil
        }
    }
}
