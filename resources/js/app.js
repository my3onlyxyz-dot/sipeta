import Alpine from 'alpinejs';
window.Alpine = Alpine;

document.addEventListener('alpine:init', () => {
  Alpine.data('deck', () => ({
    tabs: [
      { id: 1, title: 'New Tab',        dot: '#ffb454' },
      { id: 2, title: 'GitHub — myapp', dot: '#8b949e' },
      { id: 3, title: 'Laravel Docs',   dot: '#ef4444' },
    ],
    active: 1, nextId: 4,
    addTab() { const id = this.nextId++; this.tabs.push({ id, title: 'New Tab', dot: '#ffb454' }); this.active = id; this.$nextTick(() => this.$refs.omni.focus()); },
    closeTab(id) { const i = this.tabs.findIndex(t => t.id === id); this.tabs.splice(i, 1); if (!this.tabs.length) { this.addTab(); return; } if (this.active === id) this.active = this.tabs[Math.max(0, i - 1)].id; },
    reload() {},

    query: '', focused: false,
    engines: ['Google', 'DuckDuckGo', 'Bing'], engineIdx: 0,
    get engine() { return this.engines[this.engineIdx]; },
    cycleEngine() { this.engineIdx = (this.engineIdx + 1) % this.engines.length; this.$refs.omni.focus(); },
    go() { const q = this.query.trim(); if (!q) return; const t = this.tabs.find(x => x.id === this.active); if (t) { t.title = q.length > 22 ? q.slice(0, 22) + '…' : q; t.dot = '#56d4dd'; } this.query = ''; },

    hh: '00', mm: '00', blink: true, dateStr: '', greeting: '',
    tick() {
      const d = new Date();
      this.hh = String(d.getHours()).padStart(2, '0');
      this.mm = String(d.getMinutes()).padStart(2, '0');
      this.blink = d.getSeconds() % 2 === 0;
      this.dateStr = d.toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
      const h = d.getHours();
      this.greeting = h < 5 ? 'Selamat dini hari' : h < 11 ? 'Selamat pagi' : h < 15 ? 'Selamat siang' : h < 19 ? 'Selamat sore' : 'Selamat malam';
    },

    get hotkeyLabel() { return navigator.platform.includes('Mac') ? '⌘K' : 'Ctrl K'; },
    hotkeys(e) {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); this.$refs.omni.focus(); this.$refs.omni.select(); }
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 't') { e.preventDefault(); this.addTab(); }
    },

    shortcuts: [
      { label: 'GitHub',  url: 'https://github.com',      tint: 'rgba(139,148,158,.15)', fg: '#e6edf3' },
      { label: 'Laravel', url: 'https://laravel.com',     tint: 'rgba(239,68,68,.15)',   fg: '#ef4444' },
      { label: 'YouTube', url: 'https://youtube.com',     tint: 'rgba(239,68,68,.15)',   fg: '#ef4444' },
      { label: 'Gmail',   url: 'https://mail.google.com', tint: 'rgba(255,180,84,.15)',  fg: '#ffb454' },
      { label: 'Reddit',  url: 'https://reddit.com',      tint: 'rgba(255,128,64,.15)',  fg: '#ff8040' },
      { label: 'XDA',     url: 'https://xdaforums.com',   tint: 'rgba(86,212,221,.15)',  fg: '#56d4dd' },
    ],
    recent: [
      { title: 'Tailwind v4 — Vite plugin',  url: 'tailwindcss.com/docs/installation/vite', dot: '#56d4dd', time: '19:42' },
      { title: 'KernelSU · Releases',        url: 'github.com/tiann/KernelSU/releases',      dot: '#8b949e', time: '18:10' },
      { title: 'Play Integrity API checker', url: 'play.google.com/console',                 dot: '#28c840', time: '16:55' },
      { title: 'Flutter — proot setup',      url: 'docs.flutter.dev',                        dot: '#56d4dd', time: '14:08' },
    ],

    init() { this.tick(); setInterval(() => this.tick(), 1000); },
  }));
});

Alpine.start();
