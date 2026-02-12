# AdBloX MESH — Architecture

## System Overview

```
                    ┌─────────────────────────┐
                    │    mesh.adblox.se        │
                    │    (Web Dashboard)       │
                    │    HTML/CSS/JS           │
                    └───────────┬──────────────┘
                                │ REST API
                    ┌───────────┴──────────────┐
                    │    AdBloX Service         │
                    │    (Linux daemon)         │
                    │    DNS Filtering Engine   │
                    └───────────┬──────────────┘
                                │ Tailscale Mesh VPN
            ┌───────────────────┼───────────────────┐
            │                   │                   │
    ┌───────┴───────┐   ┌───────┴───────┐   ┌──────┴────────┐
    │  iOS App      │   │  Android App  │   │  Desktop      │
    │  SwiftUI +    │   │  Tailscale    │   │  Tailscale    │
    │  Network Ext  │   │  Fork         │   │  Client       │
    └───────────────┘   └───────────────┘   └───────────────┘
```

## Components

### 1. Web Dashboard (`dashboard/`)
- Static HTML/CSS/JS served at mesh.adblox.se
- No build tools or frameworks
- Communicates with AdBloX backend via REST API
- Falls back to mock JSON data when no backend detected

### 2. iOS App (`ios/`)
- **Main App Target** (`AdBloX/`): SwiftUI app with MVVM architecture
  - `TailscaleManager`: Manages VPN via NETunnelProviderManager
  - `APIClient`: REST client to mesh.adblox.se
  - `DNSFilterService`: Coordinates with Network Extension
- **Network Extension** (`AdBloXNetworkExtension/`): Separate process
  - `PacketTunnelProvider`: Intercepts DNS queries
  - `DNSResolver`: Blocklist lookup and response generation
  - Shares data with main app via App Group container

### 3. AdBloX Service (Linux)
- Runs as systemd service (`adblox.service`)
- Watchdog process (`adblox-watchdog.service`)
- Rules guard to prevent filter tampering
- Configured via `adblox.yaml`
- Tailscale integration for mesh connectivity

## Data Flow

1. Device joins mesh via QR code (Tailscale auth key)
2. All DNS queries route through AdBloX service
3. Service checks against blocklists, blocks matching domains
4. Stats and logs sent to dashboard via REST API
5. iOS Network Extension provides local DNS filtering as fallback
