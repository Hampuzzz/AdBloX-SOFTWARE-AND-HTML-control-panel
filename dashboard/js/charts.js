/**
 * AdBloX Dashboard — Canvas 2D Charts
 * Lightweight charts with no external dependencies.
 */

document.addEventListener('DOMContentLoaded', () => {
    drawQueriesChart();
    drawBlockedChart();
});

function drawQueriesChart() {
    const canvas = document.getElementById('chart-queries');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;

    canvas.width = canvas.offsetWidth * dpr;
    canvas.height = canvas.offsetHeight * dpr;
    ctx.scale(dpr, dpr);

    const w = canvas.offsetWidth;
    const h = canvas.offsetHeight;
    const padding = { top: 10, right: 10, bottom: 24, left: 40 };

    // Mock 24h data
    const data = [
        1200, 980, 750, 420, 310, 280, 350, 890, 1800, 2400, 2800, 3100,
        2900, 2700, 3200, 3500, 3100, 2800, 2200, 1900, 1700, 1500, 1400, 1300
    ];
    const max = Math.max(...data) * 1.15;

    const chartW = w - padding.left - padding.right;
    const chartH = h - padding.top - padding.bottom;
    const stepX = chartW / (data.length - 1);

    // Grid lines
    ctx.strokeStyle = '#1a1a1a';
    ctx.lineWidth = 1;
    for (let i = 0; i <= 4; i++) {
        const y = padding.top + (chartH / 4) * i;
        ctx.beginPath();
        ctx.moveTo(padding.left, y);
        ctx.lineTo(w - padding.right, y);
        ctx.stroke();

        ctx.fillStyle = '#444';
        ctx.font = '10px -apple-system, sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText(Math.round(max - (max / 4) * i).toLocaleString(), padding.left - 6, y + 3);
    }

    // Area fill
    const gradient = ctx.createLinearGradient(0, padding.top, 0, h - padding.bottom);
    gradient.addColorStop(0, 'rgba(0, 212, 255, 0.2)');
    gradient.addColorStop(1, 'rgba(0, 212, 255, 0)');

    ctx.beginPath();
    ctx.moveTo(padding.left, h - padding.bottom);
    data.forEach((val, i) => {
        const x = padding.left + i * stepX;
        const y = padding.top + chartH - (val / max) * chartH;
        if (i === 0) ctx.lineTo(x, y);
        else ctx.lineTo(x, y);
    });
    ctx.lineTo(padding.left + (data.length - 1) * stepX, h - padding.bottom);
    ctx.closePath();
    ctx.fillStyle = gradient;
    ctx.fill();

    // Line
    ctx.beginPath();
    data.forEach((val, i) => {
        const x = padding.left + i * stepX;
        const y = padding.top + chartH - (val / max) * chartH;
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    });
    ctx.strokeStyle = '#00d4ff';
    ctx.lineWidth = 2;
    ctx.stroke();

    // X-axis labels
    ctx.fillStyle = '#444';
    ctx.font = '9px -apple-system, sans-serif';
    ctx.textAlign = 'center';
    for (let i = 0; i < data.length; i += 4) {
        const x = padding.left + i * stepX;
        ctx.fillText(i + ':00', x, h - 4);
    }
}

function drawBlockedChart() {
    const canvas = document.getElementById('chart-blocked');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;

    canvas.width = canvas.offsetWidth * dpr;
    canvas.height = canvas.offsetHeight * dpr;
    ctx.scale(dpr, dpr);

    const w = canvas.offsetWidth;
    const h = canvas.offsetHeight;
    const padding = { top: 10, right: 10, bottom: 24, left: 40 };

    // Mock blocked data
    const allowed = [
        900, 720, 550, 310, 230, 210, 260, 660, 1340, 1780, 2080, 2300,
        2150, 2000, 2370, 2590, 2300, 2070, 1630, 1410, 1260, 1110, 1040, 960
    ];
    const blocked = [
        300, 260, 200, 110, 80, 70, 90, 230, 460, 620, 720, 800,
        750, 700, 830, 910, 800, 730, 570, 490, 440, 390, 360, 340
    ];

    const max = Math.max(...allowed.map((a, i) => a + blocked[i])) * 1.15;
    const chartW = w - padding.left - padding.right;
    const chartH = h - padding.top - padding.bottom;
    const barW = (chartW / allowed.length) * 0.7;
    const gap = (chartW / allowed.length) * 0.3;

    // Grid
    ctx.strokeStyle = '#1a1a1a';
    ctx.lineWidth = 1;
    for (let i = 0; i <= 4; i++) {
        const y = padding.top + (chartH / 4) * i;
        ctx.beginPath();
        ctx.moveTo(padding.left, y);
        ctx.lineTo(w - padding.right, y);
        ctx.stroke();

        ctx.fillStyle = '#444';
        ctx.font = '10px -apple-system, sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText(Math.round(max - (max / 4) * i).toLocaleString(), padding.left - 6, y + 3);
    }

    // Stacked bars
    allowed.forEach((aVal, i) => {
        const bVal = blocked[i];
        const x = padding.left + i * (barW + gap) + gap / 2;

        // Allowed (bottom)
        const aH = (aVal / max) * chartH;
        const bH = (bVal / max) * chartH;

        ctx.fillStyle = 'rgba(0, 212, 255, 0.4)';
        ctx.beginPath();
        ctx.roundRect(x, padding.top + chartH - aH - bH, barW, aH, [2, 2, 0, 0]);
        ctx.fill();

        // Blocked (top)
        ctx.fillStyle = 'rgba(255, 82, 82, 0.6)';
        ctx.beginPath();
        ctx.roundRect(x, padding.top + chartH - bH, barW, bH, [0, 0, 2, 2]);
        ctx.fill();
    });

    // X-axis
    ctx.fillStyle = '#444';
    ctx.font = '9px -apple-system, sans-serif';
    ctx.textAlign = 'center';
    for (let i = 0; i < allowed.length; i += 4) {
        const x = padding.left + i * (barW + gap) + barW / 2;
        ctx.fillText(i + ':00', x, h - 4);
    }
}
