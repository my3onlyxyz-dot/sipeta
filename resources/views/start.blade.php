<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Deck — Start Page</title>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body x-data="deck" @keydown.window="hotkeys($event)">
<div class="min-h-screen flex flex-col max-w-[1200px] mx-auto px-3 sm:px-6">
  <div class="flex items-center gap-2 pt-3">
    <div class="hidden sm:flex items-center gap-1.5 pr-2 pl-1">
      <span class="w-3 h-3 rounded-full" style="background:#ff5f57"></span>
      <span class="w-3 h-3 rounded-full" style="background:#febc2e"></span>
      <span class="w-3 h-3 rounded-full" style="background:#28c840"></span>
    </div>
    <div class="flex items-end gap-1 overflow-x-auto scroll-x flex-1">
      <template x-for="tab in tabs" :key="tab.id">
        <button @click="active=tab.id"
          class="group relative flex items-center gap-2 shrink-0 max-w-[190px] pl-3 pr-2 py-2 rounded-t-lg text-sm transition-colors"
          :class="active===tab.id ? 'bg-[var(--surface-2)] text-[var(--text)]' : 'bg-transparent text-[var(--muted)] hover:bg-[var(--surface)]'">
          <span class="absolute left-3 right-3 top-0 h-[2px] rounded-full transition-opacity" style="background:var(--accent)" :class="active===tab.id ? 'opacity-100' : 'opacity-0'"></span>
          <span class="w-2 h-2 rounded-full shrink-0" :style="`background:${tab.dot}`"></span>
          <span class="truncate font-medium" x-text="tab.title"></span>
          <span @click.stop="closeTab(tab.id)" class="ml-1 w-5 h-5 grid place-items-center rounded text-[var(--faint)] opacity-0 group-hover:opacity-100 hover:bg-[var(--surface-3)] hover:text-[var(--text)] transition">✕</span>
        </button>
      </template>
      <button @click="addTab()" title="Tab baru" class="shrink-0 w-8 h-8 mb-1 ml-0.5 grid place-items-center rounded-lg text-[var(--muted)] hover:bg-[var(--surface)] hover:text-[var(--text)] text-lg leading-none transition">+</button>
    </div>
    <button class="hidden sm:grid place-items-center w-8 h-8 rounded-lg text-[var(--muted)] hover:bg-[var(--surface)] hover:text-[var(--text)] transition" title="Pengaturan">⚙</button>
  </div>

  <div class="flex items-center gap-2 bg-[var(--surface-2)] rounded-xl p-2">
    <div class="flex items-center gap-0.5 px-1 text-[var(--muted)]">
      <button class="w-8 h-8 grid place-items-center rounded-lg hover:bg-[var(--surface-3)] hover:text-[var(--text)] transition" title="Mundur">‹</button>
      <button class="w-8 h-8 grid place-items-center rounded-lg hover:bg-[var(--surface-3)] hover:text-[var(--text)] transition" title="Maju">›</button>
      <button @click="reload()" class="w-8 h-8 grid place-items-center rounded-lg hover:bg-[var(--surface-3)] hover:text-[var(--text)] transition" title="Muat ulang">⟳</button>
    </div>
    <div class="flex-1 flex items-center gap-2 bg-[var(--ink)] rounded-lg px-3 h-10 ring-1 ring-transparent focus-within:ring-[var(--accent)] transition">
      <span class="font-code text-[var(--accent)] select-none">›</span>
      <input x-ref="omni" x-model="query" @focus="focused=true" @blur="focused=false" @keydown.enter="go()" placeholder="Cari atau ketik alamat" class="flex-1 bg-transparent outline-none font-code text-sm text-[var(--text)] placeholder:text-[var(--faint)]">
      <button @click="cycleEngine()" class="font-code text-xs px-2 py-1 rounded-md bg-[var(--surface-2)] text-[var(--muted)] hover:text-[var(--text)] transition shrink-0"><span x-text="engine"></span> ▾</button>
    </div>
    <kbd class="hidden md:block font-code text-[11px] text-[var(--faint)] border border-[var(--line)] rounded px-1.5 py-1 mr-1" x-text="hotkeyLabel"></kbd>
  </div>

  <main class="flex-1 py-10 sm:py-14">
    <header class="flex flex-wrap items-end justify-between gap-4 mb-12">
      <div>
        <div class="font-display font-bold tracking-tight leading-none text-[64px] sm:text-[88px]">
          <span x-text="hh"></span><span class="text-[var(--accent)]" :class="blink?'opacity-100':'opacity-30'">:</span><span x-text="mm"></span>
        </div>
        <p class="font-code text-sm text-[var(--muted)] mt-2" x-text="dateStr"></p>
      </div>
      <p class="font-display text-xl sm:text-2xl text-[var(--muted)]"><span x-text="greeting"></span>, <span class="text-[var(--text)]">Sahrul</span>.</p>
    </header>

    <section class="mb-12">
      <h2 class="font-code text-xs tracking-[0.2em] text-[var(--faint)] uppercase mb-4">Quick launch</h2>
      <div class="grid grid-cols-3 sm:grid-cols-4 lg:grid-cols-6 gap-3">
        <template x-for="s in shortcuts" :key="s.label">
          <a :href="s.url" target="_blank" rel="noopener" class="tile group flex flex-col items-center justify-center gap-2.5 aspect-[5/4] rounded-xl bg-[var(--surface)] ring-1 ring-[var(--line)] hover:ring-[var(--accent)] hover:-translate-y-0.5 transition-all">
            <span class="mono font-display font-bold text-2xl w-11 h-11 grid place-items-center rounded-lg transition-colors" :style="`background:${s.tint};color:${s.fg}`" x-text="s.label.charAt(0)"></span>
            <span class="text-xs text-[var(--muted)] group-hover:text-[var(--text)] transition-colors" x-text="s.label"></span>
          </a>
        </template>
        <button class="flex flex-col items-center justify-center gap-2.5 aspect-[5/4] rounded-xl border border-dashed border-[var(--line)] text-[var(--faint)] hover:border-[var(--muted)] hover:text-[var(--muted)] transition">
          <span class="text-2xl leading-none">+</span><span class="text-xs">Tambah</span>
        </button>
      </div>
    </section>

    <section>
      <h2 class="font-code text-xs tracking-[0.2em] text-[var(--faint)] uppercase mb-4">Riwayat</h2>
      <ul class="divide-y divide-[var(--line)] rounded-xl overflow-hidden bg-[var(--surface)] ring-1 ring-[var(--line)]">
        <template x-for="r in recent" :key="r.url">
          <li><a :href="r.url" target="_blank" rel="noopener" class="flex items-center gap-3 px-4 py-3 hover:bg-[var(--surface-2)] transition group">
            <span class="w-2 h-2 rounded-full shrink-0" :style="`background:${r.dot}`"></span>
            <span class="text-sm text-[var(--text)] truncate" x-text="r.title"></span>
            <span class="font-code text-xs text-[var(--faint)] truncate hidden sm:block" x-text="r.url"></span>
            <span class="font-code text-xs text-[var(--faint)] ml-auto shrink-0" x-text="r.time"></span>
          </a></li>
        </template>
      </ul>
    </section>
  </main>

  <footer class="font-code text-[11px] text-[var(--faint)] py-5 text-center">Deck · tekan <span class="text-[var(--muted)]" x-text="hotkeyLabel"></span> buat fokus ke address bar</footer>
</div>
</body>
</html>
