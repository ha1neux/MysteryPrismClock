# MysteryPrismClock Tests

This directory contains unit tests for the MysteryPrismClock project.

## Adding the Test Target to Xcode

Since test targets cannot be easily added programmatically, follow these steps to add the test target to your Xcode project:

### Method 1: Using Xcode UI (Recommended)

1. **Open your project** in Xcode
2. **Select the project** in the Project Navigator (top item)
3. Click the **"+"** button at the bottom of the targets list
4. Select **"Unit Testing Bundle"**
5. Configure the test target:
   - **Product Name**: `MysteryPrismClockTests`
   - **Team**: (Select your team)
   - **Organization Identifier**: `com.moxiesoftware` (or your identifier)
   - **Project**: MysteryPrismClock
   - **Target to be Tested**: MysteryPrismClock
6. Click **"Finish"**
7. **Delete** the default test file Xcode creates
8. In the Project Navigator, **select the test target**
9. Go to **"Build Phases"** → **"Compile Sources"**
10. Click **"+"** and add the test files:
    - `ClockColorsTests.swift`
    - `ClockPathsTests.swift`
    - `ClockViewModelTests.swift`

### Method 2: Manual Configuration

If the test target already exists but needs configuration:

1. Select the **MysteryPrismClockTests** target
2. Go to **Build Settings**
3. Ensure these settings:
   - **Product Name**: `MysteryPrismClockTests`
   - **Product Bundle Identifier**: `com.moxiesoftware.MysteryPrismClockTests`
   - **Test Host**: `$(BUILT_PRODUCTS_DIR)/MysteryPrism.saver/Contents/MacOS/MysteryPrism`
4. Go to **Build Phases** → **Compile Sources**
5. Add all `.swift` files from this directory

### Method 3: Link Existing Files

If the test target exists but the files aren't linked:

1. Select the test files in the Project Navigator
2. Open the **File Inspector** (⌥⌘1)
3. In **"Target Membership"**, check the box next to **MysteryPrismClockTests**

## Running Tests

Once the test target is configured:

### Run All Tests
- Press **⌘U** (Command+U)
- Or: **Product** → **Test**

### Run Specific Test File
- Click the diamond icon next to the class name
- Or: Right-click the file → **Run Tests**

### Run Single Test
- Click the diamond icon next to the test method
- Or: Place cursor in test → **⌃⌥⌘U** (Control+Option+Command+U)

### View Test Results
- Open the **Test Navigator** (⌘6)
- Click on any test to see results and logs

## Test Coverage

The test suite covers:

### ClockColorsTests (18 tests)
- ✅ Color initialization
- ✅ Seconds color calculation with/without wrap
- ✅ Prime color offset and wrap-around
- ✅ Minutes and hours color calculations
- ✅ Overlap color logic
- ✅ Saturation and brightness preservation
- ✅ Edge cases (midnight, 11:59:59)

### ClockPathsTests (16 tests)
- ✅ Minute hand path geometry at different angles
- ✅ Hour hand path geometry at different angles
- ✅ Path dimensions (base width calculations)
- ✅ Triangle formation validation
- ✅ Comparison between minute and hour hands
- ✅ Edge cases (zero radius, negative angles, large values)

### ClockViewModelTests (20 tests)
- ✅ Initialization state
- ✅ Setup and configuration
- ✅ Position updates and movement
- ✅ Boundary detection and collision
- ✅ Velocity management
- ✅ Time updates
- ✅ Lifecycle (start/stop)
- ✅ Debug info generation
- ✅ Performance benchmarks
- ✅ Edge cases (various screen sizes)

## Test Organization

```
MysteryPrismClockTests/
├── README.md (this file)
├── ClockColorsTests.swift      # Color calculation tests
├── ClockPathsTests.swift       # Path geometry tests
└── ClockViewModelTests.swift   # View model logic tests
```

## Writing New Tests

When adding new tests:

1. **Follow the naming convention**: `test{WhatYouAreTesting}`
2. **Use the Given-When-Then** pattern:
   ```swift
   func testSomething() {
       // Given: Setup initial state
       let value = 10

       // When: Perform action
       let result = doSomething(value)

       // Then: Assert expectations
       XCTAssertEqual(result, expected)
   }
   ```
3. **Add comments** explaining complex test logic
4. **Group related tests** using `// MARK:` comments

## Troubleshooting

### Tests Don't Appear
- Ensure test files are added to the test target (Build Phases → Compile Sources)
- Clean build folder: **Shift+⌘K**
- Rebuild: **⌘B**

### Tests Fail to Run
- Check that `@testable import MysteryPrismClock` works
- Verify the main target builds successfully
- Check test target's "Test Host" setting

### Missing Symbols
- Ensure the code you're testing is `public` or `internal` (not `private`)
- Use `@testable import` to access internal symbols
- Check that the test target depends on the main target

## CI/CD Integration

To run tests from the command line:

```bash
# Run all tests
xcodebuild test \
    -project MysteryPrismClock.xcodeproj \
    -scheme MysteryPrismClock \
    -destination 'platform=macOS'

# Run with coverage
xcodebuild test \
    -project MysteryPrismClock.xcodeproj \
    -scheme MysteryPrismClock \
    -destination 'platform=macOS' \
    -enableCodeCoverage YES
```

## Code Coverage

To view code coverage:

1. **Enable coverage**: Edit Scheme → Test → Options → Check "Code Coverage"
2. Run tests: **⌘U**
3. View results: **⌘9** (Report Navigator) → Coverage tab

## Best Practices

- ✅ Keep tests fast (avoid Thread.sleep when possible)
- ✅ Test one thing per test method
- ✅ Use descriptive test names
- ✅ Don't test framework code (SwiftUI, Foundation)
- ✅ Focus on business logic and algorithms
- ✅ Use `setUp()` and `tearDown()` for common initialization
- ✅ Avoid test interdependencies

## Future Test Ideas

Consider adding tests for:
- [ ] Color interpolation edge cases
- [ ] Performance under extreme conditions
- [ ] Memory leak detection
- [ ] Thread safety (if applicable)
- [ ] Integration tests with actual SwiftUI views
