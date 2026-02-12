# AdBloX MESH

DNS-level ad blocking across your entire network with mesh VPN connectivity.

## Components

### Web Dashboard (`dashboard/`)
Control panel served at `mesh.adblox.se`. Manage devices, blocklists, DNS query logs, and mesh settings. Plain HTML/CSS/JS — no build tools required.

Open `dashboard/index.html` in a browser to preview with mock data.

### iOS App (`ios/`)
SwiftUI app with Tailscale Go core for mesh VPN and Network Extension for on-device DNS filtering. Supports QR code device enrollment.

### Phase Roadmap

| Phase | Target | Description |
|-------|--------|-------------|
| 1 | Android | Fork Tailscale Android (BSD-3-Clause), rebrand, Play Store |
| 2 | iOS | SwiftUI + Tailscale Go core + Network Extension, App Store |
| 3 | Web | Dashboard at mesh.adblox.se with QR code enrollment |

## Quick Start

```bash
# Dashboard — just open in browser
open dashboard/index.html

# iOS — open in Xcode
open ios/AdBloX.xcodeproj
```

## License

BSD 3-Clause — see [LICENSE](LICENSE)
