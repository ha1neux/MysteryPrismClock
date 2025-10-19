# MysteryPrismClock
A dynamic macOS screen saver featuring an animated clock with moving, color-changing elements.

## Features
- **Dynamic Colors**: Clock colors change based on time components (seconds, minutes, hours)
- **Moving Clock**: The clock repositions itself randomly every 30 seconds
- **Smooth Animation**: 30 FPS animation with smooth second hand movement
- **SwiftUI Implementation**: Built using modern SwiftUI within a ScreenSaver framework

## Installation
1. Clone this repository
2. Open the project in Xcode
3. Build the screen saver target
4. Install the generated `.saver` file by double-clicking it
5. Select "MysteryPrismClock" in System Preferences > Desktop & Screen Saver

   Note: If you make changes to the code and recompile and reinstall, you must reboot to have
   the changes take effect. This is a limitation of macOS.

## Technical Details
- **Platform**: macOS
- **Framework**: ScreenSaver, SwiftUI
- **Language**: Swift
- **Minimum Version**: macOS 15.6

## Code Structure
- `MysteryPrismScreenSaver.swift`: Main screen saver class that hosts the SwiftUI view
- `MysteryPrismClockView.swift`: SwiftUI implementation of the animated clock
- `MysteryPrismClock-Bridging-Header.h`: Bridging header for mixed Swift/Objective-C code

## License
MIT License.

## Author

Created by Bill Coderre in October 2025.
