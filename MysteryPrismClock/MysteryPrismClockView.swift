//
//  MysteryPrismClockView.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

import SwiftUI

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

#Preview {
    MysteryPrismClockView()
}
