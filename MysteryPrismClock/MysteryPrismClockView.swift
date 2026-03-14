//
//  MysteryPrismClockView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

import SwiftUI

struct MysteryPrismClockView: View {
    @StateObject private var viewModel = ClockViewModel()
    @State private var opacity: CGFloat = 0.0
    @State private var hasInitialized = false
    
    // Constants
    private let clockSizeFactor: CGFloat = 2.0
    private let inset: CGFloat = 0.8
    private var insetPrime: CGFloat { (1.0 - inset) / 2 }

    // Movement constants
    private let fadeInDuration: TimeInterval = 5.0
    
    private var clockSize: CGFloat {
        let baseDimension = min(viewModel.screenSize.width, viewModel.screenSize.height)
        return baseDimension / clockSizeFactor
    }
    
    private var fallbackCenter: CGPoint {
        CGPoint(x: viewModel.screenSize.width / 2, y: viewModel.screenSize.height / 2)
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Clock
            ClockView(
                time: viewModel.currentTime,
                clockBaseColor: viewModel.clockBaseColor,
                clockSize: clockSize,
                inset: inset,
                insetPrime: insetPrime,
                opacity: opacity
            )
            .position(viewModel.clockPosition == .zero ? fallbackCenter : viewModel.clockPosition)
            
            // Debug information overlay
            if viewModel.showDebugInfo {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.debugInfo)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.8))
                        .clipShape(.rect(cornerRadius: 8))
                        Spacer()
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            viewModel.screenSize = newSize
            
            guard !hasInitialized else { return }
            hasInitialized = true
            
            // Logging state is already set by screensaver init, but check again as backup
            FileLogger.shared.updateLoggingState()
            let capsLockPressed = NSEvent.modifierFlags.contains(.capsLock)
            
            // Log startup (will only log if CapsLock is pressed)
            FileLogger.shared.logSeparator("VIEW APPEARED")
            FileLogger.shared.info("Clock view appeared - Screen size: \(newSize)")
            FileLogger.shared.info("CapsLock on launch: \(capsLockPressed ? "PRESSED (logging enabled)" : "not pressed (logging disabled)")")
            
            // Register this view model with the shared instance
            SharedTimerManager.shared.currentViewModel = viewModel
            
            FileLogger.shared.info("Clock view: Registered viewModel[\(ObjectIdentifier(viewModel).hashValue)] with SharedTimerManager")
            
            // Start fade-in animation
            withAnimation(.easeIn(duration: fadeInDuration)) {
                opacity = 1.0
            }
            
            viewModel.setupInitialClock(screenSize: newSize)
            FileLogger.shared.info("Clock initialized and ready for viewModel[\(ObjectIdentifier(viewModel).hashValue)]")
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
    }
}

#Preview {
    MysteryPrismClockView()
}
