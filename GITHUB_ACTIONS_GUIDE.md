# GitHub Actions CI/CD Guide

Complete guide for the automated workflows set up for the TodoApp project.

## 🚀 Workflows Overview

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual trigger via GitHub UI

**Jobs:**
- **Build and Test** - Compiles the app and runs all tests
- **Lint** - Runs SwiftLint for code quality

**What It Does:**
1. Checks out code
2. Selects correct Xcode version
3. Installs XcodeGen
4. Generates Xcode project
5. Resolves Swift Package dependencies
6. Builds app for testing
7. Runs all unit tests
8. Uploads test results as artifacts

---

### 2. Release Workflow (`.github/workflows/release.yml`)

**Triggers:**
- Push of tags matching `v*` (e.g., `v1.0.0`)
- Manual trigger via GitHub UI

**What It Does:**
1. Builds release archive
2. Creates GitHub Release with notes
3. Attaches build artifacts

---

## 📋 Setup Instructions

### 1. Initial Setup

The workflows are ready to use! Just commit and push:

```bash
git add .github/
git commit -m "Add GitHub Actions CI/CD workflows"
git push origin main
```

### 2. Configure Branch Protection (Recommended)

Go to: **Settings > Branches > Add rule**

For `main` branch:
- ✅ Require a pull request before merging
- ✅ Require status checks to pass
  - Select: `Build and Test`
  - Select: `SwiftLint`
- ✅ Require conversation resolution before merging

### 3. Update CODEOWNERS

Edit `.github/CODEOWNERS` and replace `@your-github-username` with your actual GitHub username:

```
* @yourusername
```

---

## 🎯 Using the Workflows

### Running CI on Pull Requests

1. Create a feature branch:
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make changes and commit:
   ```bash
   git add .
   git commit -m "Add new feature"
   git push origin feature/my-feature
   ```

3. Open a Pull Request on GitHub

4. CI automatically runs:
   - ✅ Build check
   - ✅ Tests
   - ✅ Linting

5. PR is ready to merge when all checks pass ✅

---

### Creating a Release

1. Update version in code

2. Commit changes:
   ```bash
   git add .
   git commit -m "Bump version to 1.0.0"
   git push origin main
   ```

3. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. GitHub Actions automatically:
   - Builds release
   - Creates GitHub Release
   - Generates release notes

---

## ⚙️ Configuration

### Xcode Version

Update in workflow files if needed:

```yaml
env:
  XCODE_VERSION: '15.2'  # Change this
  IOS_SIMULATOR: 'iPhone 15'
  IOS_VERSION: '17.2'
```

### Simulator Configuration

Available simulators on GitHub Actions runners:
- iPhone 15, 15 Plus, 15 Pro, 15 Pro Max
- iPhone 14, 14 Plus, 14 Pro, 14 Pro Max
- iPad Pro, iPad Air

Update the `IOS_SIMULATOR` env variable to change device.

---

## 📊 Monitoring Workflows

### View Workflow Runs

1. Go to **Actions** tab in GitHub
2. See all workflow runs and their status
3. Click any run to see detailed logs

### Debug Failed Runs

1. Click on the failed workflow
2. Click on the failed job
3. Expand the failed step
4. Review error logs

Common failures:
- **Build errors** - Check compilation issues
- **Test failures** - Review test logs
- **Timeout** - Increase timeout in workflow

---

## 🔧 SwiftLint Configuration

The `.swiftlint.yml` file configures linting rules:

```yaml
disabled_rules:
  - trailing_whitespace  # Example

opt_in_rules:
  - empty_count
  - explicit_init

line_length:
  warning: 120
  error: 200
```

### Customize Rules

Edit `.swiftlint.yml`:
- Add rules to `disabled_rules` to ignore them
- Add rules to `opt_in_rules` to enable them
- Adjust `line_length` limits

### Run Locally

```bash
# Install SwiftLint
brew install swiftlint

# Run linting
swiftlint lint

# Auto-fix issues
swiftlint --fix
```

---

## 📦 Artifacts

### Test Results

After each CI run, test results are uploaded:
- Location: Workflow run page > Artifacts section
- Retention: 7 days
- Includes: `.xcresult` bundles and crash logs

### Download Artifacts

1. Go to workflow run
2. Scroll to **Artifacts** section
3. Download `test-results.zip`

---

## 🚨 Troubleshooting

### "No matching Xcode version"

**Issue:** GitHub runner doesn't have specified Xcode version

**Fix:** Check available versions:
- https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md

Update `XCODE_VERSION` in workflow.

---

### "xcodegen: command not found"

**Issue:** XcodeGen installation failed

**Fix:** Already handled in workflow with `brew install xcodegen`. Check brew logs if failing.

---

### "Simulator not found"

**Issue:** Specified simulator unavailable

**Fix:** Use `xcrun simctl list devices` to check available devices. Update `IOS_SIMULATOR`.

---

### Tests Timeout

**Issue:** Tests take too long

**Fix:** Add timeout to test step:

```yaml
- name: Run tests
  timeout-minutes: 10  # Add this
  run: |
    xcodebuild test-without-building ...
```

---

### Package Resolution Fails

**Issue:** SPM dependencies won't resolve

**Fix:** Add retry logic or check network issues. Already included in workflow.

---

## 🔐 Secrets and Variables

### GitHub Token

The `GITHUB_TOKEN` is automatically provided - no setup needed.

### Adding Custom Secrets

For App Store deployment (future):

1. Go to **Settings > Secrets and variables > Actions**
2. Click **New repository secret**
3. Add:
   - `APP_STORE_CONNECT_API_KEY`
   - `CERTIFICATE_P12`
   - `PROVISIONING_PROFILE`

Then use in workflow:
```yaml
env:
  API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
```

---

## 📈 Advanced Workflows

### Matrix Builds

Test on multiple iOS versions:

```yaml
strategy:
  matrix:
    ios-version: ['17.0', '17.2', '17.4']
    device: ['iPhone 15', 'iPad Pro']
```

### Caching Dependencies

Speed up builds:

```yaml
- name: Cache SPM packages
  uses: actions/cache@v3
  with:
    path: .build
    key: ${{ runner.os }}-spm-${{ hashFiles('Package.resolved') }}
```

### Code Coverage

Add coverage reporting:

```yaml
- name: Generate code coverage
  run: |
    xcodebuild test \
      -enableCodeCoverage YES \
      ...

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
```

---

## 📋 Checklist for Production

Before using in production:

- [ ] Update `@your-github-username` in CODEOWNERS
- [ ] Configure branch protection rules
- [ ] Set up required status checks
- [ ] Test workflows with a PR
- [ ] Verify test artifacts upload correctly
- [ ] Configure notification settings
- [ ] Document team workflow process
- [ ] Add badges to README (optional)

---

## 🎨 Status Badges

Add to README.md:

```markdown
![CI](https://github.com/username/repo/workflows/CI/badge.svg)
![Release](https://github.com/username/repo/workflows/Release/badge.svg)
```

Replace `username/repo` with your repository path.

---

## 🔄 Workflow Best Practices

1. **Keep workflows fast** - Use caching, parallel jobs
2. **Fail fast** - Stop on first error when appropriate
3. **Use matrix builds** - Test multiple configurations
4. **Upload artifacts** - Preserve test results and logs
5. **Set timeouts** - Prevent hanging workflows
6. **Use secrets** - Never commit credentials
7. **Version pinning** - Use specific action versions (`@v4`)

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode on GitHub Actions](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [XcodeGen Documentation](https://github.com/yonaskolb/XcodeGen)

---

## Summary

GitHub Actions is now configured for:
- ✅ Automated testing on every PR
- ✅ Code quality checks with SwiftLint
- ✅ Automated releases on tags
- ✅ Test result artifacts
- ✅ Pull request template
- ✅ Code owners

**Next steps:**
1. Commit and push the workflows
2. Open a test PR to verify CI works
3. Tag a release to test release workflow

Your CI/CD pipeline is ready! 🚀
