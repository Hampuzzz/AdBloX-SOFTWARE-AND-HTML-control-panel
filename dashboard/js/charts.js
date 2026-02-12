// AdBloX MESH — Lightweight Canvas 2D chart

class MeshChart {
  constructor(canvas, options = {}) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.data = [];
    this.options = Object.assign({
      lineColor: '#00d4ff',
      lineColorSecondary: '#ff4466',
      fillColor: 'rgba(0, 212, 255, 0.08)',
      gridColor: 'rgba(255, 255, 255, 0.05)',
      labelColor: '#888888',
      lineWidth: 2,
      padding: { top: 20, right: 20, bottom: 40, left: 50 },
      showSecondLine: true
    }, options);

    this._resizeObserver = new ResizeObserver(() => this._handleResize());
    this._resizeObserver.observe(canvas.parentElement);
    this._handleResize();
  }

  setData(points) {
    this.data = points;
    this.render();
  }

  render() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;
    const p = this.options.padding;
    const cw = w - p.left - p.right;
    const ch = h - p.top - p.bottom;

    ctx.clearRect(0, 0, w, h);

    if (!this.data.length) return;

    const maxTotal = Math.max(...this.data.map(d => d.total)) * 1.1;

    // Grid lines
    ctx.strokeStyle = this.options.gridColor;
    ctx.lineWidth = 1;
    const gridLines = 5;
    for (let i = 0; i <= gridLines; i++) {
      const y = p.top + (ch / gridLines) * i;
      ctx.beginPath();
      ctx.moveTo(p.left, y);
      ctx.lineTo(w - p.right, y);
      ctx.stroke();

      // Y labels
      const val = Math.round(maxTotal - (maxTotal / gridLines) * i);
      ctx.fillStyle = this.options.labelColor;
      ctx.font = '11px Inter, sans-serif';
      ctx.textAlign = 'right';
      ctx.fillText(formatNumber(val), p.left - 8, y + 4);
    }

    // X labels
    ctx.textAlign = 'center';
    const step = Math.max(1, Math.floor(this.data.length / 8));
    for (let i = 0; i < this.data.length; i += step) {
      const x = p.left + (cw / (this.data.length - 1)) * i;
      ctx.fillStyle = this.options.labelColor;
      ctx.fillText(this.data[i].hour, x, h - p.bottom + 20);
    }

    // Helper to draw a line
    const drawLine = (key, color, fill) => {
      ctx.beginPath();
      for (let i = 0; i < this.data.length; i++) {
        const x = p.left + (cw / (this.data.length - 1)) * i;
        const y = p.top + ch - (this.data[i][key] / maxTotal) * ch;
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.strokeStyle = color;
      ctx.lineWidth = this.options.lineWidth;
      ctx.stroke();

      if (fill) {
        // Fill area under line
        const last = this.data.length - 1;
        ctx.lineTo(p.left + cw, p.top + ch);
        ctx.lineTo(p.left, p.top + ch);
        ctx.closePath();
        ctx.fillStyle = fill;
        ctx.fill();
      }
    };

    // Draw total line with fill
    drawLine('total', this.options.lineColor, this.options.fillColor);

    // Draw blocked line
    if (this.options.showSecondLine) {
      drawLine('blocked', this.options.lineColorSecondary, 'rgba(255, 68, 102, 0.05)');
    }
  }

  _handleResize() {
    const rect = this.canvas.parentElement.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;
    this.canvas.width = rect.width * dpr;
    this.canvas.height = rect.height * dpr;
    this.canvas.style.width = rect.width + 'px';
    this.canvas.style.height = rect.height + 'px';
    this.ctx.scale(dpr, dpr);
    // Reset canvas logical size for drawing
    this.canvas.width = rect.width;
    this.canvas.height = rect.height;
    if (this.data.length) this.render();
  }

  destroy() {
    this._resizeObserver.disconnect();
  }
}
