# Test Target Setup for Screen Saver Bundle

Since MysteryPrismClock is a screen saver bundle (not a regular app), you need to configure the test target manually.

## Step-by-Step Instructions

### 1. Create the Test Target (if not already done)

1. In Xcode, click the **"+"** at the bottom of the targets list
2. Select **"Unit Testing Bundle"**
3. Configure:
   - **Product Name**: `MysteryPrismClockTests`
   - **Team**: (Your team)
   - **Organization Identifier**: `com.moxiesoftware`
   - **Target to be Tested**: **None** (this is OK!)
4. Click **Finish**

### 2. Add Test Files to Target

1. In Project Navigator, select all three test files:
   - `ClockColorsTests.swift`
   - `ClockPathsTests.swift`
   - `ClockViewModelTests.swift`

2. Open **File Inspector** (View → Inspectors → File, or ⌥⌘1)

3. In **Target Membership** section, check ✅ **MysteryPrismClockTests**

### 3. Configure Build Settings

1. Select **MysteryPrismClockTests** target
2. Go to **Build Settings** tab
3. Search for "Test Host"
4. Set **Test Host** to:
   ```
   $(BUILT_PRODUCTS_DIR)/MysteryPrism.saver/Contents/MacOS/MysteryPrism
   ```

5. Search for "Bundle Loader"
6. Set **Bundle Loader** to:
   ```
   $(TEST_HOST)
   ```

### 4. Link Against Main Target

1. Still in **MysteryPrismClockTests** target
2. Go to **Build Phases** tab
3. Expand **Dependencies**
4. Click **"+"**
5. Select **MysteryPrismClock**
6. Click **Add**

### 5. Make Source Code Accessible

You have two options:

#### Option A: Add Source Files to Test Target (Recommended)

1. In Project Navigator, select these source files (⌘-click to select multiple):
   - `ClockColors.swift`
   - `ClockPaths.swift`
   - `ClockViewModel.swift`
   - `ColorExtension.swift`

2. In **File Inspector** (⌥⌘1), under **Target Membership**:
   - Keep ✅ **MysteryPrismClock** checked
   - Also check ✅ **MysteryPrismClockTests**

#### Option B: Use @testable import

If Option A doesn't work, the tests use `@testable import MysteryPrismClock` which should give access to internal symbols.

### 6. Test It!

1. Press **⌘U** to run tests
2. You should see all 54 tests run

If you get errors about symbols not found, use Option A above.

## Troubleshooting

### "Module 'MysteryPrismClock' not found"

- Make sure you completed Step 4 (Link Against Main Target)
- Build the main target first: Select **MysteryPrismClock** scheme and press ⌘B
- Then try running tests again

### "Use of unresolved identifier 'ClockColors'"

- Use Option A in Step 5 (add source files to test target)

### Tests won't run

- Make sure the test files are added to **Compile Sources** in Build Phases
- Check that **MysteryPrismClock** is in **Dependencies**

### "No such module 'XCTest'"

- Your test target might not be linked to XCTest framework
- Go to Build Phases → Link Binary With Libraries → Add XCTest.framework
