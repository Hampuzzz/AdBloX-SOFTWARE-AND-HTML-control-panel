# AdBloX MESH — Phase Plan

## Phase 1: Android App (Play Store + APK)
**Status**: Ready to start

1. Fork `tailscale/tailscale-android` (BSD-3-Clause)
2. Rebrand: app name, icons, colors, splash screen
3. Hardcode `mesh.adblox.se` as default coordination server
4. Add WebView tab for the dashboard
5. Build signed APK for direct download
6. Submit to Google Play Store

**Key files to modify in fork:**
- `AndroidManifest.xml` — package name, permissions
- `res/` — all drawable assets, colors, strings
- `MainActivity.kt` — add WebView tab
- `build.gradle` — signing config

## Phase 2: iOS App (Sideload + App Store)
**Status**: Code complete, needs Xcode build

1. Open `ios/` in Xcode on macOS
2. Configure signing (see SIDELOAD.md for 3rd-party distribution)
3. Build Tailscale Go core as XCFramework
4. Test Network Extension on physical device
5. Distribute via:
   - **IPA sideloading** (AltStore, Sideloadly, TrollStore)
   - **TestFlight** for beta testing
   - **App Store** for public release

## Phase 3: Dashboard + QR Integration
**Status**: Dashboard complete, needs backend API

1. Deploy dashboard to `mesh.adblox.se`
2. Connect to real AdBloX backend REST API
3. Implement QR code enrollment flow end-to-end
4. Add WebSocket for real-time stats updates
5. Add Tailscale SSO authentication
