# MysteryPrismClock

A dynamic macOS screen saver featuring an animated clock with moving, color-changing elements.

## Features

- **Dynamic Colors**: Clock colors change based on time components (seconds, minutes, hours)
- **Moving Clock**: The clock repositions itself randomly every 30 seconds
- **Smooth Animation**: 30 FPS animation with smooth second hand movement
- **SwiftUI Implementation**: Built using modern SwiftUI within a ScreenSaver framework

## Description

MysteryPrismClock displays a colorful, animated clock that moves around the screen. The clock features:

- A circular face with dynamic colors that change based on the current time
- Separate visual elements for seconds (moving disk), minutes, and hours
- Color overlays that show intersections between different time components
- Automatic repositioning every 30 seconds to create a dynamic screen saver experience

## Installation

1. Clone this repository
2. Open the project in Xcode
3. Build the screen saver target
4. Install the generated `.saver` file by double-clicking it
5. Select "MysteryPrismClock" in System Preferences > Desktop & Screen Saver

## Technical Details

- **Platform**: macOS
- **Framework**: ScreenSaver, SwiftUI
- **Language**: Swift
- **Minimum Version**: macOS 11.0+ (SwiftUI requirement)

## Code Structure

- `MysteryPrismScreenSaver.swift`: Main screen saver class that hosts the SwiftUI view
- `MysteryPrismClockView.swift`: SwiftUI implementation of the animated clock
- `MysteryPrismClock-Bridging-Header.h`: Bridging header for mixed Swift/Objective-C code

## License

[Add your preferred license here]

## Author

Created by Bill Coderre on 10/18/25.