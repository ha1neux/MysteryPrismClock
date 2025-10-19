//
//  MysteryPrismScreenSaver.swift
//  MysteryPrismClock
//
//  Created by Bill Coderre on 10/18/25.
//

import ScreenSaver
import SwiftUI

class MysteryPrismScreenSaver: ScreenSaverView {
    private var hostingView: NSHostingView<MysteryPrismClockView>!
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let clockView = MysteryPrismClockView()
        hostingView = NSHostingView(rootView: clockView)
        hostingView.frame = bounds
        hostingView.autoresizingMask = [.width, .height]
        addSubview(hostingView)
    }
    
    override func startAnimation() {
        super.startAnimation()
        // Animation is handled by the SwiftUI view's timers
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        // Timers will be automatically invalidated when the view disappears
    }
    
    override func draw(_ rect: NSRect) {
        // Drawing is handled by the SwiftUI hosting view
    }
    
    override func animateOneFrame() {
        // Animation is handled by the SwiftUI view's timers
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
    
    override var configureSheet: NSWindow? {
        return nil
    }
}
