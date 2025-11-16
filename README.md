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
2. Open the project in Xcode, adjust code signing credentials
3. Build the screen saver target
4. Press CapsLock for debug window and log
5. Trigger screensaver.
6. There is no step 6!

## Code Signing Setup

To build and distribute this screen saver, you'll need to configure code signing. The complexity depends on your distribution goals:

### For Personal Use (Development Signing)

**Easiest option**: Just sign with your Apple Developer account for personal use.

1. **Get an Apple Developer Account**
   - Free account: Sign in with your Apple ID in Xcode (Xcode → Settings → Accounts)
   - Paid account ($99/year): Join the [Apple Developer Program](https://developer.apple.com/programs/)

2. **Configure Xcode Signing**
   - Open the project in Xcode
   - Select the **MysteryPrismClock** target
   - Go to **"Signing & Capabilities"** tab
   - Under **"Signing"**:
     - **Automatically manage signing**: ✅ Checked (recommended for personal use)
     - **Team**: Select your personal team or development team
   - Xcode will automatically create a development certificate

3. **Build and Install**
   - Press **⌘B** to build
   - The build script will automatically:
     - Install to `~/Library/Screen Savers`
     - Restart the screen saver engine
   - Your screen saver is now installed!

### For Distribution (Release Signing & Notarization)

**For sharing with others**: You need a paid Apple Developer account and need to notarize.

#### Prerequisites

1. **Paid Apple Developer Account** ($99/year)
   - Enroll at [developer.apple.com](https://developer.apple.com/programs/)

2. **Developer ID Certificate**
   - Open **Xcode** → **Settings** → **Accounts**
   - Select your team → **Manage Certificates**
   - Click **"+"** → **"Developer ID Application"**
   - Certificate will be created and added to your keychain

#### Step 1: Configure Code Signing Identity

1. Open `Scripts/sign-notarize-staple.sh`
2. Update the `DEVELOPER_ID` variable (around line 11):
   ```bash
   DEVELOPER_ID="Developer ID Application: YOUR NAME (YOUR TEAM ID)"
   ```

3. To find your exact identity:
   ```bash
   security find-identity -v -p codesigning
   ```
   Look for the "Developer ID Application" entry

#### Step 2: Create Notarization Credentials

Notarization requires an **app-specific password** for your Apple ID:

1. **Generate an App-Specific Password**
   - Go to [appleid.apple.com](https://appleid.apple.com/)
   - Sign in with your Apple ID
   - Go to **Security** → **App-Specific Passwords**
   - Click **"+"** to generate a new password
   - Name it "MysteryPrism Notarization" (or similar)
   - **Save the password** (you'll need it in the next step)

2. **Store Credentials in Keychain**

   Run this command in Terminal (replace with your info):
   ```bash
   xcrun notarytool store-credentials "notarization-profile" \
       --apple-id "your-apple-id@example.com" \
       --team-id "YOUR_TEAM_ID" \
       --password "xxxx-xxxx-xxxx-xxxx"
   ```

   - `notarization-profile`: Name of the keychain profile (must match the script)
   - `your-apple-id@example.com`: Your Apple ID email
   - `YOUR_TEAM_ID`: Your 10-character team ID (find in developer account)
   - `xxxx-xxxx-xxxx-xxxx`: The app-specific password you just created

3. **Verify the profile was created**:
   ```bash
   xcrun notarytool list-credentials
   ```

#### Step 3: Configure Xcode Project

1. Open the project in Xcode
2. Select the **MysteryPrismClock** target
3. Go to **"Signing & Capabilities"**
4. Configure as follows:
   - **Automatically manage signing**: ❌ Unchecked
   - **Signing Certificate**: "Developer ID Application"
   - **Team**: Your paid developer team
   - **Provisioning Profile**: Leave as "None" (not needed for screen savers)

#### Step 4: Build Release Version

1. In Xcode, select the **"MysteryPrismClock"** scheme (not DEBUG)
2. Select **"Product"** → **"Archive"** or press **⌘B** with Release configuration
3. The build script will automatically:
   - ✅ Sign the screen saver with your Developer ID
   - ✅ Submit to Apple for notarization
   - ✅ Wait for notarization to complete (usually 1-5 minutes)
   - ✅ Staple the notarization ticket
   - ✅ Create a distributable `.zip` file
   - ✅ Open the folder with the signed and notarized build

4. The final `MysteryPrism.zip` is ready to share!

### Troubleshooting Code Signing

#### "No identity found" error
- Ensure you have a "Developer ID Application" certificate
- Check with: `security find-identity -v -p codesigning`
- Create one in Xcode → Settings → Accounts → Manage Certificates

#### Notarization fails with authentication error
- Verify your notarization profile: `xcrun notarytool list-credentials`
- Make sure you used an **app-specific password**, not your regular Apple ID password
- Ensure your team ID is correct

#### "Could not find the notarization credentials" error
- The script looks for a profile named `notarization-profile`
- If you used a different name, update line 12 in `Scripts/sign-notarize-staple.sh`:
  ```bash
  NOTARIZATION_KEYCHAIN_PROFILE="your-profile-name"
  ```

#### Notarization takes too long
- Notarization usually takes 1-5 minutes
- If it takes longer, check status with:
  ```bash
  xcrun notarytool history --keychain-profile "notarization-profile"
  ```

#### To skip notarization during development
- The script only runs for **Release** builds
- Use the **DEBUG** scheme for development (notarization will be skipped)

### Manual Signing (Advanced)

If you prefer to sign manually without the automated script:

```bash
# Sign
codesign --force --verify --verbose \
    --sign "Developer ID Application: YOUR NAME (TEAM_ID)" \
    --options runtime --timestamp \
    ~/Library/Screen\ Savers/MysteryPrism.saver

# Create zip
cd ~/Library/Screen\ Savers
ditto -c -k --keepParent MysteryPrism.saver MysteryPrism.zip

# Submit for notarization
xcrun notarytool submit MysteryPrism.zip \
    --keychain-profile "notarization-profile" \
    --wait

# Staple
xcrun stapler staple MysteryPrism.saver

# Verify
xcrun stapler validate MysteryPrism.saver
codesign --verify --verbose=2 MysteryPrism.saver
```

## Technical Details
- **Platform**: macOS
- **Framework**: ScreenSaver, SwiftUI
- **Language**: Swift
- **Minimum Supported OS Version**: macOS 14.8.2 or possibly earlier, pending testing

## Code Structure
- `MysteryPrismScreenSaver.swift`: Main screen saver class that hosts the SwiftUI view
- `MysteryPrismClockView.swift`: SwiftUI implementation of the animated clock
- Code has been refactored to lots of small files for separate functionality such as `Color` calculations and the various segments of the clock to be drawn.

## License
MIT License. Please feel free to re-use the code for your own projects. Please feel free to install the saver on your Mac and enjoy it. **Please do not sell the existing screensaver or put it in a product as-is without asking. Thank you.**

## Author
Created by Bill Coderre in October/November 2025.

## Wish for Xcode/Claude enhancement
Xcode's Claude connection cannot "see" (whatever that means) projects' `.xcodeproj` files. This is a sadness.
