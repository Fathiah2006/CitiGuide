/* CitiGuide — line icon set (stroke-based, geometric) */
(function () {
  const P = {
    search:   '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/>',
    heart:    '<path d="M20.8 8.6c0-2.5-2-4.5-4.5-4.5-1.7 0-3.2 1-3.9 2.4l-.4.8-.4-.8a4.3 4.3 0 0 0-3.9-2.4c-2.5 0-4.5 2-4.5 4.5 0 5 8.8 10.3 8.8 10.3S20.8 13.6 20.8 8.6z"/>',
    home:     '<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/>',
    mapPin:   '<path d="M20 10.5c0 5.2-8 11-8 11s-8-5.8-8-11a8 8 0 0 1 16 0z"/><circle cx="12" cy="10.5" r="2.8"/>',
    user:     '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.6-6.5 8-6.5s8 2.5 8 6.5"/>',
    star:     '<path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.2 1 5.9-5.2-2.8-5.2 2.8 1-5.9-4.3-4.2 5.9-.9z"/>',
    arrowL:   '<path d="M15 5l-7 7 7 7"/>',
    arrowR:   '<path d="M9 5l7 7-7 7"/>',
    chevR:    '<path d="M9 6l6 6-6 6"/>',
    chevD:    '<path d="M6 9l6 6 6-6"/>',
    sliders:  '<path d="M4 7h11M19 7h1M4 17h5M13 17h7"/><circle cx="17" cy="7" r="2.2"/><circle cx="11" cy="17" r="2.2"/>',
    share:    '<circle cx="6" cy="12" r="2.4"/><circle cx="17" cy="6" r="2.4"/><circle cx="17" cy="18" r="2.4"/><path d="M8.1 11l6.8-3.8M8.1 13l6.8 3.8"/>',
    nav:      '<path d="M3 11l18-8-8 18-2.2-7.8L3 11z"/>',
    phone:    '<path d="M5 4h3.5l1.5 4-2 1.5a12 12 0 0 0 5 5l1.5-2 4 1.5V19a2 2 0 0 1-2 2A16 16 0 0 1 4 6a2 2 0 0 1 1-2z"/>',
    globe:    '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17M12 3.5c2.5 2.4 2.5 14.6 0 17M12 3.5c-2.5 2.4-2.5 14.6 0 17"/>',
    clock:    '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
    camera:   '<path d="M4 8h3l1.5-2h7L17 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/><circle cx="12" cy="13" r="3.3"/>',
    plus:     '<path d="M12 5v14M5 12h14"/>',
    settings: '<circle cx="12" cy="12" r="3"/><path d="M12 2.5v3M12 18.5v3M21.5 12h-3M5.5 12h-3M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1M18.4 18.4l-2.1-2.1M7.7 7.7 5.6 5.6"/>',
    bell:     '<path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6z"/><path d="M10 19a2 2 0 0 0 4 0"/>',
    x:        '<path d="M6 6l12 12M18 6 6 18"/>',
    check:    '<path d="M5 12.5l4.5 4.5L19 7"/>',
    mail:     '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="M4 7l8 6 8-6"/>',
    lock:     '<rect x="4.5" y="10.5" width="15" height="10" rx="2.5"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5"/>',
    eye:      '<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/>',
    eyeOff:   '<path d="M3 3l18 18M10 5.2A9 9 0 0 1 12 5c6.4 0 10 7 10 7a17 17 0 0 1-3.3 4M6 7.4A17 17 0 0 0 2 12s3.6 7 10 7a9 9 0 0 0 3.6-.7"/><path d="M9.6 9.7a3 3 0 0 0 4.2 4.2"/>',
    cal:      '<rect x="3.5" y="5" width="17" height="16" rx="2.5"/><path d="M3.5 9.5h17M8 3v4M16 3v4"/>',
    landmark: '<path d="M4 9.5 12 4l8 5.5M5 9.5h14M6.5 9.5V18M10 9.5V18M14 9.5V18M17.5 9.5V18M4 21h16"/>',
    utensils: '<path d="M7 3v8a2 2 0 0 0 4 0V3M9 11v10M17 3c-1.5 0-2.5 2-2.5 5s1 4 2.5 4M17 12v9"/>',
    bed:      '<path d="M3 18v-7a2 2 0 0 1 2-2h9a3 3 0 0 1 3 3v1h2a2 2 0 0 1 2 2v3M3 18v2M21 18v2M3 14h18"/>',
    ticket:   '<path d="M4 7a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2a2 2 0 0 0 0-4V7z"/><path d="M14 5v14"/>',
    image:    '<rect x="3.5" y="4.5" width="17" height="15" rx="2.5"/><circle cx="8.5" cy="9.5" r="1.8"/><path d="M4 17l4.5-4 3.5 3 3-2.5 5 4.5"/>',
    edit:     '<path d="M5 19h3l9-9-3-3-9 9v3z"/><path d="M14 6l3 3"/>',
    logout:   '<path d="M14 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8M16 8l4 4-4 4M9 12h11"/>',
    sort:     '<path d="M7 5v14M7 19l-3-3M7 19l3-3M17 19V5M17 5l-3 3M17 5l3 3"/>',
    filter:   '<path d="M4 6h16M7 12h10M10 18h4"/>',
    info:     '<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5M12 8h.01"/>',
    wifi:     '<path d="M5 12.5a10 10 0 0 1 14 0M8 15.5a6 6 0 0 1 8 0M12 18.5h.01"/>',
    cloud:    '<path d="M7 18a4 4 0 0 1-.5-8 5.5 5.5 0 0 1 10.6 1.3A3.5 3.5 0 0 1 17 18H7z"/>',
    inbox:    '<path d="M3 13h5l1.5 3h5L21 13M3 13l3-8h12l3 8v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-6z"/>',
    refresh:  '<path d="M20 11a8 8 0 1 0-.5 4M20 5v6h-6"/>',
    pin2:     '<circle cx="12" cy="10" r="3"/><path d="M12 21s7-5.5 7-11a7 7 0 1 0-14 0c0 5.5 7 11 7 11z"/>',
  };

  function Icon({ name, size = 22, stroke = 1.8, color = 'currentColor', fill = 'none', style = {} }) {
    const d = P[name];
    if (!d) return null;
    return React.createElement('svg', {
      width: size, height: size, viewBox: '0 0 24 24', fill,
      stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round',
      style, dangerouslySetInnerHTML: { __html: d },
    });
  }
  // solid star for ratings
  function StarSolid({ size = 16, color = 'var(--star)', style = {} }) {
    return React.createElement('svg', {
      width: size, height: size, viewBox: '0 0 24 24', fill: color, stroke: 'none', style,
      dangerouslySetInnerHTML: { __html: '<path d="M12 3.2l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17.6 6.6 20.2l1-6.1L3.2 9.7l6.1-.9z"/>' },
    });
  }

  /* ── CitiGuide brand mark ──────────────────────────────────
     A "place" pin (Citi) holding a compass needle (Guide).
     North tip in brand amber = your guiding direction. Built
     from simple geometry; reads at 16px → 160px. */
  function LogoMark({ size = 48, pin = 'var(--primary)', north = 'var(--star)', south = '#fff', pivot, style = {} }) {
    const piv = pivot || pin;
    return React.createElement('svg', {
      width: size, height: size, viewBox: '0 0 48 48', fill: 'none', style,
    },
      // teardrop pin silhouette
      React.createElement('path', {
        d: 'M24 3.5C15 3.5 7.5 10.8 7.5 19.8c0 4.2 2.2 8.7 5.4 12.7 3.2 4 7.1 7.4 9.6 9.4a2.4 2.4 0 0 0 3 0c2.5-2 6.4-5.4 9.6-9.4 3.2-4 5.4-8.5 5.4-12.7C40.5 10.8 33 3.5 24 3.5Z',
        fill: pin,
      }),
      // compass needle — south half
      React.createElement('path', { d: 'M24 30.4 27.4 20 20.6 20Z', fill: south, opacity: .9 }),
      // compass needle — north half (guiding tip)
      React.createElement('path', { d: 'M24 9.6 27.4 20 20.6 20Z', fill: north }),
      // pivot
      React.createElement('circle', { cx: 24, cy: 20, r: 2.5, fill: piv }),
      React.createElement('circle', { cx: 24, cy: 20, r: 1, fill: north }),
    );
  }

  window.Icon = Icon;
  window.StarSolid = StarSolid;
  window.LogoMark = LogoMark;
})();
