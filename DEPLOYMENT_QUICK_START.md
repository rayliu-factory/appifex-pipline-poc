# Deployment Quick Start

## 🎯 Two Pipelines

### 1️⃣ Preview Build (Ad Hoc) - Manual
**Trigger:** Actions → Preview Build → Run workflow
**Output:** IPA + install page for web deployment
**Use:** Share builds with testers via web link

### 2️⃣ TestFlight Release - Automatic
**Trigger:** Push to `main` branch
**Output:** Uploaded to TestFlight automatically
**Use:** Production releases and beta testing

---

## ⚡ Quick Setup

### Required GitHub Secrets

```bash
# For TestFlight (8 secrets)
APPSTORE_CERTIFICATE_BASE64
APPSTORE_P12_PASSWORD
APPSTORE_PROVISION_PROFILE_BASE64
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY_BASE64
KEYCHAIN_PASSWORD

# For Preview Builds (3 additional secrets)
BUILD_CERTIFICATE_BASE64
P12_PASSWORD
BUILD_PROVISION_PROFILE_BASE64
```

### Files to Update

1. `.github/workflows/ExportOptions-AppStore.plist`
   - Replace `YOUR_TEAM_ID`
   - Replace `YOUR_APPSTORE_PROVISIONING_PROFILE_NAME`

2. `.github/workflows/ExportOptions-AdHoc.plist`
   - Replace `YOUR_TEAM_ID`
   - Replace `YOUR_ADHOC_PROVISIONING_PROFILE_NAME`

---

## 📝 How to Get Secrets

### Certificates (P12)
```bash
# Export from Keychain Access as .p12
# Then convert to base64:
base64 -i cert.p12 | pbcopy
```

### Provisioning Profiles
```bash
# Download from Apple Developer
# Convert to base64:
base64 -i profile.mobileprovision | pbcopy
```

### API Key
```bash
# Download from App Store Connect → Users & Access → Keys
# Convert to base64:
base64 -i AuthKey_XXXXX.p8 | pbcopy
```

---

## 🚀 Usage

### Create Preview Build

```bash
# GitHub UI:
Actions → Preview Build → Run workflow
  Branch: develop
  Build number: (leave empty for auto)
  
# Download artifacts → upload to web server → share link
```

### Release to TestFlight

```bash
# Just push to main!
git checkout main
git merge develop
git push origin main

# Or manual:
Actions → TestFlight Release → Run workflow
```

---

## ✅ Verification

After setup, test:

```bash
# 1. Test preview build
Actions → Preview Build → Run → Download artifacts ✓

# 2. Test TestFlight upload  
Push to main → Check App Store Connect ✓
```

---

## 📚 Full Documentation

See [DEPLOYMENT_SETUP.md](DEPLOYMENT_SETUP.md) for complete guide.
