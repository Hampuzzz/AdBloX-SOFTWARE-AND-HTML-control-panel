// AdBloX MESH — API client with mock data fallback

const API = {
  baseUrl: '/api',
  useMock: true,

  async init() {
    try {
      const res = await fetch(this.baseUrl + '/ping', { signal: AbortSignal.timeout(2000) });
      if (res.ok) { this.useMock = false; return; }
    } catch (e) { /* fall through to mock */ }
    this.useMock = true;
    console.log('[AdBloX] Using mock data (no backend detected)');
  },

  async get(path) {
    if (this.useMock) return this._getMock(path);
    const res = await fetch(this.baseUrl + path, { headers: this._headers() });
    if (!res.ok) throw new Error('API error: ' + res.status);
    return res.json();
  },

  async post(path, body) {
    if (this.useMock) return { success: true };
    const res = await fetch(this.baseUrl + path, {
      method: 'POST',
      headers: this._headers(),
      body: JSON.stringify(body)
    });
    if (!res.ok) throw new Error('API error: ' + res.status);
    return res.json();
  },

  _headers() {
    return {
      'Content-Type': 'application/json',
      'X-Mesh-Token': localStorage.getItem('mesh_token') || ''
    };
  },

  async _getMock(path) {
    const mockMap = {
      '/stats': 'mock/stats.json',
      '/devices': 'mock/devices.json',
      '/blocklists': 'mock/blocklists.json',
      '/querylog': 'mock/querylog.json'
    };
    const file = mockMap[path];
    if (!file) return {};
    const res = await fetch(file);
    return res.json();
  }
};
