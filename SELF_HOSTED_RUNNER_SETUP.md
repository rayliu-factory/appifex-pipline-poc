# Self-Hosted Runner Setup Guide

Complete guide for setting up and managing a self-hosted GitHub Actions runner for iOS builds.

## 🎯 Why Self-Hosted?

**Benefits:**
- ✅ Faster builds (no queue time)
- ✅ Use your own Mac hardware
- ✅ Control Xcode versions
- ✅ Pre-installed dependencies
- ✅ No minute limits
- ✅ Access to local certificates

**Requirements:**
- Mac with macOS 12.0 or later
- Xcode installed
- Admin access
- Stable internet connection

---

## 📋 Prerequisites

### 1. Prepare Your Mac

```bash
# Check macOS version
sw_vers

# Check Xcode
xcode-select -p
xcodebuild -version

# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Install SwiftLint (optional)
brew install swiftlint
```

### 2. Create Dedicated User (Recommended)

```bash
# Create a user for the runner
sudo dscl . -create /Users/github-runner
sudo dscl . -create /Users/github-runner UserShell /bin/bash
sudo dscl . -create /Users/github-runner RealName "GitHub Runner"
sudo dscl . -create /Users/github-runner UniqueID 502
sudo dscl . -create /Users/github-runner PrimaryGroupID 20
sudo dscl . -passwd /Users/github-runner

# Or use GUI: System Settings → Users & Groups → Add User
```

---

## 🚀 Install GitHub Actions Runner

### Step 1: Download Runner

1. Go to your GitHub repository
2. **Settings → Actions → Runners**
3. Click **New self-hosted runner**
4. Select **macOS** and architecture (Intel or Apple Silicon)

### Step 2: Set Up Runner

```bash
# Create a folder for the runner
mkdir actions-runner && cd actions-runner

# Download (replace with URL from GitHub)
curl -o actions-runner-osx.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-osx.tar.gz

# Configure
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_TOKEN

# When prompted:
# - Name: Choose a name (e.g., "mac-mini-1")
# - Work folder: Press enter for default (_work)
# - Labels: Press enter or add custom labels (e.g., "xcode-15,ios")
```

### Step 3: Install as Service

```bash
# Install service (runs on boot)
sudo ./svc.sh install

# Start service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

---

## ⚙️ Runner Configuration

### Environment Variables

Create `~/.bash_profile` or `~/.zshrc`:

```bash
# Xcode
export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Ruby (if using fastlane)
export PATH="/usr/local/opt/ruby/bin:$PATH"

# Add to runner
echo 'source ~/.bash_profile' >> ~/.bashrc
```

### Runner Labels

Add labels for targeting specific runners:

```bash
# During configuration or after:
cd actions-runner
./config.sh --labels xcode-15,ios17,m1
```

Use in workflows:
```yaml
runs-on: [self-hosted, xcode-15]
```

---

## 🔐 Security Setup

### 1. Keychain Access

The runner needs access to signing certificates:

```bash
# Create keychain for CI
security create-keychain -p "runner-password" ~/Library/Keychains/runner.keychain
security set-keychain-settings -lut 21600 ~/Library/Keychains/runner.keychain
security unlock-keychain -p "runner-password" ~/Library/Keychains/runner.keychain

# Add to search list
security list-keychains -d user -s ~/Library/Keychains/runner.keychain ~/Library/Keychains/login.keychain
```

### 2. Automatic Keychain Unlock

Create `~/unlock-keychain.sh`:

```bash
#!/bin/bash
security unlock-keychain -p "runner-password" ~/Library/Keychains/runner.keychain
```

Make executable:
```bash
chmod +x ~/unlock-keychain.sh
```

Add to LaunchAgent for automatic unlock.

### 3. SSH Keys (for private dependencies)

```bash
# Generate SSH key for the runner
ssh-keygen -t ed25519 -C "github-runner@yourdomain.com"

# Add to GitHub
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings → SSH and GPG keys
```

---

## 🛠️ Dependencies Setup

### Install Required Tools

```bash
# XcodeGen (already installed)
brew install xcodegen

# SwiftLint
brew install swiftlint

# Fastlane (optional)
brew install fastlane

# CocoaPods (if needed)
sudo gem install cocoapods
```

### Pre-cache Dependencies

```bash
# Clone your repo
cd ~
git clone https://github.com/YOUR_ORG/YOUR_REPO.git
cd YOUR_REPO

# Resolve dependencies once
xcodegen generate
xcodebuild -resolvePackageDependencies -project TodoApp.xcodeproj

# This speeds up first run
```

---

## 📱 Simulator Setup

### Install iOS Runtimes

```bash
# List available runtimes
xcrun simctl list runtimes

# Download iOS runtime (if needed)
# Xcode → Settings → Platforms → Get iOS 17.0

# Create simulator
xcrun simctl create "iPhone 15" "iPhone 15" "iOS17.2"

# Boot simulator (helps with first run)
xcrun simctl boot "iPhone 15"
```

### Pre-boot Simulators

Create script `~/boot-simulators.sh`:

```bash
#!/bin/bash
xcrun simctl boot "iPhone 15" 2>/dev/null || true
```

Add to cron or LaunchAgent.

---

## 🔄 Maintenance

### Update Runner

```bash
cd ~/actions-runner
sudo ./svc.sh stop
./config.sh remove --token YOUR_TOKEN

# Download new version
curl -o actions-runner-osx.tar.gz -L NEW_VERSION_URL
tar xzf ./actions-runner-osx.tar.gz

# Reconfigure and restart
./config.sh --url REPO_URL --token NEW_TOKEN
sudo ./svc.sh install
sudo ./svc.sh start
```

### Clean Build Artifacts

Create cleanup script `~/cleanup-builds.sh`:

```bash
#!/bin/bash

# Clean old builds
find ~/actions-runner/_work -type d -name "build" -mtime +7 -exec rm -rf {} +

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean archives older than 30 days
find ~/Library/Developer/Xcode/Archives -mtime +30 -delete

# Clean simulators
xcrun simctl delete unavailable
```

Run weekly via cron:
```bash
crontab -e
# Add: 0 2 * * 0 ~/cleanup-builds.sh
```

### Monitor Resources

```bash
# Check disk space
df -h

# Check runner logs
tail -f ~/actions-runner/_diag/Runner_*.log

# Check service status
sudo ./svc.sh status
```

---

## 🚨 Troubleshooting

### Runner Won't Start

```bash
# Check logs
cat ~/actions-runner/_diag/Runner_*.log

# Verify permissions
ls -la ~/actions-runner

# Restart service
sudo ./svc.sh stop
sudo ./svc.sh start
```

### Build Fails with "Permission Denied"

```bash
# Fix ownership
sudo chown -R $(whoami) ~/actions-runner

# Check keychain access
security unlock-keychain ~/Library/Keychains/runner.keychain
```

### "Xcode not found"

```bash
# Set Xcode path
sudo xcode-select -s /Applications/Xcode.app

# Verify
xcodebuild -version
```

### Simulator Issues

```bash
# Reset all simulators
xcrun simctl erase all

# Delete unavailable
xcrun simctl delete unavailable

# Restart CoreSimulatorService
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
```

---

## 📊 Monitoring & Optimization

### Enable Verbose Logging

In workflow:
```yaml
- name: Build
  run: xcodebuild -verbose ...
```

### Speed Optimizations

1. **Enable build cache**:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/Library/Developer/Xcode/DerivedData
       key: ${{ runner.os }}-deriveddata-${{ hashFiles('**/*.xcodeproj') }}
   ```

2. **Use local SPM cache**:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.swiftpm
       key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
   ```

3. **Pre-install dependencies**:
   Keep tools installed on the runner

### Resource Limits

Monitor and set limits:

```bash
# Check memory
top -l 1 | grep PhysMem

# Check CPU
sysctl -n hw.ncpu

# Limit concurrent jobs in workflow
jobs:
  build:
    concurrency:
      group: ${{ github.workflow }}-${{ github.ref }}
      cancel-in-progress: true
```

---

## 🔧 Advanced Configuration

### Multiple Runners

Run multiple runners on one Mac:

```bash
# Runner 1
mkdir ~/actions-runner-1
cd ~/actions-runner-1
# ... configure ...

# Runner 2
mkdir ~/actions-runner-2
cd ~/actions-runner-2
# ... configure ...
```

### Custom Labels

Target specific capabilities:

```bash
./config.sh --labels ios,xcode-15,m1-max,32gb-ram
```

Use in workflow:
```yaml
runs-on: [self-hosted, m1-max]
```

### Offline Mode

For air-gapped environments:

```bash
# Download dependencies on connected machine
# Transfer to offline runner
# Use local mirror
```

---

## 📋 Checklist

Before using your self-hosted runner:

- [ ] macOS and Xcode up to date
- [ ] Runner installed and running as service
- [ ] XcodeGen installed
- [ ] Homebrew configured
- [ ] Certificates in keychain
- [ ] SSH keys set up
- [ ] Simulators installed and booted
- [ ] Dependencies pre-cached
- [ ] Cleanup scripts scheduled
- [ ] Monitoring in place
- [ ] Tested with sample workflow

---

## 🔐 Security Best Practices

1. **Don't run public repos** on self-hosted runners (security risk)
2. **Use dedicated user** for runner service
3. **Keep secrets in GitHub Secrets**, not on runner
4. **Regular updates** - macOS, Xcode, runner software
5. **Network isolation** - firewall rules for runner
6. **Audit logs** - review runner activity regularly
7. **Backup certificates** - store securely offsite

---

## 📚 Resources

- [GitHub Self-Hosted Runners Docs](https://docs.github.com/en/actions/hosting-your-own-runners)
- [macOS Runner Setup](https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners#macos)
- [Runner Security](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

## Summary

Your self-hosted runner is now configured for:
- ✅ Fast iOS builds on your own hardware
- ✅ No GitHub Actions minute limits
- ✅ Custom Xcode versions
- ✅ Pre-installed dependencies
- ✅ Secure certificate management
- ✅ Automated cleanup and maintenance

All workflows now use `runs-on: self-hosted` instead of GitHub-hosted runners! 🚀
