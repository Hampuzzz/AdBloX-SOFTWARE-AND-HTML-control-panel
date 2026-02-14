/**
 * AdBloX Dashboard — Core JS
 * Handles version injection, sidebar navigation, and mobile menu.
 */

document.addEventListener('DOMContentLoaded', () => {
    injectVersion();
    initSidebar();
});

// ===== Version Injection =====
// Reads from ADBLOX_CONFIG (config.js) so every page stays in sync.
function injectVersion() {
    const v = ADBLOX_CONFIG.version;

    // Sidebar version badge
    const sidebarVersion = document.getElementById('sidebar-version');
    if (sidebarVersion) sidebarVersion.textContent = 'v' + v;

    // Sidebar footer
    const footerVersion = document.getElementById('sidebar-footer-version');
    if (footerVersion) footerVersion.textContent = ADBLOX_CONFIG.product + ' ' + ADBLOX_CONFIG.edition + ' v' + v;

    // Feature cards that show version
    const featureYt = document.getElementById('feature-yt-version');
    if (featureYt) featureYt.textContent = 'v' + v;

    // Settings page version fields
    const settingsVersion = document.getElementById('settings-version');
    if (settingsVersion) settingsVersion.textContent = v + ' ' + ADBLOX_CONFIG.edition;

    const settingsBuild = document.getElementById('settings-build');
    if (settingsBuild) settingsBuild.textContent = ADBLOX_CONFIG.buildDate;

    // Update tab version
    const updateVersion = document.getElementById('update-version');
    if (updateVersion) updateVersion.textContent = 'v' + v;

    const updateVersionLarge = document.getElementById('update-version-large');
    if (updateVersionLarge) updateVersionLarge.textContent = 'v' + v;

    // Any element with data-version attribute
    document.querySelectorAll('[data-version]').forEach(el => {
        el.textContent = el.dataset.version === 'full'
            ? ADBLOX_CONFIG.product + ' v' + v
            : 'v' + v;
    });
}

// ===== Sidebar =====
function initSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const menuBtn = document.getElementById('mobile-menu-btn');

    if (menuBtn) {
        menuBtn.addEventListener('click', () => {
            sidebar.classList.toggle('open');
            overlay.classList.toggle('open');
        });
    }

    if (overlay) {
        overlay.addEventListener('click', () => {
            sidebar.classList.remove('open');
            overlay.classList.remove('open');
        });
    }
}
