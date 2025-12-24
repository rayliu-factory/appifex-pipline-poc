# Deployment Setup Guide

Complete guide to configure GitHub Actions for Preview builds and TestFlight releases.

## 📋 Overview

This project has two deployment pipelines:

1. **Preview Build** - Ad Hoc builds for web deployment (manual trigger)
2. **TestFlight Release** - Automatic submission to TestFlight (on push to main)

---

## 🔐 Prerequisites

### 1. Apple Developer Account
- Active Apple Developer Program membership ($99/year)
- Access to App Store Connect
- Team ID from Apple Developer portal

### 2. App Store Connect Setup
- App created in App Store Connect
- Bundle ID: `com.demo.TodoApp` (or your custom ID)

### 3. Certificates and Provisioning Profiles

You'll need:
- **Distribution Certificate** (for App Store)
- **Development/Ad Hoc Certificate** (for Preview builds)
- **App Store Provisioning Profile**
- **Ad Hoc Provisioning Profile**

---

## 📝 Step-by-Step Setup

### Step 1: Create Certificates

#### A. App Store Distribution Certificate

1. Go to [Apple Developer → Certificates](https://developer.apple.com/account/resources/certificates)
2. Click **+** to create new certificate
3. Select **Apple Distribution**
4. Upload CSR (create in Keychain Access → Certificate Assistant → Request a Certificate)
5. Download certificate
6. Double-click to install in Keychain

#### B. Export Certificate as P12

```bash
# Open Keychain Access
# Find your certificates
# Right-click → Export
# Save as .p12 with password
```

Export both:
- App Store certificate → `appstore_cert.p12`
- Ad Hoc certificate → `adhoc_cert.p12`

### Step 2: Create Provisioning Profiles

#### A. App Store Profile

1. Go to [Profiles](https://developer.apple.com/account/resources/profiles)
2. Click **+**
3. Select **App Store**
4. Choose your App ID
5. Select your Distribution certificate
6. Download profile

#### B. Ad Hoc Profile

1. Click **+**
2. Select **Ad Hoc**
3. Choose your App ID
4. Select your certificate
5. **Add device UDIDs** for testing
6. Download profile

### Step 3: Create App Store Connect API Key

1. Go to [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
2. Click **+** to generate key
3. Name: "GitHub Actions"
4. Access: **App Manager** or **Developer**
5. Click **Generate**
6. Download the `.p8` key file (only shown once!)
7. Note the **Key ID** and **Issuer ID**

### Step 4: Prepare Files for GitHub Secrets

#### Convert to Base64

```bash
# Convert certificates to base64
base64 -i appstore_cert.p12 | pbcopy
# Paste into APPSTORE_CERTIFICATE_BASE64

base64 -i adhoc_cert.p12 | pbcopy
# Paste into BUILD_CERTIFICATE_BASE64

# Convert provisioning profiles to base64
base64 -i AppStore.mobileprovision | pbcopy
# Paste into APPSTORE_PROVISION_PROFILE_BASE64

base64 -i AdHoc.mobileprovision | pbcopy
# Paste into BUILD_PROVISION_PROFILE_BASE64

# Convert API key to base64
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
# Paste into APP_STORE_CONNECT_API_KEY_BASE64
```

### Step 5: Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:

#### For App Store/TestFlight:
| Secret Name | Description | Example |
|-------------|-------------|---------|
| `APPSTORE_CERTIFICATE_BASE64` | App Store cert (base64) | `MIIKcAIBAz...` |
| `APPSTORE_P12_PASSWORD` | Password for App Store cert | `your-password` |
| `APPSTORE_PROVISION_PROFILE_BASE64` | App Store profile (base64) | `MIINpQYJKo...` |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID | `ABC123XYZ` |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | `69a6de8d-...` |
| `APP_STORE_CONNECT_API_KEY_BASE64` | API .p8 key (base64) | `LS0tLS1CRU...` |
| `KEYCHAIN_PASSWORD` | Random password for keychain | `random-secure-pwd` |

#### For Preview/Ad Hoc Builds:
| Secret Name | Description |
|-------------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Ad Hoc cert (base64) |
| `P12_PASSWORD` | Password for Ad Hoc cert |
| `BUILD_PROVISION_PROFILE_BASE64` | Ad Hoc profile (base64) |

### Step 6: Update Export Options

Edit `.github/workflows/ExportOptions-AppStore.plist`:

```xml
<key>teamID</key>
<string>ABC123XYZ</string>  <!-- Your Team ID -->

<key>com.demo.TodoApp</key>
<string>TodoApp AppStore Profile</string>  <!-- Your profile name -->
```

Edit `.github/workflows/ExportOptions-AdHoc.plist`:

```xml
<key>teamID</key>
<string>ABC123XYZ</string>  <!-- Your Team ID -->

<key>com.demo.TodoApp</key>
<string>TodoApp AdHoc Profile</string>  <!-- Your profile name -->
```

### Step 7: Update Bundle ID (if needed)

If using a different bundle ID than `com.demo.TodoApp`:

1. Update `project.yml`:
   ```yaml
   PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.YourApp
   ```

2. Update both ExportOptions files

3. Regenerate project:
   ```bash
   xcodegen generate
   ```

---

## 🚀 Using the Pipelines

### Preview Build (Ad Hoc)

**Manual Trigger:**

1. Go to **Actions** tab on GitHub
2. Select **Preview Build** workflow
3. Click **Run workflow**
4. Enter:
   - Branch to build from (e.g., `develop`)
   - Build number (optional)
5. Click **Run workflow**

**What Happens:**
1. Builds ad hoc IPA
2. Creates `manifest.plist` for OTA installation
3. Generates install page
4. Uploads artifacts

**Download & Deploy:**
1. Go to workflow run
2. Download artifact ZIP
3. Extract files:
   - `TodoApp.ipa`
   - `manifest.plist`
   - `install.html`
4. Upload to your web server (must be HTTPS)
5. Update URLs in `manifest.plist` and `install.html`
6. Share install link with testers

**OTA Installation:**
Testers open `install.html` in Safari on their iOS device.

### TestFlight Release

**Automatic Trigger:**
Pushes to `main` branch automatically trigger TestFlight upload.

```bash
git checkout main
git merge develop
git push origin main
```

**Manual Trigger:**

1. Go to **Actions** tab
2. Select **TestFlight Release** workflow
3. Click **Run workflow**
4. Select `main` branch
5. Click **Run workflow**

**What Happens:**
1. Builds App Store IPA
2. Uploads to TestFlight
3. Creates GitHub Release
4. Archives IPA artifact (90 days)

**After Upload:**
1. Wait 15-30 minutes for Apple processing
2. Go to [App Store Connect](https://appstoreconnect.apple.com)
3. Navigate to TestFlight
4. Add testers or groups
5. Submit for testing

---

## 🎯 Testing the Setup

### Test Preview Build

1. Trigger Preview Build workflow manually
2. Wait for completion
3. Check for errors
4. Download artifacts
5. Verify IPA and manifest files

### Test TestFlight Upload

1. Make a small change
2. Commit to main branch
3. Push to GitHub
4. Monitor workflow run
5. Check App Store Connect for upload

---

## 🐛 Troubleshooting

### "Code signing failed"

**Check:**
- Correct certificate in secrets
- Certificate not expired
- Provisioning profile includes App ID
- Team ID matches

**Fix:**
```bash
# Verify certificate
security find-identity -p codesigning -v

# Check provisioning profile
security cms -D -i YourProfile.mobileprovision
```

### "No matching provisioning profile"

**Check:**
- Bundle ID matches exactly
- Profile name in ExportOptions matches
- Profile includes correct devices (Ad Hoc)
- Profile not expired

### "Upload to TestFlight failed"

**Common causes:**
- Invalid API key
- Wrong Issuer ID or Key ID
- API key lacks permissions
- IPA built with wrong profile

**Fix:**
- Regenerate API key
- Verify IDs in secrets
- Grant "App Manager" access to key

### "altool deprecated" Warning

If you see this warning, update to use `notarytool`:

```bash
xcrun notarytool submit \
  --apple-id "your@email.com" \
  --password "app-specific-password" \
  --team-id "ABC123XYZ" \
  $IPA_PATH
```

---

## 📊 Monitoring Builds

### View Logs

1. Go to Actions tab
2. Click on workflow run
3. Expand each step to see logs

### Download Artifacts

1. Scroll to bottom of workflow run
2. Click artifact name to download
3. Extract ZIP file

### Check TestFlight Status

1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. Go to Apps → Your App → TestFlight
3. Check "Processing" status
4. Usually ready in 15-30 minutes

---

## 🔒 Security Best Practices

1. **Rotate secrets regularly** - Change passwords/keys every 6 months
2. **Use minimal permissions** - API keys should have least privileges needed
3. **Don't commit secrets** - Never put credentials in code
4. **Audit access** - Review who has access to GitHub secrets
5. **Use environment protection** - Require approvals for production

---

## 📋 Checklist

Before first deployment:

- [ ] Apple Developer account active
- [ ] App created in App Store Connect
- [ ] Certificates created and exported
- [ ] Provisioning profiles created
- [ ] API key generated
- [ ] All secrets added to GitHub
- [ ] Export options updated with Team ID
- [ ] Bundle ID configured correctly
- [ ] Tested locally first
- [ ] Preview build tested
- [ ] TestFlight upload tested

---

## 🔄 Updating Certificates

When certificates expire:

1. Create new certificate
2. Export as P12
3. Convert to base64
4. Update GitHub secret
5. Update provisioning profiles
6. Test build

---

## 📚 Resources

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/deployment/deploying-xcode-applications)

---

## Summary

You now have:
- ✅ Preview build pipeline for ad hoc distribution
- ✅ Automatic TestFlight uploads on main branch
- ✅ Secure certificate and profile management
- ✅ OTA installation support for testers
- ✅ GitHub Release creation

**Next steps:**
1. Configure all secrets
2. Update export options
3. Test preview build
4. Test TestFlight upload
5. Invite beta testers!

🎉 Happy deploying!
