# MysteryPrismClock
A dynamic macOS screen saver featuring an animated clock with moving, color-changing elements. (Made with the assistance of <a href="https://claude.ai" target="_blank">claude.ai</a>)

<a href="https://www.youtube.com/watch?v=WLEx7_kY8Ws" target="_blank">YouTube demo</a>

<img width="662" height="423" alt="Screenshot 2025-10-27 at 9 34 06 AM" src="https://github.com/user-attachments/assets/aa96ed8f-a870-4022-a36b-490aaae03fc0" />


## Features
- **Dynamic Colors**: Clock colors change based on time components (seconds, minutes, hours)
- **Background Changes**: Clock background changes smoothly every 30 seconds.
- **Moving Clock**: The clock slowly wanders around the screen
- **SwiftUI Implementation**: Built using modern SwiftUI within a ScreenSaver framework
- **Auto installation/restart screensaver engine script**: No more restarting to see changes!
- **Auto Sign, Notarize, Stamp, and Zip release builds**: Requires you to make changes to the codesigning entities, and get a certificate from Apple and install it in your keychain (ask Claude for help with this), but once it's set up, it does all the dirty work for you, so you can send it to your friends.

## Build/Installation
1. Clone this repository
2. Open the project in Xcode
3. Build the screen saver target
4. Press CapsLock for debug window and log
5. Trigger screensaver.
6. There is no step 6!

## Technical Details
- **Platform**: macOS
- **Framework**: ScreenSaver, SwiftUI
- **Language**: Swift
- **Minimum Supported OS Version**: macOS 15.6

## Code Structure
- `MysteryPrismScreenSaver.swift`: Main screen saver class that hosts the SwiftUI view
- `MysteryPrismClockView.swift`: SwiftUI implementation of the animated clock

## License
MIT License.

## Author
Created by Bill Coderre in October/November 2025.

## Wish for Xcode/Claude enhancemeent
Claude cannot "see" (whatever that means) projects' `.pbxproj` files. This is a sadness. I am sure it is planned for a future release.
