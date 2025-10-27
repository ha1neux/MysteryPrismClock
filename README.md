# MysteryPrismClock
A dynamic macOS screen saver featuring an animated clock with moving, color-changing elements.

<a href="https://www.youtube.com/watch?v=WLEx7_kY8Ws" target="_blank">YouTube demo</a>

<img width="662" height="423" alt="Screenshot 2025-10-27 at 9 34 06 AM" src="https://github.com/user-attachments/assets/aa96ed8f-a870-4022-a36b-490aaae03fc0" />


## Features
- **Dynamic Colors**: Clock colors change based on time components (seconds, minutes, hours)
- **Background Changes**: Clock background changes smoothly every 30 seconds.
- **Moving Clock**: The clock slowly wanders around the screen
- **SwiftUI Implementation**: Built using modern SwiftUI within a ScreenSaver framework

## Installation
1. Clone this repository
2. Open the project in Xcode
3. Build the screen saver target
4. Under Product, select "Show build folder in Finder."
5. Open Products/Release.
6. Install the generated `.saver` file by double-clicking it
7. Select "MysteryPrism" in System Preferences > Desktop & Screen Saver (In Tahoe, System Preferences > Wallpaper, click on the "Screensaver" button, scroll all the way down and all the way to the right to find it.)

   Note: If you make changes to the code and recompile and reinstall, you might have to reboot to have
   the changes take effect. This is a limitation of macOS.

## Technical Details
- **Platform**: macOS
- **Framework**: ScreenSaver, SwiftUI
- **Language**: Swift
- **Minimum Version**: macOS 15.6

## Code Structure
- `MysteryPrismScreenSaver.swift`: Main screen saver class that hosts the SwiftUI view
- `MysteryPrismClockView.swift`: SwiftUI implementation of the animated clock

## License
MIT License.

## Author
Created by Bill Coderre in October 2025.
