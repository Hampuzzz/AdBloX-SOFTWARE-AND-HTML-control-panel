# AdBloX MESH iOS — Sideloading Guide

Install AdBloX MESH on your iPhone without the App Store.

## Option 1: AltStore (Recommended)

AltStore lets you install IPAs using your Apple ID. Apps stay installed for 7 days and auto-refresh.

### Setup
1. Install AltServer on your Mac/PC from https://altstore.io
2. Connect your iPhone via USB
3. Install AltStore to your iPhone through AltServer

### Install AdBloX
1. Download `AdBloX-MESH.ipa` from the releases page
2. Open the IPA file on your iPhone
3. Choose "Open in AltStore"
4. AltStore will sign and install the app
5. Keep AltServer running on your computer to auto-refresh every 7 days

## Option 2: Sideloadly

Sideloadly is a desktop tool for sideloading IPAs.

1. Download Sideloadly from https://sideloadly.io
2. Connect your iPhone via USB
3. Drag `AdBloX-MESH.ipa` into Sideloadly
4. Enter your Apple ID
5. Click Start — the app will be installed
6. On iPhone: Settings > General > VPN & Device Management > Trust the developer profile
7. Re-sign every 7 days (free Apple ID) or 365 days (paid developer account)

## Option 3: TrollStore (iOS 14.0–16.6.1)

TrollStore allows permanent installation without re-signing. Only works on specific iOS versions.

1. Check if your iOS version is supported at https://ios.cfw.guide/installing-trollstore
2. Install TrollStore following the guide for your version
3. Open `AdBloX-MESH.ipa` in TrollStore
4. The app is permanently installed — no re-signing needed

## Option 4: Developer Account ($99/year)

With an Apple Developer account, you can install on up to 100 devices for 1 year.

1. Enroll at https://developer.apple.com
2. Open `ios/` in Xcode
3. Select your developer team for signing
4. Build to your device via USB
5. Or export an Ad Hoc IPA for distribution

## Building the IPA

### Prerequisites
- macOS with Xcode 15+
- Apple ID (free) or Apple Developer account ($99/year)

### Steps
1. Open `ios/AdBloX.xcodeproj` in Xcode
2. Select "AdBloX" scheme and your iPhone as target
3. Go to Signing & Capabilities:
   - Set Team to your Apple ID / developer account
   - Set Bundle ID to `se.adblox.mesh` (or your own)
   - Enable "Network Extensions" capability
   - Add App Group: `group.se.adblox.mesh`
4. For the `AdBloXNetworkExtension` target:
   - Set same Team
   - Set Bundle ID to `se.adblox.mesh.tunnel`
   - Enable "Network Extensions" capability
   - Add same App Group
5. Build: Product > Archive
6. Export IPA: Distribute App > Ad Hoc (or Development)

### VPN & Network Extension Permissions
The Network Extension requires special entitlements:
- For **sideloading**: The DNS filtering works via `NEDNSSettingsManager` (no special entitlement needed)
- For **full packet tunnel**: Requires `com.apple.developer.networking.networkextension` entitlement (developer account only)

## After Installation

1. Open AdBloX MESH app
2. Go to Settings > turn on VPN Connection
3. Allow VPN configuration when prompted
4. Turn on DNS Filtering
5. Scan a QR code from the dashboard to join the mesh, or enter the auth key manually
