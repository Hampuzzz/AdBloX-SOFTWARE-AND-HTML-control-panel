/**
 * AdBloX Dashboard Configuration
 * ================================
 * Single source of truth for version and settings.
 * The update script on the device patches THIS file —
 * every page reads from here, so the whole UI stays in sync.
 */
const ADBLOX_CONFIG = {
    version: "1.9.3",
    buildDate: "2026-02-14",
    product: "AdBloX",
    edition: "Pro",
    deviceApi: "/api",          // relative to adblox.local
    refreshInterval: 5000,      // stats polling (ms)
};
