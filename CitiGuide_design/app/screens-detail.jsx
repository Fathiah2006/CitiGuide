/* CitiGuide — listing details & map/directions */
(function () {
  const { Icon, StarSolid, DeviceShell, Photo, Stars, TopBar, Sheet, HeartBtn } = window;
  const D = window.CG_DATA;
  const h = React.createElement;
  const { useState } = React;

  function QuickAction({ icon, label, onClick, tone }) {
    return h('button', { onClick, style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7 } },
      h('div', { style: { width: 50, height: 50, borderRadius: 16, background: tone === 'primary' ? 'var(--primary)' : 'var(--primary-tint)', color: tone === 'primary' ? '#fff' : 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' } },
        h(Icon, { name: icon, size: 22, stroke: 2 })),
      h('span', { style: { fontSize: 12, fontWeight: 600, color: 'var(--ink-2)' } }, label));
  }

  function InfoRow({ icon, label, value, action, last }) {
    return h('div', { style: { display: 'flex', alignItems: 'center', gap: 13, padding: '14px 0', borderBottom: last ? 'none' : '1px solid var(--line-2)' } },
      h('div', { style: { width: 38, height: 38, borderRadius: 11, background: 'var(--bg-alt)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)', flexShrink: 0 } }, h(Icon, { name: icon, size: 19, stroke: 1.9 })),
      h('div', { style: { flex: 1, minWidth: 0 } },
        h('div', { style: { fontSize: 12, color: 'var(--muted)', fontWeight: 600 } }, label),
        h('div', { style: { fontSize: 14.5, fontWeight: 600, color: 'var(--ink)', marginTop: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' } }, value)),
      action);
  }

  /* abstract minimal map card */
  function MiniMap({ hue = 200, height = 150, round = 16, onClick, marker = true, label }) {
    return h('button', { onClick, style: { display: 'block', width: '100%', height, borderRadius: round, overflow: 'hidden', position: 'relative', background: '#E8EEF1' } },
      h('svg', { width: '100%', height: '100%', viewBox: '0 0 320 200', preserveAspectRatio: 'xMidYMid slice', style: { position: 'absolute', inset: 0 } },
        h('rect', { width: 320, height: 200, fill: '#EAF0F2' }),
        h('g', { fill: '#DDE6E9' }, h('rect', { x: 20, y: 18, width: 70, height: 52, rx: 4 }), h('rect', { x: 200, y: 30, width: 90, height: 44, rx: 4 }), h('rect', { x: 40, y: 130, width: 80, height: 50, rx: 4 }), h('rect', { x: 230, y: 120, width: 70, height: 64, rx: 4 })),
        h('g', { stroke: '#fff', strokeWidth: 7, fill: 'none', strokeLinecap: 'round' }, h('path', { d: 'M0 95 H320' }), h('path', { d: 'M150 0 V200' }), h('path', { d: 'M0 160 L120 160 L150 200' })),
        h('g', { stroke: '#cfdade', strokeWidth: 1.5, fill: 'none' }, h('path', { d: 'M0 95 H320' }), h('path', { d: 'M150 0 V200' })),
        // water
        h('path', { d: 'M250 0 Q300 40 320 30 L320 0 Z', fill: '#CBE0E6' }),
      ),
      marker && h('div', { style: { position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%,-100%)' } },
        h('div', { style: { width: 38, height: 38, borderRadius: '50% 50% 50% 0', background: 'var(--primary)', transform: 'rotate(-45deg)', boxShadow: 'var(--sh-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' } },
          h('div', { style: { transform: 'rotate(45deg)', color: '#fff', display: 'flex' } }, h(StarSolid, { size: 16, color: '#fff' })))),
      label && h('div', { style: { position: 'absolute', right: 10, bottom: 10, background: '#fff', borderRadius: 9, padding: '7px 11px', boxShadow: 'var(--sh-1)', fontSize: 12.5, fontWeight: 700, color: 'var(--primary)', display: 'flex', alignItems: 'center', gap: 5 } },
        h(Icon, { name: 'nav', size: 14, stroke: 2 }), label),
    );
  }

  /* ── Listing details ── */
  function Details({ l, isFav, onBack, onFav, onMap, onReviews, onAddReview, reviews }) {
    const [img, setImg] = useState(0);
    const cat = D.catById(l.categoryId);
    const revs = reviews || D.reviewsFor(l.id);
    const baseHue = l.hue ?? cat.hue;

    return h(DeviceShell, { statusTone: 'light' },
      h('div', { className: 'cg-scroll' },
        // hero gallery
        h('div', { style: { position: 'relative', height: 320 } },
          h(Photo, { hue: baseHue + img * 14, cat: cat.icon, dim: true }),
          h('div', { style: { position: 'absolute', top: 48, left: 16, right: 16, display: 'flex', justifyContent: 'space-between' } },
            h('button', { onClick: onBack, style: glassBtn }, h(Icon, { name: 'arrowL', size: 22, color: '#fff' })),
            h('div', { style: { display: 'flex', gap: 10 } },
              h('button', { style: glassBtn }, h(Icon, { name: 'share', size: 19, color: '#fff' })),
              h(HeartBtn, { on: isFav, onClick: onFav, dark: true })),
          ),
          // gallery dots
          h('div', { style: { position: 'absolute', bottom: 36, left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: 6 } },
            Array.from({ length: Math.min(l.images, 4) }).map((_, i) => h('button', { key: i, onClick: () => setImg(i), style: { width: i === img ? 22 : 7, height: 7, borderRadius: 9, background: i === img ? '#fff' : 'rgba(255,255,255,.5)', transition: 'all .2s' } }))),
        ),
        // body sheet
        h('div', { style: { background: '#fff', borderRadius: '26px 26px 0 0', marginTop: -24, position: 'relative', padding: '22px 20px 0' } },
          h('div', { style: { display: 'flex', alignItems: 'flex-start', gap: 12 } },
            h('div', { style: { flex: 1 } },
              h('div', { style: { display: 'flex', alignItems: 'center', gap: 8 } },
                h('span', { style: { fontSize: 11.5, fontWeight: 700, color: 'var(--primary-300)', textTransform: 'uppercase', letterSpacing: '.05em' } }, cat.name),
                l.price && h('span', { style: { fontSize: 12.5, color: 'var(--muted)', fontWeight: 600 } }, '· ' + l.price)),
              h('div', { className: 't-display', style: { fontSize: 25, marginTop: 4, lineHeight: 1.12 } }, l.name)),
            h('div', { style: { textAlign: 'right', flexShrink: 0 } },
              h('div', { style: { display: 'flex', alignItems: 'center', gap: 4, justifyContent: 'flex-end' } }, h(StarSolid, { size: 17 }), h('span', { className: 't-title', style: { fontSize: 18 } }, l.rating.toFixed(1))),
              h('div', { style: { fontSize: 12, color: 'var(--muted)', marginTop: 1 } }, `${l.ratingCount} reviews`)),
          ),
          h('div', { style: { display: 'flex', alignItems: 'center', gap: 6, marginTop: 10, color: 'var(--muted)' } },
            h(Icon, { name: 'mapPin', size: 15, stroke: 1.9 }),
            h('span', { style: { fontSize: 13.5 } }, l.address),
            h('span', { style: { marginLeft: 'auto', display: 'inline-flex', alignItems: 'center', gap: 5, color: l.openNow ? 'var(--success)' : 'var(--danger)', fontWeight: 700, fontSize: 13 } },
              h('span', { style: { width: 7, height: 7, borderRadius: 9, background: 'currentColor' } }), l.openNow ? 'Open now' : 'Closed')),
          // quick actions
          h('div', { style: { display: 'flex', gap: 8, margin: '20px 0 6px' } },
            h(QuickAction, { icon: 'nav', label: 'Directions', tone: 'primary', onClick: onMap }),
            h(QuickAction, { icon: 'phone', label: 'Call' }),
            h(QuickAction, { icon: 'globe', label: 'Website' }),
            h(QuickAction, { icon: 'share', label: 'Share' })),
          h('div', { className: 'hr', style: { margin: '20px 0' } }),
          // about
          h('div', { className: 't-title', style: { fontSize: 17, marginBottom: 8 } }, 'About'),
          h('p', { style: { fontSize: 14.5, lineHeight: 1.6, color: 'var(--ink-2)', textWrap: 'pretty' } }, l.description),
          l.tags.length > 0 && h('div', { style: { display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 14 } },
            l.tags.map(t => h('span', { key: t, style: { fontSize: 12.5, fontWeight: 600, color: 'var(--ink-2)', background: 'var(--bg-alt)', padding: '6px 12px', borderRadius: 100 } }, t))),
          // info
          h('div', { style: { marginTop: 20 } },
            h(InfoRow, { icon: 'clock', label: 'Opening hours', value: l.hours }),
            h(InfoRow, { icon: 'phone', label: 'Phone', value: l.phone, action: h('button', { style: linkBtn }, 'Call') }),
            h(InfoRow, { icon: 'globe', label: 'Website', value: l.website, action: h('button', { style: linkBtn }, 'Visit'), last: true }),
          ),
          // map
          h('div', { className: 't-title', style: { fontSize: 17, margin: '20px 0 12px' } }, 'Location'),
          h(MiniMap, { hue: baseHue, onClick: onMap, label: 'Directions' }),
          h('div', { style: { fontSize: 13.5, color: 'var(--muted)', marginTop: 10, display: 'flex', alignItems: 'center', gap: 6 } },
            h(Icon, { name: 'mapPin', size: 15 }), l.address),
          // reviews
          h('div', { className: 'hr', style: { margin: '22px 0' } }),
          h(RatingSummary, { l, onAdd: onAddReview }),
          h('div', { style: { marginTop: 6 } },
            revs.slice(0, 2).map((r, i) => h(ReviewItem, { key: i, r }))),
          h('button', { onClick: onReviews, className: 'btn btn-outline', style: { marginTop: 8 } }, `See all ${l.ratingCount} reviews`),
          h('div', { style: { height: 96 } }),
        ),
      ),
      // sticky CTA
      h('div', { style: { position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 20px 30px', background: 'rgba(255,255,255,.94)', backdropFilter: 'blur(10px)', borderTop: '1px solid var(--line)', display: 'flex', alignItems: 'center', gap: 14 } },
        h('div', null,
          h('div', { style: { fontSize: 12, color: 'var(--muted)', fontWeight: 600 } }, l.price ? 'Price' : 'Entry'),
          h('div', { className: 't-title', style: { fontSize: 17 } }, l.price || (l.categoryId === 'attractions' || l.categoryId === 'events' ? 'Free' : 'Varies'))),
        h('button', { onClick: onMap, className: 'btn btn-primary', style: { flex: 1, width: 'auto' } }, h(Icon, { name: 'nav', size: 19, stroke: 2 }), 'Get directions')),
    );
  }

  function RatingSummary({ l, onAdd }) {
    const dist = [0.72, 0.18, 0.06, 0.02, 0.02]; // 5..1
    return h('div', null,
      h('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 } },
        h('div', { className: 't-title', style: { fontSize: 17 } }, 'Reviews & ratings'),
        h('button', { onClick: onAdd, style: { display: 'flex', alignItems: 'center', gap: 5, fontSize: 13.5, fontWeight: 700, color: 'var(--primary)' } }, h(Icon, { name: 'plus', size: 16, stroke: 2.4 }), 'Write')),
      h('div', { style: { display: 'flex', gap: 18, alignItems: 'center' } },
        h('div', { style: { textAlign: 'center', flexShrink: 0 } },
          h('div', { className: 't-display', style: { fontSize: 42, lineHeight: 1 } }, l.rating.toFixed(1)),
          h('div', { style: { marginTop: 6 } }, h(Stars, { value: l.rating, size: 13 })),
          h('div', { style: { fontSize: 12, color: 'var(--muted)', marginTop: 4 } }, `${l.ratingCount} reviews`)),
        h('div', { style: { flex: 1 } },
          dist.map((p, i) => h('div', { key: i, style: { display: 'flex', alignItems: 'center', gap: 8, marginBottom: 5 } },
            h('span', { style: { fontSize: 11.5, color: 'var(--muted)', width: 8 } }, 5 - i),
            h('div', { style: { flex: 1, height: 6, borderRadius: 6, background: 'var(--bg-alt-2)', overflow: 'hidden' } },
              h('div', { style: { width: `${p * 100}%`, height: '100%', background: 'var(--star)', borderRadius: 6 } }))))),
      ),
    );
  }

  function ReviewItem({ r, onLike }) {
    const [liked, setLiked] = useState(r.liked);
    const [n, setN] = useState(r.likes);
    return h('div', { style: { padding: '16px 0', borderBottom: '1px solid var(--line-2)' } },
      h('div', { style: { display: 'flex', alignItems: 'center', gap: 11 } },
        h('div', { style: { width: 40, height: 40, borderRadius: 999, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 14, flexShrink: 0 } }, r.user.split(' ').map(w => w[0]).join('')),
        h('div', { style: { flex: 1 } },
          h('div', { style: { fontSize: 14.5, fontWeight: 700 } }, r.user),
          h('div', { style: { display: 'flex', alignItems: 'center', gap: 7, marginTop: 2 } }, h(Stars, { value: r.rating, size: 11 }), h('span', { style: { fontSize: 12, color: 'var(--muted)' } }, r.date))),
      ),
      h('p', { style: { fontSize: 14, lineHeight: 1.55, color: 'var(--ink-2)', margin: '10px 0 0', textWrap: 'pretty' } }, r.text),
      h('button', { onClick: () => { setLiked(v => !v); setN(v => v + (liked ? -1 : 1)); onLike && onLike(); }, style: { display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 10, fontSize: 12.5, fontWeight: 700, color: liked ? 'var(--primary)' : 'var(--muted)' } },
        h(Icon, { name: 'heart', size: 15, stroke: 2, fill: liked ? 'var(--primary)' : 'none' }), `Helpful · ${n}`),
    );
  }

  /* ── Map / directions ── */
  function MapView({ l, onBack }) {
    const cat = D.catById(l.categoryId);
    return h(DeviceShell, { statusTone: 'dark', bg: '#EAF0F2' },
      h('div', { style: { flex: 1, position: 'relative', background: '#EAF0F2' } },
        h('div', { style: { position: 'absolute', inset: 0 } },
          h(MiniMap, { hue: l.hue ?? cat.hue, height: '100%', round: 0, onClick: null })),
        h('div', { style: { position: 'absolute', top: 48, left: 16, right: 16, display: 'flex', justifyContent: 'space-between' } },
          h('button', { onClick: onBack, style: { ...glassBtn, background: '#fff', boxShadow: 'var(--sh-2)' } }, h(Icon, { name: 'arrowL', size: 22, color: 'var(--ink)' })),
          h('button', { style: { ...glassBtn, background: '#fff', boxShadow: 'var(--sh-2)' } }, h(Icon, { name: 'pin2', size: 20, color: 'var(--primary)' }))),
        // bottom directions card
        h('div', { style: { position: 'absolute', left: 14, right: 14, bottom: 30, background: '#fff', borderRadius: 22, boxShadow: 'var(--sh-3)', padding: 18 } },
          h('div', { style: { display: 'flex', gap: 13, alignItems: 'center' } },
            h('div', { style: { width: 58, height: 58, borderRadius: 14, overflow: 'hidden', flexShrink: 0 } }, h(Photo, { hue: l.hue ?? cat.hue, cat: cat.icon })),
            h('div', { style: { flex: 1, minWidth: 0 } },
              h('div', { className: 't-title', style: { fontSize: 16.5 } }, l.name),
              h('div', { style: { display: 'flex', alignItems: 'center', gap: 5, marginTop: 3, color: 'var(--muted)' } }, h(Icon, { name: 'mapPin', size: 14 }), h('span', { style: { fontSize: 13, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' } }, l.address))),
          ),
          h('div', { style: { display: 'flex', gap: 16, margin: '14px 0', padding: '12px 0', borderTop: '1px solid var(--line-2)', borderBottom: '1px solid var(--line-2)' } },
            h(Stat, { icon: 'nav', k: '12 min', v: 'Driving' }),
            h(Stat, { icon: 'mapPin', k: '4.2 km', v: 'Distance' }),
            h(Stat, { icon: 'clock', k: l.openNow ? 'Open' : 'Closed', v: 'Status' })),
          h('div', { style: { display: 'flex', gap: 10 } },
            h('button', { className: 'btn btn-primary', style: { flex: 1 } }, h(Icon, { name: 'nav', size: 18, stroke: 2 }), 'Google Maps'),
            h('button', { className: 'btn btn-outline', style: { flex: 1 } }, 'Apple Maps')),
        ),
      ),
    );
  }
  function Stat({ icon, k, v }) {
    return h('div', { style: { flex: 1, display: 'flex', alignItems: 'center', gap: 9 } },
      h('div', { style: { color: 'var(--primary)' } }, h(Icon, { name: icon, size: 18, stroke: 2 })),
      h('div', null, h('div', { style: { fontSize: 14, fontWeight: 700 } }, k), h('div', { style: { fontSize: 11.5, color: 'var(--muted)' } }, v)));
  }

  const glassBtn = { width: 42, height: 42, borderRadius: 999, background: 'rgba(8,28,42,.34)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 };
  const linkBtn = { fontSize: 13.5, fontWeight: 700, color: 'var(--primary)', padding: '6px 12px', borderRadius: 100, background: 'var(--primary-tint)' };

  Object.assign(window, { Details, MapView, MiniMap, ReviewItem, RatingSummary });
})();
