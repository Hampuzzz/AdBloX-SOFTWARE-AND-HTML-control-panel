# AdBloX MESH — iOS App

iOS app that works like Tailscale. Connect to your AdBloX device, all DNS traffic routes through it (ads blocked everywhere), and access the device's dashboard right from the app.

## How It Works

```
iPhone (this app)
  |
  |-- VPN Tunnel (NETunnelProvider)
  |
  v
AdBloX Device (Raspberry Pi / Linux)
  |-- DNS filtering (blocks ads, trackers, malware)
  |-- Web dashboard (accessible through the app)
  |-- Mesh network (Tailscale)
```

1. **Connect** — Tap the power button to establish a VPN tunnel to your AdBloX device
2. **Dashboard** — Once connected, the Dashboard tab loads your device's web UI
3. **Nodes** — See all devices on the mesh network
4. **Settings** — Configure device IP, view connection stats

## Get the IPA (No Mac Needed)

The IPA builds automatically via GitHub Actions on every push:

1. Go to **Actions** tab in this repo
2. Click the latest **Build AdBloX MESH IPA** run
3. Download the **AdBloX-MESH-IPA** artifact
4. Unzip — you get `AdBloX-MESH-v1.9.3.ipa`

Or trigger a build manually: Actions > Build AdBloX MESH IPA > Run workflow

## Install via AltStore

See [docs/ALTSTORE.md](docs/ALTSTORE.md) for full instructions.

1. Transfer the `.ipa` to your iPhone (AirDrop, email, iCloud Drive)
2. Open the file on iPhone, choose "Open in AltStore"
3. AltStore signs and installs it
4. Refreshes automatically every 7 days

## App Structure

```
ios/AdBloX/
├── AdBloXApp.swift              # Entry point, tab bar
├── Extensions/Color+AdBloX.swift # Brand colors (#0a0a0a bg, #00d4ff cyan)
├── Services/VPNManager.swift     # VPN tunnel (like Tailscale)
└── Views/
    ├── ConnectView.swift         # Main: big power button
    ├── DashboardWebView.swift    # WebView → device dashboard
    ├── DeviceSetupView.swift     # QR scanner + manual IP
    ├── NodesView.swift           # Mesh peers
    └── SettingsView.swift        # Config, about, reset

ios/AdBloXNetworkExtension/
├── PacketTunnelProvider.swift    # DNS interception
└── DNSResolver.swift             # Blocklist matching
```

## License

BSD 3-Clause — see [LICENSE](LICENSE)
