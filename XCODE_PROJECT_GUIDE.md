# Xcode Project Setup Guide

## ✅ Project Successfully Configured!

Your TodoApp is now set up as a proper Xcode project using **XcodeGen**.

## 🎯 What Was Created

1. **TodoApp.xcodeproj** - Xcode project file
2. **project.yml** - XcodeGen configuration (source of truth)
3. **Proper iOS App Target** - Ready to build and run
4. **Automatic SPM Integration** - All dependencies configured

## 🚀 How to Use

### Opening the Project

```bash
open TodoApp.xcodeproj
```

This will open the project in Xcode with:
- ✅ iOS app target configured
- ✅ All source files included
- ✅ Dependencies (TCA, Swift Navigation, Factory) ready
- ✅ Schemes pre-configured
- ✅ Info.plist settings embedded

### Building and Running

1. **Select the TodoApp scheme** from the scheme selector (next to play/stop buttons)

2. **Select a simulator**:
   - Click on the device selector
   - Choose any iOS 17+ simulator (e.g., "iPhone 15")

3. **Build and Run**:
   - Press `Cmd+R` to build and run
   - Or press `Cmd+B` to just build

4. The app will launch in the iOS Simulator!

### Running Tests

- Press `Cmd+U` to run all tests
- Or go to **Product > Test**

## 📝 Project Configuration (project.yml)

The `project.yml` file defines your project structure. Key sections:

### Targets

```yaml
targets:
  TodoApp:
    type: application          # iOS app
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - Sources/TodoApp        # Source code location
    dependencies:
      - package: ComposableArchitecture
      - package: SwiftNavigation
      - package: Factory
```

### Settings

All iOS app settings are pre-configured:
- Bundle identifier: `com.demo.TodoApp`
- SwiftUI support enabled
- Interface orientations set
- Info.plist auto-generated

## 🔄 Regenerating the Project

If you modify `project.yml` or need to regenerate:

```bash
xcodegen generate
```

**When to regenerate:**
- After modifying `project.yml`
- After adding/removing source files
- After changing build settings
- When collaborating (each developer runs `xcodegen`)

## 🎨 Project Structure in Xcode

```
TodoApp (Project)
├── TodoApp (Target)
│   ├── Models/
│   │   └── Todo.swift
│   ├── Services/
│   │   └── TodoRepository.swift
│   ├── DependencyInjection/
│   │   └── AppContainer.swift
│   ├── Features/
│   │   ├── TodoList/
│   │   │   ├── TodoListFeature.swift
│   │   │   └── TodoListView.swift
│   │   └── TodoDetail/
│   │       ├── TodoDetailFeature.swift
│   │       ├── TodoDetailView.swift
│   │       ├── TodoFormFeature.swift
│   │       └── TodoFormView.swift
│   └── App/
│       ├── AppFeature.swift
│       ├── AppView.swift
│       └── TodoApp.swift (@main)
│
├── TodoAppTests (Target)
│   └── TodoListFeatureTests.swift
│
└── Packages (Dependencies)
    ├── ComposableArchitecture
    ├── SwiftNavigation
    └── Factory
```

## 🔧 Customizing the Project

### Changing Bundle Identifier

Edit `project.yml`:
```yaml
settings:
  PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.TodoApp
```

Then regenerate:
```bash
xcodegen generate
```

### Adding New Build Configurations

Edit `project.yml`:
```yaml
settings:
  configurations:
    Debug:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: DEBUG
    Release:
      SWIFT_OPTIMIZATION_LEVEL: -O
```

### Adding Asset Catalogs or Resources

1. Create the folder: `Sources/TodoApp/Resources/`
2. Add to `project.yml`:
```yaml
targets:
  TodoApp:
    sources:
      - Sources/TodoApp
    resources:
      - Sources/TodoApp/Resources/**
```

## 🌟 Advantages of XcodeGen

### 1. Version Control Friendly
- `project.yml` is a simple YAML file
- Much easier to review and merge than `.xcodeproj`
- Fewer merge conflicts

### 2. Reproducible
- Anyone can regenerate the project
- Consistent across team members
- No "it works on my machine" issues

### 3. Easy to Maintain
- One source of truth (`project.yml`)
- Changes are explicit and reviewable
- Can be scripted and automated

### 4. Clean Repository
- Can `.gitignore` the `.xcodeproj` (we keep it for convenience)
- Smaller diffs in version control
- Clear project structure

## 🐛 Troubleshooting

### "No scheme selected" Error

If Xcode opens but shows no schemes:
1. Go to **Product > Scheme > Manage Schemes...**
2. Ensure **TodoApp** is checked
3. Close and reopen Xcode

### Dependencies Not Resolving

1. **File > Packages > Reset Package Caches**
2. **File > Packages > Resolve Package Versions**
3. Wait for resolution to complete

### Build Fails

1. Clean build folder: **Product > Clean Build Folder** (`Cmd+Shift+K`)
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Regenerate project:
   ```bash
   xcodegen generate
   ```

### Can't Find Source Files

If Xcode shows red (missing) files:
1. Check that files exist in `Sources/TodoApp/`
2. Regenerate project:
   ```bash
   xcodegen generate
   ```

## 📱 Running on a Real Device

1. **Connect your iPhone/iPad** via USB
2. **Select your device** from the device selector
3. **Trust the device** when prompted on both Mac and iOS device
4. **Set up code signing**:
   - Select the TodoApp target
   - Go to **Signing & Capabilities**
   - Select your Team
   - Xcode will automatically create a provisioning profile
5. Press `Cmd+R` to build and run

## 🎓 Next Steps

Now that you have a working Xcode project:

1. **Explore the code**:
   - Open [TodoListFeature.swift](Sources/TodoApp/Features/TodoList/TodoListFeature.swift)
   - See how TCA reducers work
   - Examine the state management

2. **Run the app**:
   - Build and run (`Cmd+R`)
   - Try adding, editing, deleting todos
   - Test the filtering functionality

3. **Run tests**:
   - Press `Cmd+U`
   - See how TCA's `TestStore` works
   - Add more test cases

4. **Modify the app**:
   - Add new features
   - Change the UI
   - Experiment with TCA patterns

5. **Read the docs**:
   - [README.md](README.md) - Overview
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
   - [APP_FLOW.md](APP_FLOW.md) - Data flow diagrams

## 📋 Quick Reference

| Action | Command |
|--------|---------|
| Open project | `open TodoApp.xcodeproj` |
| Regenerate | `xcodegen generate` |
| Build | `Cmd+B` |
| Run | `Cmd+R` |
| Test | `Cmd+U` |
| Clean | `Cmd+Shift+K` |

## ✅ Verification Checklist

- [x] XcodeGen installed
- [x] project.yml created
- [x] TodoApp.xcodeproj generated
- [x] iOS app target configured
- [x] Dependencies declared
- [x] Source files included
- [x] Test target configured
- [x] Info.plist settings embedded
- [x] Documentation updated

**Your project is ready to use!** 🎉

Open it with:
```bash
open TodoApp.xcodeproj
```
