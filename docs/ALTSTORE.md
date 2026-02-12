# Installing AdBloX MESH via AltStore

AltStore lets you install apps on your iPhone without the App Store. The app refreshes automatically every 7 days as long as AltServer is running on your Mac or PC.

## Prerequisites

- iPhone running iOS 16.0 or later
- Mac or Windows PC on the same Wi-Fi network (for AltServer)
- Apple ID (free works, no developer account needed)
- No Mac needed to build — the IPA builds automatically via GitHub Actions

## Step 1: Download the IPA

**Option A — From GitHub Actions (automated, no Mac needed):**
1. Go to the repo's **Actions** tab on GitHub
2. Click the latest **Build AdBloX MESH IPA** workflow run
3. Scroll down to **Artifacts** and download **AdBloX-MESH-IPA**
4. Unzip the download — you get `AdBloX-MESH-v1.8.2.ipa`

**Option B — From Releases:**
- If a release exists, download `AdBloX-MESH-v1.8.2.ipa` from the Releases page

## Step 2: Install AltServer on your computer

**Mac:**
1. Download AltServer from https://altstore.io
2. Move to Applications folder
3. Launch AltServer — it appears in the menu bar

**Windows:**
1. Download AltServer from https://altstore.io
2. Install and run AltServer
3. Install iCloud for Windows from Apple (NOT from Microsoft Store)
4. AltServer appears in the system tray

## Step 3: Install AltStore on your iPhone

1. Connect iPhone to computer via USB
2. Trust the computer on your iPhone if prompted
3. In AltServer menu: Install AltStore > [Your iPhone]
4. Enter your Apple ID and password
5. AltStore appears on your iPhone home screen
6. On iPhone: Settings > General > VPN & Device Management > Trust your Apple ID

## Step 4: Install the IPA via AltStore

**Option A — AirDrop:**
1. AirDrop the `.ipa` file from your computer to your iPhone
2. Open the file, choose "Open in AltStore"
3. AltStore signs and installs it

**Option B — Via AltServer:**
1. Connect iPhone via USB
2. In AltServer menu: Install App > Select the `.ipa`
3. App installs on your iPhone

**Option C — Via iCloud Drive / Files:**
1. Put the `.ipa` in your iCloud Drive
2. On iPhone, open the Files app
3. Tap the `.ipa` file > "Open in AltStore"

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
