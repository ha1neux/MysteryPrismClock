//
//  SharedTimerManager.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 11/4/25.
//

import Foundation

// Shared timer manager that can be accessed from the screensaver wrapper
@MainActor
public class SharedTimerManager {
    public static let shared = SharedTimerManager()
    
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
