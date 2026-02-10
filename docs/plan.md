# App Store Readiness Plan

Plan for addressing Apple Developer and App Store guidelines before submission. Items can be marked completed as implementation is done.

---

## Phase 1: Critical (Must Complete Before Submission)

### 1.1 Deployment Target
- [x] Keep `IPHONEOS_DEPLOYMENT_TARGET` at 26.0 (required for `glassEffect` Liquid Glass design)
- [x] Verified no blocking issues: `glassEffect` is iOS 26–only; Apple does not reject for high minimum OS

### 1.2 Signing & Provisioning
- [ ] Set `DEVELOPMENT_TEAM` to your Apple Developer account
- [ ] Enable Automatic signing or configure App Store provisioning profile
- [ ] In Xcode: Signing & Capabilities → Team → Select your team
- [ ] Verify build succeeds for "Any iOS Device"

### 1.3 App Icon
- [x] Design and add 1024×1024 app icon
- [x] Add to Assets.xcassets → AppIcon
- [x] Ensure all required sizes are populated (Xcode can generate from 1024px)

### 1.4 Sign in with Apple
- [ ] If adding Google/Email sign-in: implement Sign in with Apple first (Guideline 2.3.8)
- [ ] If keeping Anonymous Auth only: document decision (no third‑party login = no SiwA required)
- [ ] Add Sign in with Apple capability if implementing social login

---

## Phase 2: High Priority

### 2.1 Privacy
- [ ] Create Privacy Policy document
- [ ] Host Privacy Policy at a public URL
- [ ] Add Privacy Policy URL to App Store Connect
- [ ] Add Privacy Policy link in app (e.g. Profile or Settings)
- [ ] Fill App Privacy nutrition labels in App Store Connect for:
  - [ ] User ID (Firebase)
  - [ ] Display name
  - [ ] Game data (scores, rooms)
  - [ ] Friend/balance data
  - [ ] Crash data (Crashlytics)
  - [ ] Analytics (Firebase)

### 2.2 Push Notifications (for Nudge)
- [ ] Add Push Notifications capability in Xcode
- [ ] Configure Firebase Cloud Messaging (or equivalent)
- [ ] Only send nudges after user enables Notifications in Profile
- [ ] Test notification flow end-to-end

### 2.3 App Completeness
- [ ] Verify no broken or placeholder features
- [ ] Remove or implement any "Coming soon" sections
- [ ] Test full flow: Create room → Join room → Play rounds → End game
- [ ] Test Friends tab: settle, nudge
- [ ] Test Profile tab: edit name, settings, logout
- [ ] Verify all buttons and navigation work

---

## Phase 3: Medium Priority

### 3.1 Financial / Gambling Disclaimer (Optional)
- [ ] Decide if in-app disclaimer is needed
- [ ] If yes: add short disclaimer in Rules or before first game (e.g. "For tracking friendly games only")
- [ ] Ensure App Store description avoids "betting" or "gambling" language

### 3.2 Offline Experience
- [ ] Test app behavior when offline
- [ ] Add user-facing message when network is unavailable (if applicable)
- [ ] Ensure Mock mode or graceful degradation works

### 3.3 Production Logging
- [ ] Wrap or remove `print()` statements in production
- [ ] Use `#if DEBUG` for debug logs
- [ ] Ensure no user IDs or sensitive data in production logs
- [ ] Review Crashlytics configuration

---

## Phase 4: Pre-Submission Checklist

### 4.1 App Store Connect
- [ ] Create app record in App Store Connect
- [ ] Add screenshots for required device sizes
- [ ] Write app description
- [ ] Set age rating
- [ ] Add keywords
- [ ] Set support URL
- [ ] Set Privacy Policy URL
- [ ] Complete App Privacy questionnaire

### 4.2 Build & Upload
- [ ] Archive build in Xcode
- [ ] Upload to App Store Connect (TestFlight)
- [ ] Test via TestFlight on physical device
- [ ] Resolve any export compliance questions

### 4.3 Final Review
- [ ] Re-read App Store Review Guidelines
- [ ] Verify no guideline 4.2 (minimum functionality) issues
- [ ] Confirm app provides lasting value
- [ ] Submit for review

---

## Completion Tracker

| Phase   | Status | Completed Items |
|---------|--------|-----------------|
| Phase 1 | ⬜     | 0 / 4          |
| Phase 2 | ⬜     | 0 / 3          |
| Phase 3 | ⬜     | 0 / 3          |
| Phase 4 | ⬜     | 0 / 3          |

**How to use:** Check off each `- [ ]` item when done. Update the Completion Tracker by changing `⬜` to `✅` and updating counts when a phase is complete.

---

## Reference Links

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
