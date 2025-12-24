# Creating an Xcode Project for TodoApp

There are three ways to work with this project in Xcode:

## Option 1: Open Package Directly (Recommended - Simplest)

This is the **easiest** way and requires no additional setup:

1. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

2. **IMPORTANT**: After Xcode opens, you need to create a scheme to run the app:

   a. Go to **Product > Scheme > New Scheme...**

   b. Set:
      - **Target**: TodoApp
      - **Name**: TodoApp (or any name you like)

   c. Click **OK**

3. Select the scheme you just created from the scheme selector (next to the play button)

4. Select an iOS 17+ simulator

5. Press **Cmd+R** to run

### Limitations of This Approach:
- Swift Packages can only create library targets, not app targets
- You won't be able to run the app directly this way without additional configuration

## Option 2: Use XcodeGen (Recommended - Best)

This generates a proper `.xcodeproj` file with an iOS app target:

### Install XcodeGen:
```bash
brew install xcodegen
```

### Generate the Project:
```bash
xcodegen generate
```

### Open the Project:
```bash
open TodoApp.xcodeproj
```

### What You Get:
- ✅ Proper iOS app target
- ✅ Automatic dependency management
- ✅ Proper Info.plist configuration
- ✅ Ready to build and run
- ✅ All schemes pre-configured

The `project.yml` file is already configured for this!

## Option 3: Manual Xcode Project Creation (Most Control)

If you want full control, create a new Xcode project manually:

### Step 1: Create New iOS App Project

1. Open Xcode
2. **File > New > Project**
3. Choose **iOS > App**
4. Configure:
   - Product Name: `TodoApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Save in: A **different folder** (not this repo)

### Step 2: Add Swift Package Dependencies

1. In the new project, go to **File > Add Package Dependencies...**

2. Add each package:
   - `https://github.com/pointfreeco/swift-composable-architecture`
   - `https://github.com/pointfreeco/swift-navigation`
   - `https://github.com/hmlongco/Factory`

### Step 3: Copy Source Files

1. Delete the default `ContentView.swift` and `TodoAppApp.swift`

2. Copy all files from this repo's `Sources/TodoApp/` to your new project:
   ```bash
   cp -r Sources/TodoApp/* /path/to/your/new/TodoApp/TodoApp/
   ```

3. In Xcode, right-click the project and **Add Files to "TodoApp"...**

4. Select all the copied source files

### Step 4: Update App Entry Point

The `TodoApp.swift` file is already configured as the entry point with `@main`.

### Step 5: Build and Run

Press **Cmd+R** to build and run!

## Comparison

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Package Direct** | Simplest, no setup | Limited app features | Quick testing |
| **XcodeGen** | Automated, clean, repeatable | Requires brew install | Development |
| **Manual Project** | Full control, standard workflow | Manual setup, separate repo | Production |

## Current Project Structure Issue

The current `Package.swift` defines a **library** target, not an **executable** target. iOS apps need to be executable targets or Xcode app projects.

### To Fix This (Advanced):

You could modify `Package.swift` to use an executable target, but this has limitations for iOS apps. Here's what that would look like:

```swift
.executableTarget(
    name: "TodoApp",
    dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SwiftNavigation", package: "swift-navigation"),
        .product(name: "Factory", package: "Factory"),
    ],
    path: "Sources/TodoApp"
)
```

However, **this won't work well for iOS apps** because:
- Executable targets in SPM are designed for command-line tools
- iOS apps need proper Info.plist configuration
- You need app icons, launch screens, etc.

## Recommendation

**Use XcodeGen (Option 2)** - It's the best balance of automation and proper iOS app structure:

```bash
# Install (one time)
brew install xcodegen

# Generate project (run from this directory)
xcodegen generate

# Open in Xcode
open TodoApp.xcodeproj
```

This will create a proper iOS app project that:
- Uses your existing source files
- Automatically manages dependencies
- Is properly configured for iOS
- Can be regenerated anytime (great for team projects!)

---

**Already have XcodeGen installed?** Just run:
```bash
./setup-xcode.sh
```
