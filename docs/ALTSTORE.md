# Installing AdBloX MESH via AltStore

AltStore lets you install apps on your iPhone without the App Store. The app refreshes automatically every 7 days as long as AltServer is running on your Mac or PC.

## Prerequisites

- iPhone running iOS 16.0 or later
- Mac or Windows PC on the same Wi-Fi network
- Apple ID (free works, no developer account needed)

## Step 1: Install AltServer on your computer

**Mac:**
1. Download AltServer from https://altstore.io
2. Move to Applications folder
3. Launch AltServer — it appears in the menu bar

**Windows:**
1. Download AltServer from https://altstore.io
2. Install and run AltServer
3. Install iCloud for Windows from Apple (NOT from Microsoft Store)
4. AltServer appears in the system tray

## Step 2: Install AltStore on your iPhone

1. Connect iPhone to computer via USB
2. Trust the computer on your iPhone if prompted
3. In AltServer menu: Install AltStore > [Your iPhone]
4. Enter your Apple ID and password
5. AltStore appears on your iPhone home screen
6. On iPhone: Settings > General > VPN & Device Management > Trust your Apple ID

## Step 3: Build the AdBloX MESH IPA

On a Mac with Xcode 15+ installed:

1. Create a new Xcode project:
   - File > New > Project > iOS > App
   - Product Name: `AdBloX MESH`
   - Bundle ID: `se.adblox.mesh`
   - Interface: SwiftUI, Language: Swift

2. Copy the source files from this repo:
   - Replace auto-generated files with contents of `ios/AdBloX/`
   - Delete the auto-generated ContentView.swift

3. Add Network Extension target:
   - File > New > Target > Network Extension (Packet Tunnel)
   - Product Name: `AdBloXNetworkExtension`
   - Copy files from `ios/AdBloXNetworkExtension/`

4. Configure signing:
   - Select AdBloX target > Signing & Capabilities
   - Team: Your Apple ID
   - Add capability: Network Extensions (Packet Tunnel)
   - Add capability: App Groups > `group.se.adblox.mesh`
   - Repeat for the Network Extension target

5. Build the IPA:
   - Set device to "Any iOS Device (arm64)"
   - Product > Archive
   - Distribute App > Ad Hoc > Export
   - This creates `AdBloX MESH.ipa`

## Step 4: Install via AltStore

**Option A — AirDrop the IPA:**
1. AirDrop the `.ipa` file to your iPhone
2. Open the file, choose "Open in AltStore"
3. AltStore signs and installs it

**Option B — Via AltServer:**
1. Connect iPhone via USB
2. In AltServer menu: Install App > Select the `.ipa`
3. App installs on your iPhone

## Step 5: First Launch

1. Open **AdBloX MESH** on your iPhone
2. Tap **Set Up Device** (or the QR icon)
3. Either scan the QR code from your AdBloX device, or enter its IP manually
4. Go to the **Connect** tab
5. Tap the big power button
6. Allow VPN configuration when iOS prompts
7. Switch to **Dashboard** tab — your device's web UI loads

## Auto-Refresh

AltStore refreshes apps every 7 days automatically:
- AltServer must be running on your computer
- Both devices on the same Wi-Fi
- If the app expires, open AltStore to refresh it

## Troubleshooting

**"Could not find AltServer"**
- AltServer must be running on your Mac/PC
- Same Wi-Fi network as your iPhone

**VPN won't connect**
- Settings > General > VPN & Device Management — check profile exists
- Try deleting the VPN profile and reconnecting from the app

**Dashboard won't load**
- Verify you're connected (green dot on Connect tab)
- Check the device IP in Settings
- Test in Safari: `http://[device-ip]`

**App expired after 7 days**
- Connect to same Wi-Fi as your computer (with AltServer running)
- Open AltStore > tap refresh
