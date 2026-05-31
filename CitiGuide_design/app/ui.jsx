/* CitiGuide — shared UI primitives */
(function () {
  const { Icon, StarSolid } = window;
  const h = React.createElement;

  /* ── deterministic placeholder "photo" ──────────────────────
     A calm duotone wash + faint contour texture + category glyph.
     Intentional minimal placeholder system (no external images). */
  function Photo({ hue = 200, cat, label, round = 0, style = {}, dim = false, ratio }) {
    const a = `hsl(${hue} 26% 66%)`;
    const b = `hsl(${(hue + 22) % 360} 32% 43%)`;
    const wrap = {
      position: 'relative', width: '100%', height: ratio ? undefined : '100%',
      aspectRatio: ratio || undefined, borderRadius: round, overflow: 'hidden',
      background: `linear-gradient(140deg, ${a}, ${b})`, ...style,
    };
    return h('div', { style: wrap },
      // soft light
      h('div', { style: { position: 'absolute', inset: 0, background: 'radial-gradient(120% 90% at 18% 12%, rgba(255,255,255,.34), rgba(255,255,255,0) 55%)' } }),
      // contour texture
      h('svg', { width: '100%', height: '100%', viewBox: '0 0 200 140', preserveAspectRatio: 'xMidYMid slice', style: { position: 'absolute', inset: 0, opacity: .22 } },
        h('g', { fill: 'none', stroke: '#fff', strokeWidth: 1 },
          h('path', { d: 'M-10 40 C 40 20, 80 70, 130 48 S 220 30, 230 60' }),
          h('path', { d: 'M-10 70 C 40 50, 80 100, 130 78 S 220 60, 230 90' }),
          h('path', { d: 'M-10 100 C 40 80, 80 130, 130 108 S 220 90, 230 120' }),
        )
      ),
      // category glyph
      cat && h('div', { style: { position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: .5 } },
        h(Icon, { name: cat, size: 46, color: '#fff', stroke: 1.4 })
      ),
      dim && h('div', { style: { position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(8,28,42,0) 38%, rgba(8,28,42,.55))' } }),
      label && h('div', { style: {
        position: 'absolute', left: 10, bottom: 10, padding: '3px 8px', borderRadius: 7,
        background: 'rgba(8,28,42,.34)', backdropFilter: 'blur(4px)', color: 'rgba(255,255,255,.92)',
        fontSize: 9.5, letterSpacing: '.04em', fontFamily: 'var(--mono)', textTransform: 'uppercase',
      } }, label),
    );
  }

  /* ── star rating row ── */
  function Stars({ value = 0, size = 14, gap = 2, showVal = false, count }) {
    const full = Math.round(value);
    return h('div', { style: { display: 'inline-flex', alignItems: 'center', gap: 6 } },
      h('div', { style: { display: 'inline-flex', gap } },
        [0,1,2,3,4].map(i => h(StarSolid, { key: i, size, color: i < full ? 'var(--star)' : '#E2E7EB' }))
      ),
      showVal && h('span', { style: { fontSize: size - 1, fontWeight: 700, color: 'var(--ink)' } }, value.toFixed(1)),
      count != null && h('span', { style: { fontSize: size - 2, color: 'var(--muted)', fontWeight: 500 } }, `(${count})`),
    );
  }

  /* ── compact rating pill ── */
  function RatingBadge({ value, dark = false }) {
    return h('div', { style: {
      display: 'inline-flex', alignItems: 'center', gap: 4, padding: '4px 9px', borderRadius: 100,
      background: dark ? 'rgba(8,28,42,.5)' : '#fff', backdropFilter: dark ? 'blur(6px)' : 'none',
      boxShadow: dark ? 'none' : 'var(--sh-1)', fontSize: 12.5, fontWeight: 700,
      color: dark ? '#fff' : 'var(--ink)',
    } }, h(StarSolid, { size: 12 }), value.toFixed(1));
  }

  /* ── Android status bar (overlay) ── */
  function StatusBar({ tone = 'dark' }) {
    const c = tone === 'light' ? '#fff' : 'var(--ink)';
    return h('div', { style: {
      position: 'absolute', top: 0, left: 0, right: 0, height: 40, zIndex: 60,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 18px 0 22px', pointerEvents: 'none',
    } },
      h('span', { style: { fontSize: 14, fontWeight: 600, color: c, letterSpacing: '.01em' } }, '9:30'),
      h('div', { style: { display: 'flex', alignItems: 'center', gap: 6, color: c } },
        h(Icon, { name: 'wifi', size: 15, stroke: 2 }),
        h('svg', { width: 22, height: 12, viewBox: '0 0 26 13' },
          h('rect', { x: .6, y: .6, width: 22, height: 11.8, rx: 3, fill: 'none', stroke: c, strokeOpacity: .5 }),
          h('rect', { x: 2.2, y: 2.2, width: 16, height: 8.6, rx: 1.6, fill: c }),
          h('rect', { x: 23.4, y: 4, width: 2, height: 5, rx: 1, fill: c }),
        ),
      ),
    );
  }

  /* ── gesture nav pill (overlay) ── */
  function NavPill({ tone = 'dark' }) {
    return h('div', { style: {
      position: 'absolute', bottom: 7, left: 0, right: 0, height: 22, zIndex: 60,
      display: 'flex', alignItems: 'center', justifyContent: 'center', pointerEvents: 'none',
    } }, h('div', { style: {
      width: 132, height: 5, borderRadius: 3,
      background: tone === 'light' ? 'rgba(255,255,255,.85)' : 'rgba(21,32,43,.32)',
    } }));
  }

  /* ── the phone screen surface: status bar + screen + nav pill ── */
  function DeviceShell({ children, statusTone = 'dark', navTone = 'dark', bg = 'var(--bg)' }) {
    return h('div', { style: { position: 'relative', width: '100%', height: '100%', background: bg, overflow: 'hidden' } },
      h(StatusBar, { tone: statusTone }),
      h('div', { className: 'cg' }, children),
      h(NavPill, { tone: navTone }),
    );
  }

  /* ── simple top app bar (back + title + actions) ── */
  function TopBar({ title, onBack, right, transparent = false, sub }) {
    return h('div', { style: {
      paddingTop: 44, paddingBottom: 8, paddingLeft: 8, paddingRight: 8,
      display: 'flex', alignItems: 'center', gap: 4, flexShrink: 0,
      background: transparent ? 'transparent' : 'var(--bg)',
      borderBottom: transparent ? 'none' : '1px solid var(--line-2)',
    } },
      onBack && h('button', { onClick: onBack, 'aria-label': 'Back', style: iconBtn }, h(Icon, { name: 'arrowL', size: 23 })),
      h('div', { style: { flex: 1, minWidth: 0, paddingLeft: onBack ? 0 : 10 } },
        title && h('div', { className: 't-title', style: { fontSize: 18.5 } }, title),
        sub && h('div', { style: { fontSize: 12.5, color: 'var(--muted)', fontWeight: 500 } }, sub),
      ),
      right,
    );
  }
  const iconBtn = {
    width: 42, height: 42, borderRadius: 999, display: 'flex', alignItems: 'center',
    justifyContent: 'center', color: 'var(--ink)', flexShrink: 0,
  };

  /* ── bottom navigation ── */
  function BottomNav({ active, onNav }) {
    const items = [
      { id: 'home', icon: 'home', label: 'Explore' },
      { id: 'search', icon: 'search', label: 'Search' },
      { id: 'favourites', icon: 'heart', label: 'Saved' },
      { id: 'profile', icon: 'user', label: 'Profile' },
    ];
    return h('div', { style: {
      flexShrink: 0, display: 'flex', borderTop: '1px solid var(--line)', background: 'rgba(255,255,255,.92)',
      backdropFilter: 'blur(10px)', padding: '8px 6px 26px',
    } },
      items.map(it => {
        const on = active === it.id;
        return h('button', { key: it.id, onClick: () => onNav(it.id), style: {
          flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
          color: on ? 'var(--primary)' : 'var(--muted-2)', padding: '4px 0',
        } },
          h(Icon, { name: it.icon, size: 23, stroke: on ? 2.2 : 1.8, fill: on && it.id === 'favourites' ? 'var(--primary)' : 'none' }),
          h('span', { style: { fontSize: 11, fontWeight: on ? 700 : 600 } }, it.label),
        );
      })
    );
  }

  /* ── bottom sheet ── */
  function Sheet({ open, onClose, children, title, maxH = '82%' }) {
    if (!open) return null;
    return h('div', { style: { position: 'absolute', inset: 0, zIndex: 80 } },
      h('div', { onClick: onClose, className: 'anim-in', style: { position: 'absolute', inset: 0, background: 'rgba(15,25,33,.45)' } }),
      h('div', { className: 'sheet-pop', style: {
        position: 'absolute', left: 0, right: 0, bottom: 0, maxHeight: maxH,
        background: '#fff', borderRadius: '24px 24px 0 0', boxShadow: 'var(--sh-3)',
        display: 'flex', flexDirection: 'column', overflow: 'hidden',
      } },
        h('div', { style: { display: 'flex', justifyContent: 'center', paddingTop: 10 } },
          h('div', { style: { width: 40, height: 5, borderRadius: 3, background: 'var(--line)' } })),
        title && h('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 20px 6px' } },
          h('div', { className: 't-title', style: { fontSize: 19 } }, title),
          h('button', { onClick: onClose, style: iconBtn }, h(Icon, { name: 'x', size: 22 })),
        ),
        h('div', { style: { overflowY: 'auto', padding: '6px 20px 26px' } }, children),
      ),
    );
  }

  /* ── pill button (small) ── */
  function Pill({ icon, label, onClick, tone = 'ghost', style = {} }) {
    const tones = {
      ghost:   { background: 'var(--bg-alt-2)', color: 'var(--ink)' },
      primary: { background: 'var(--primary)', color: '#fff' },
      outline: { background: '#fff', color: 'var(--primary)', border: '1.5px solid var(--line)' },
    };
    return h('button', { onClick, style: {
      height: 44, padding: '0 16px', borderRadius: 12, display: 'inline-flex', alignItems: 'center',
      justifyContent: 'center', gap: 7, fontSize: 14.5, fontWeight: 700, ...tones[tone], ...style,
    } }, icon && h(Icon, { name: icon, size: 18, stroke: 2 }), label);
  }

  /* ── empty state ── */
  function EmptyState({ icon = 'inbox', title, body, action }) {
    return h('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '40px 36px', gap: 6 } },
      h('div', { style: { width: 76, height: 76, borderRadius: 24, background: 'var(--primary-tint)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12, color: 'var(--primary)' } },
        h(Icon, { name: icon, size: 34, stroke: 1.7 })),
      h('div', { className: 't-title', style: { fontSize: 18 } }, title),
      h('div', { style: { fontSize: 14, color: 'var(--muted)', lineHeight: 1.5, maxWidth: 250 } }, body),
      action && h('div', { style: { marginTop: 16, width: '100%', maxWidth: 220 } }, action),
    );
  }

  Object.assign(window, { Photo, Stars, RatingBadge, StatusBar, NavPill, DeviceShell, TopBar, BottomNav, Sheet, Pill, EmptyState, iconBtn });
})();
