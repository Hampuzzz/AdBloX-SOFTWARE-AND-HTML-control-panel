# AdBloX MESH — API Specification

Base URL: `https://mesh.adblox.se/api`

Authentication: `X-Mesh-Token` header (Tailscale identity)

## Endpoints

### GET /api/stats
Returns overview statistics.

```json
{
  "queries_today": 12847,
  "blocked_today": 3291,
  "blocked_percent": 25.6,
  "devices_online": 4,
  "devices_total": 6,
  "uptime_seconds": 864000,
  "queries_over_time": [
    {"hour": "00:00", "total": 320, "blocked": 85}
  ],
  "recent_activity": [
    {"domain": "ads.google.com", "status": "blocked", "time": "2 min ago", "device": "MacBook Pro"}
  ]
}
```

### GET /api/devices
Returns all mesh devices.

```json
{
  "devices": [
    {
      "id": "node-abc123",
      "hostname": "MacBook Pro",
      "ip": "100.64.0.1",
      "os": "macos",
      "online": true,
      "last_seen": "2026-02-12T10:30:00Z",
      "queries_today": 4200,
      "blocked_today": 1100
    }
  ]
}
```

### GET /api/blocklists
Returns configured blocklists.

```json
{
  "lists": [
    {
      "id": "default",
      "name": "AdBloX Default",
      "description": "Core ad-blocking rules",
      "url": "https://rules.adblox.se/default.txt",
      "entries": 145000,
      "enabled": true,
      "updated": "2026-02-10T06:00:00Z"
    }
  ]
}
```

### POST /api/blocklists/:id/toggle
Toggle a blocklist on/off.

**Body:** `{"enabled": true}`

### GET /api/querylog?page=1
Returns paginated DNS query log.

```json
{
  "total": 12847,
  "page": 1,
  "per_page": 50,
  "entries": [
    {
      "timestamp": "2026-02-12T10:30:15Z",
      "domain": "ads.google.com",
      "type": "A",
      "status": "blocked",
      "device": "MacBook Pro",
      "list": "AdBloX Default"
    }
  ]
}
```

### GET /api/ping
Health check. Returns `{"ok": true}`.
