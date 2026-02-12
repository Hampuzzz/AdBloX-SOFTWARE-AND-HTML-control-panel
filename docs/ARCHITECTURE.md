# AdBloX MESH iOS — Architecture

## How It Works

```
┌─────────────────────────────────────────────────┐
│  iPhone                                         │
│                                                 │
│  AdBloX MESH App (SwiftUI)                      │
│  ├── ConnectView      → Big power button        │
│  ├── DashboardWebView → WKWebView to device     │
│  ├── NodesView        → Mesh peer list          │
│  └── SettingsView     → VPN config              │
│                                                 │
│  VPNManager (NETunnelProviderManager)            │
│  └── Establishes VPN tunnel to AdBloX device    │
│                                                 │
│  AdBloXNetworkExtension (separate process)       │
│  ├── PacketTunnelProvider → DNS interception     │
│  └── DNSResolver → blocklist matching            │
│                                                 │
└────────────────────┬────────────────────────────┘
                     │ VPN Tunnel
                     │ (all DNS traffic)
                     v
┌─────────────────────────────────────────────────┐
│  AdBloX Device (Raspberry Pi / Linux server)     │
│                                                 │
│  adblox service (systemd)                        │
│  ├── DNS filtering engine                        │
│  ├── Web dashboard (HTTP)                        │
│  ├── Tailscale mesh VPN                          │
│  └── adblox-watchdog (keeps it running)          │
│                                                 │
└─────────────────────────────────────────────────┘
```

## App Flow

1. **First launch**: User scans QR code or enters AdBloX device IP
2. **Connect**: VPN tunnel established via `NETunnelProviderManager`
3. **DNS routing**: All DNS queries from iPhone → through tunnel → AdBloX device
4. **Ad blocking**: AdBloX device checks queries against blocklists, returns 0.0.0.0 for blocked domains
5. **Dashboard access**: WebView loads `http://[device-ip]` through the tunnel

## Key Files

| File | Purpose |
|------|---------|
| `VPNManager.swift` | Core VPN logic — connect, disconnect, status monitoring, device configuration |
| `ConnectView.swift` | Main UI — power button, traffic stats, connection status |
| `DashboardWebView.swift` | WKWebView that loads device dashboard when connected |
| `DeviceSetupView.swift` | QR scanner + manual IP entry for initial setup |
| `NodesView.swift` | List of mesh peers (like Tailscale's device list) |
| `PacketTunnelProvider.swift` | Network Extension: intercepts and filters DNS |
| `DNSResolver.swift` | Blocklist lookup, creates blocked DNS responses |

## Distribution

Distributed via **AltStore** (sideloading):
- Built as IPA in Xcode
- Installed via AltStore on iPhone
- Auto-refreshes every 7 days via AltServer
- No App Store or developer account needed (free Apple ID works)

See [ALTSTORE.md](ALTSTORE.md) for installation instructions.
