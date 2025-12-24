# Troubleshooting Guide

Common issues and their solutions when working with the TodoApp project.

## Build Issues

### ❌ "Cannot code sign because the target does not have an Info.plist file"

**Problem**: Test target is missing Info.plist configuration.

**Solution**: This has been fixed in `project.yml`. The test target now has:
```yaml
settings:
  GENERATE_INFOPLIST_FILE: YES
```

If you see this error:
```bash
xcodegen generate
```

This will regenerate the project with the correct settings.

---

### ❌ "No such module 'ComposableArchitecture'"

**Problem**: Swift Package dependencies haven't been resolved.

**Solution**:
1. In Xcode: **File > Packages > Resolve Package Versions**
2. Wait for resolution to complete (may take a minute)
3. Build again (**Cmd+B**)

---

### ❌ "Building for iOS Simulator, but the linked framework was built for iOS"

**Problem**: Dependency built for wrong platform.

**Solution**:
1. Clean build folder: **Product > Clean Build Folder** (**Cmd+Shift+K**)
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Rebuild: **Cmd+B**

---

### ❌ "Scheme 'TodoApp' is not currently configured for the test action"

**Problem**: Scheme is misconfigured.

**Solution**:
1. **Product > Scheme > Edit Scheme...**
2. Select **Test** in the sidebar
3. Ensure **TodoAppTests** is checked
4. Click **Close**

---

## Test Issues

### ❌ Tests Won't Compile

**Problem**: Using old test format or missing imports.

**Solution**: Tests should use **XCTest**, not Swift Testing:
```swift
import ComposableArchitecture
import XCTest
@testable import TodoApp

@MainActor
final class YourTests: XCTestCase {
    func testExample() async {
        // Test code
    }
}
```

---

### ❌ "State was not expected to change, but a change occurred"

**Problem**: TCA's TestStore detected unexpected state change.

**Solution**: Add state assertion in the closure:
```swift
await store.send(.someAction) {
    $0.propertyThatChanged = expectedValue
}
```

---

### ❌ "Received unexpected action"

**Problem**: An effect triggered an action you didn't handle.

**Solution**: Add a receive for that action:
```swift
await store.receive(\.unexpectedAction) {
    // Assert state changes if needed
}
```

---

## Runtime Issues

### ❌ App Crashes on Launch

**Problem**: Various causes.

**Solutions**:
1. Check console for error messages
2. Set an exception breakpoint:
   - **Debug > Breakpoints > Create Exception Breakpoint**
3. Verify all files are included in target
4. Clean and rebuild

---

### ❌ "No simulator devices available"

**Problem**: No iOS simulators installed.

**Solution**:
1. **Xcode > Settings > Platforms**
2. Download iOS 17.0+ runtime
3. Restart Xcode
4. Select simulator from device menu

---

## Dependency Issues

### ❌ "Package.resolved file is corrupted"

**Problem**: Dependency lock file is invalid.

**Solution**:
```bash
rm -rf .build
rm Package.resolved
```
Then in Xcode: **File > Packages > Reset Package Caches**

---

### ❌ Packages Won't Update

**Problem**: Cache issues.

**Solution**:
1. **File > Packages > Reset Package Caches**
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **File > Packages > Update to Latest Package Versions**

---

## Project Generation Issues

### ❌ "No project spec found at project.yml"

**Problem**: Running xcodegen from wrong directory.

**Solution**:
```bash
cd /path/to/appifex-pipeline-poc
xcodegen generate
```

---

### ❌ Changes to project.yml Not Taking Effect

**Problem**: Forgot to regenerate.

**Solution**:
```bash
xcodegen generate
```
Then reopen the project in Xcode.

---

## Code Signing Issues

### ❌ "Failed to create provisioning profile"

**Problem**: Code signing not configured.

**Solution**:
1. Select **TodoApp** target
2. Go to **Signing & Capabilities**
3. Check **Automatically manage signing**
4. Select your **Team**

---

### ❌ "No account for team"

**Problem**: Not signed in to Xcode.

**Solution**:
1. **Xcode > Settings > Accounts**
2. Click **+** to add Apple ID
3. Sign in
4. Select team in project settings

---

## Simulator Issues

### ❌ Simulator Won't Boot

**Problem**: Simulator corrupted or stuck.

**Solutions**:
1. **Device > Erase All Content and Settings**
2. Delete and recreate simulator
3. Restart Mac

---

### ❌ "App installation failed"

**Problem**: Previous build artifacts.

**Solution**:
1. Delete app from simulator (long press, delete)
2. Clean build folder (**Cmd+Shift+K**)
3. Build and run again (**Cmd+R**)

---

## Performance Issues

### ❌ Build Takes Too Long

**Solutions**:
1. Enable build parallelization:
   - **File > Project Settings > Build System: New Build System**
2. Increase parallel tasks:
   - **Xcode > Settings > Locations > Derived Data > Advanced > Custom**
   - Set build system to **Automatic**

---

### ❌ Indexing Takes Forever

**Solutions**:
1. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
2. Restart Xcode
3. Let indexing complete (one time)

---

## Git Issues

### ❌ Merge Conflicts in .xcodeproj

**Problem**: Multiple people modifying Xcode project.

**Solution**:
With XcodeGen, this shouldn't happen. Just regenerate:
```bash
git checkout project.yml  # Keep the correct version
xcodegen generate
git add TodoApp.xcodeproj
```

---

## Common Quick Fixes

### The "Nuclear Option" (When All Else Fails)

```bash
# 1. Clean everything
rm -rf .build
rm -rf ~/Library/Developer/Xcode/DerivedData
rm Package.resolved

# 2. Regenerate project
xcodegen generate

# 3. Open in Xcode
open TodoApp.xcodeproj

# 4. In Xcode:
# - File > Packages > Reset Package Caches
# - File > Packages > Resolve Package Versions
# - Product > Clean Build Folder (Cmd+Shift+K)
# - Product > Build (Cmd+B)
```

---

## Getting Help

### Before Asking for Help

1. ✅ Check this troubleshooting guide
2. ✅ Check the console for error messages
3. ✅ Try the "Nuclear Option" above
4. ✅ Search for the error message online

### Where to Get Help

- **TCA Issues**: https://github.com/pointfreeco/swift-composable-architecture/discussions
- **XcodeGen Issues**: https://github.com/yonaskolb/XcodeGen/issues
- **General Swift**: https://forums.swift.org

### When Reporting Issues

Include:
- Error message (full text)
- Steps to reproduce
- Xcode version
- macOS version
- What you've tried

---

## Preventive Maintenance

### Keep Things Working

1. **Regenerate regularly**:
   ```bash
   xcodegen generate
   ```

2. **Keep dependencies updated**:
   - **File > Packages > Update to Latest Package Versions** (monthly)

3. **Clean periodically**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

4. **Update Xcode**:
   - Keep Xcode up to date via Mac App Store

---

## Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Won't build | Clean (**Cmd+Shift+K**), rebuild |
| Won't run tests | Regenerate: `xcodegen generate` |
| Dependencies broken | Reset caches in Xcode |
| Simulator issues | Delete app, clean, rebuild |
| Project corrupted | `xcodegen generate` |
| Everything broken | See "Nuclear Option" above |

---

## Prevention Tips

✅ **Always regenerate after modifying project.yml**
✅ **Commit project.yml changes before regenerating**
✅ **Clean build folder before major changes**
✅ **Keep Xcode and dependencies updated**
✅ **Use source control (git) religiously**

---

## Still Having Issues?

If you've tried everything and it still doesn't work:

1. Create a fresh clone:
   ```bash
   cd ..
   git clone <repo-url> TodoApp-fresh
   cd TodoApp-fresh
   xcodegen generate
   open TodoApp.xcodeproj
   ```

2. If the fresh clone works, something in your local environment needs cleaning

3. If the fresh clone doesn't work, there's an issue with the project configuration

---

**Most issues can be solved by regenerating the project and cleaning build artifacts!**
