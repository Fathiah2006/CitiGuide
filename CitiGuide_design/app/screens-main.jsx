/* CitiGuide — city select, home & search */
(function () {
  const { Icon, StarSolid, DeviceShell, Photo, Stars, RatingBadge, TopBar, BottomNav, Sheet, Pill, EmptyState } = window;
  const D = window.CG_DATA;
  const h = React.createElement;
  const { useState } = React;

  /* ── reusable listing cards ── */
  function HeartBtn({ on, onClick, dark = false }) {
    return h('button', {
      onClick: (e) => { e.stopPropagation(); onClick && onClick(); },
      'aria-label': 'Save',
      style: {
        width: 36, height: 36, borderRadius: 999, flexShrink: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: dark ? 'rgba(8,28,42,.4)' : '#fff', backdropFilter: dark ? 'blur(6px)' : 'none',
        boxShadow: dark ? 'none' : 'var(--sh-1)', color: on ? 'var(--coral)' : (dark ? '#fff' : 'var(--muted)'),
      },
    }, h(Icon, { name: 'heart', size: 19, stroke: 2, fill: on ? 'var(--coral)' : 'none' }));
  }

  function ListingRow({ l, isFav, onFav, onOpen }) {
    const cat = D.catById(l.categoryId);
    return h('div', { onClick: () => onOpen(l.id), role: 'button', style: {
      display: 'flex', gap: 13, width: '100%', textAlign: 'left', padding: '8px 0', alignItems: 'center', cursor: 'pointer',
    } },
      h('div', { style: { width: 92, height: 92, borderRadius: 16, overflow: 'hidden', flexShrink: 0 } },
        h(Photo, { hue: l.hue ?? cat.hue, cat: cat.icon })),
      h('div', { style: { flex: 1, minWidth: 0 } },
        h('div', { style: { fontSize: 11.5, fontWeight: 700, color: 'var(--primary-300)', textTransform: 'uppercase', letterSpacing: '.05em' } }, cat.name),
        h('div', { className: 't-title', style: { fontSize: 16, marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' } }, l.name),
        h('div', { style: { display: 'flex', alignItems: 'center', gap: 5, marginTop: 5 } },
          h(StarSolid, { size: 13 }),
          h('span', { style: { fontSize: 13, fontWeight: 700 } }, l.rating.toFixed(1)),
          h('span', { style: { fontSize: 12.5, color: 'var(--muted)' } }, `(${l.ratingCount})`),
          l.price && h('span', { style: { fontSize: 12.5, color: 'var(--muted)' } }, '· ' + l.price),
        ),
        h('div', { style: { display: 'flex', alignItems: 'center', gap: 4, marginTop: 4, color: 'var(--muted)' } },
          h(Icon, { name: 'mapPin', size: 13, stroke: 1.8 }),
          h('span', { style: { fontSize: 12.5, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' } }, l.address || l.short)),
      ),
      h(HeartBtn, { on: isFav, onClick: onFav }),
    );
  }

  function FeaturedCard({ l, isFav, onFav, onOpen }) {
    const cat = D.catById(l.categoryId);
    return h('div', { onClick: () => onOpen(l.id), role: 'button', style: {
      width: 246, flexShrink: 0, textAlign: 'left', background: '#fff', cursor: 'pointer',
      borderRadius: 20, boxShadow: 'var(--sh-2)', overflow: 'hidden',
    } },
      h('div', { style: { position: 'relative', height: 152 } },
        h(Photo, { hue: l.hue ?? cat.hue, cat: cat.icon, dim: true }),
        h('div', { style: { position: 'absolute', top: 10, left: 10 } }, h(RatingBadge, { value: l.rating, dark: true })),
        h('div', { style: { position: 'absolute', top: 10, right: 10 } }, h(HeartBtn, { on: isFav, onClick: onFav, dark: true })),
        l.price && h('div', { style: { position: 'absolute', bottom: 10, right: 12, color: '#fff', fontSize: 13, fontWeight: 700 } }, l.price),
      ),
      h('div', { style: { padding: '12px 14px 15px' } },
        h('div', { style: { fontSize: 11, fontWeight: 700, color: 'var(--primary-300)', textTransform: 'uppercase', letterSpacing: '.05em' } }, cat.name),
        h('div', { className: 't-title', style: { fontSize: 16.5, marginTop: 3, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' } }, l.name),
        h('div', { style: { fontSize: 13, color: 'var(--muted)', marginTop: 4, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' } }, l.short),
      ),
    );
  }

  /* ── City selection ── */
  function CitySelect({ selected, onSelect }) {
    return h(DeviceShell, { statusTone: 'dark' },
      h('div', { className: 'cg-scroll' },
        h('div', { style: { padding: '60px 24px 8px' } },
          h('div', { style: { fontSize: 13, fontWeight: 700, color: 'var(--primary-300)', textTransform: 'uppercase', letterSpacing: '.08em' } }, 'CitiGuide'),
          h('div', { className: 't-display', style: { fontSize: 32, marginTop: 8 } }, 'Where to?'),
          h('div', { style: { fontSize: 15, color: 'var(--muted)', marginTop: 6 } }, 'Pick a city to start exploring.'),
        ),
        h('div', { style: { display: 'flex', flexDirection: 'column', gap: 14, padding: '16px 24px 32px' } },
          D.CITIES.map(c => {
            const on = selected === c.id;
            return h('button', { key: c.id, onClick: () => onSelect(c.id), className: 'anim-up', style: {
              position: 'relative', height: 150, borderRadius: 22, overflow: 'hidden', textAlign: 'left',
              boxShadow: on ? '0 0 0 3px var(--primary), var(--sh-2)' : 'var(--sh-1)',
            } },
              h(Photo, { hue: c.hue, dim: true }),
              h('div', { style: { position: 'absolute', inset: 0, padding: 18, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' } },
                h('div', { style: { display: 'flex', alignItems: 'center', gap: 6, color: 'rgba(255,255,255,.85)' } },
                  h(Icon, { name: 'mapPin', size: 14, stroke: 2 }),
                  h('span', { style: { fontSize: 12.5, fontWeight: 600 } }, c.state)),
                h('div', { className: 't-display', style: { fontSize: 26, color: '#fff', marginTop: 3 } }, c.name),
                h('div', { style: { fontSize: 13, color: 'rgba(255,255,255,.82)', marginTop: 2 } }, `${c.places} places · ${c.tagline}`),
              ),
              on && h('div', { style: { position: 'absolute', top: 14, right: 14, width: 28, height: 28, borderRadius: 999, background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' } }, h(Icon, { name: 'check', size: 17, stroke: 3 })),
            );
          }),
        ),
      ),
    );
  }

  /* ── Home / Explore ── */
  function Home({ cityId, favs, onOpen, onFav, onNav, onSearch, onChangeCity, active = 'home' }) {
    const [cat, setCat] = useState('all');
    const city = D.cityById(cityId);
    let list = D.byCity(cityId);
    const featured = list.filter(l => l.featured);
    if (cat !== 'all') list = list.filter(l => l.categoryId === cat);
    const cats = [{ id: 'all', name: 'All', icon: 'home' }, ...D.CATEGORIES];

    return h(DeviceShell, { statusTone: 'light', bg: 'var(--bg-alt)' },
      h('div', { className: 'cg-scroll' },
        // hero
        h('div', { style: { position: 'relative', height: 280 } },
          h(Photo, { hue: city.hue, dim: true }),
          h('div', { style: { position: 'absolute', inset: 0, padding: '52px 22px 0', display: 'flex', flexDirection: 'column' } },
            h('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
              h('button', { onClick: onChangeCity, style: { display: 'flex', alignItems: 'center', gap: 6, color: '#fff', background: 'rgba(8,28,42,.32)', backdropFilter: 'blur(6px)', padding: '7px 12px', borderRadius: 100 } },
                h(Icon, { name: 'mapPin', size: 16, stroke: 2 }),
                h('span', { style: { fontSize: 13.5, fontWeight: 700 } }, city.name),
                h(Icon, { name: 'chevD', size: 15, stroke: 2.2 })),
              h('button', { style: { width: 40, height: 40, borderRadius: 999, background: 'rgba(8,28,42,.32)', backdropFilter: 'blur(6px)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', position: 'relative' } },
                h(Icon, { name: 'bell', size: 20 }),
                h('div', { style: { position: 'absolute', top: 9, right: 10, width: 7, height: 7, borderRadius: 9, background: 'var(--coral)', border: '1.5px solid rgba(8,28,42,.4)' } })),
            ),
            h('div', { style: { marginTop: 'auto', paddingBottom: 36 } },
              h('div', { style: { fontSize: 13.5, color: 'rgba(255,255,255,.8)', fontWeight: 600 } }, 'Explore'),
              h('div', { className: 't-display', style: { fontSize: 26, color: '#fff', lineHeight: 1.12, marginTop: 3, maxWidth: 300 } }, city.tagline),
            ),
          ),
        ),
        // search bar (overlapping)
        h('div', { style: { padding: '0 20px', marginTop: -26, position: 'relative', zIndex: 2 } },
          h('button', { onClick: onSearch, style: { width: '100%', height: 54, borderRadius: 16, background: '#fff', boxShadow: 'var(--sh-2)', display: 'flex', alignItems: 'center', gap: 11, padding: '0 16px', color: 'var(--muted)' } },
            h(Icon, { name: 'search', size: 20 }),
            h('span', { style: { fontSize: 15, fontWeight: 500 } }, `Search ${city.name}…`),
            h('div', { style: { marginLeft: 'auto', width: 36, height: 36, borderRadius: 11, background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' } }, h(Icon, { name: 'sliders', size: 18, stroke: 2 })),
          ),
        ),
        // category chips
        h('div', { style: { display: 'flex', gap: 9, overflowX: 'auto', padding: '20px 20px 4px', scrollbarWidth: 'none' } },
          cats.map(c => h('button', { key: c.id, onClick: () => setCat(c.id), className: 'chip' + (cat === c.id ? ' is-active' : '') },
            h(Icon, { name: c.icon, size: 16, stroke: 2 }), c.name))),
        // featured
        cat === 'all' && featured.length > 0 && h('div', null,
          h(SectionHead, { title: 'Featured', sub: 'Hand-picked highlights' }),
          h('div', { style: { display: 'flex', gap: 14, overflowX: 'auto', padding: '4px 20px 8px', scrollbarWidth: 'none' } },
            featured.map(l => h(FeaturedCard, { key: l.id, l, isFav: favs.has(l.id), onFav: () => onFav(l.id), onOpen }))),
        ),
        // popular list
        h(SectionHead, { title: cat === 'all' ? `Popular in ${city.name}` : D.catById(cat).name, sub: `${list.length} places` }),
        h('div', { style: { padding: '0 20px 16px', display: 'flex', flexDirection: 'column' } },
          list.map(l => h(React.Fragment, { key: l.id },
            h(ListingRow, { l, isFav: favs.has(l.id), onFav: () => onFav(l.id), onOpen }),
            h('div', { className: 'hr', style: { margin: '4px 0' } }))),
        ),
        h('div', { style: { height: 8 } }),
      ),
      h(BottomNav, { active, onNav }),
    );
  }

  function SectionHead({ title, sub, action }) {
    return h('div', { style: { display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', padding: '18px 20px 10px' } },
      h('div', null,
        h('div', { className: 't-title', style: { fontSize: 20 } }, title),
        sub && h('div', { style: { fontSize: 13, color: 'var(--muted)', marginTop: 2, fontWeight: 500 } }, sub)),
      action,
    );
  }

  /* ── Search ── */
  const SORTS = [{ id: 'rating', label: 'Top rated' }, { id: 'reviews', label: 'Most reviewed' }, { id: 'name', label: 'A–Z' }];
  function Search({ cityId, favs, onOpen, onFav, onNav, active = 'search', initialQuery = '' }) {
    const [q, setQ] = useState(initialQuery);
    const [cats, setCats] = useState([]);
    const [minR, setMinR] = useState(0);
    const [sort, setSort] = useState('rating');
    const [sheet, setSheet] = useState(false);
    const city = D.cityById(cityId);

    let results = D.byCity(cityId);
    const hasQuery = q.trim().length > 0;
    if (hasQuery) results = results.filter(l => (l.name + ' ' + l.short + ' ' + l.tags.join(' ')).toLowerCase().includes(q.toLowerCase()));
    if (cats.length) results = results.filter(l => cats.includes(l.categoryId));
    if (minR) results = results.filter(l => l.rating >= minR);
    results = [...results].sort((a, b) => sort === 'rating' ? b.rating - a.rating : sort === 'reviews' ? b.ratingCount - a.ratingCount : a.name.localeCompare(b.name));
    const activeFilters = cats.length + (minR ? 1 : 0);

    return h(DeviceShell, { statusTone: 'dark' },
      h('div', { style: { padding: '46px 16px 12px', flexShrink: 0 } },
        h('div', { style: { display: 'flex', gap: 10 } },
          h('div', { className: 'field', style: { flex: 1, height: 50 } },
            h(Icon, { name: 'search', size: 19, color: 'var(--muted)' }),
            h('input', { autoFocus: false, placeholder: `Search ${city.name}…`, value: q, onChange: e => setQ(e.target.value) }),
            q && h('button', { onClick: () => setQ(''), style: { color: 'var(--muted)', display: 'flex' } }, h(Icon, { name: 'x', size: 18 }))),
          h('button', { onClick: () => setSheet(true), style: { width: 50, height: 50, borderRadius: 14, background: activeFilters ? 'var(--primary)' : 'var(--bg-alt-2)', color: activeFilters ? '#fff' : 'var(--ink)', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative', flexShrink: 0 } },
            h(Icon, { name: 'sliders', size: 21, stroke: 2 }),
            activeFilters > 0 && h('div', { style: { position: 'absolute', top: -4, right: -4, minWidth: 19, height: 19, padding: '0 5px', borderRadius: 999, background: 'var(--coral)', color: '#fff', fontSize: 11, fontWeight: 800, display: 'flex', alignItems: 'center', justifyContent: 'center' } }, activeFilters)),
        ),
      ),
      h('div', { className: 'cg-scroll', style: { padding: '0 16px' } },
        !hasQuery && activeFilters === 0
          ? h(SearchSuggest, { city, onPick: setQ, onCat: (id) => setCats([id]) })
          : results.length === 0
            ? h(EmptyState, { icon: 'search', title: 'No matches', body: `We couldn’t find anything for “${q}” in ${city.name}. Try a different word or clear your filters.`, action: h('button', { className: 'btn btn-ghost', onClick: () => { setQ(''); setCats([]); setMinR(0); } }, 'Clear search') })
            : h('div', null,
              h('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 4px 6px' } },
                h('span', { style: { fontSize: 13.5, color: 'var(--muted)', fontWeight: 600 } }, `${results.length} result${results.length > 1 ? 's' : ''}`),
                h('button', { onClick: () => setSheet(true), style: { display: 'flex', alignItems: 'center', gap: 5, fontSize: 13.5, fontWeight: 700, color: 'var(--primary)' } },
                  h(Icon, { name: 'sort', size: 16, stroke: 2 }), SORTS.find(s => s.id === sort).label)),
              results.map(l => h(React.Fragment, { key: l.id },
                h(ListingRow, { l, isFav: favs.has(l.id), onFav: () => onFav(l.id), onOpen }),
                h('div', { className: 'hr', style: { margin: '4px 0' } }))),
              h('div', { style: { height: 8 } }),
            ),
      ),
      h(BottomNav, { active, onNav }),
      h(Sheet, { open: sheet, onClose: () => setSheet(false), title: 'Filters' },
        h(FilterBody, { cats, setCats, minR, setMinR, sort, setSort, onApply: () => setSheet(false), onClear: () => { setCats([]); setMinR(0); setSort('rating'); } }),
      ),
    );
  }

  function SearchSuggest({ city, onPick, onCat }) {
    const recents = ['Museum', 'Jollof', 'Pool', 'Carnival'];
    return h('div', { style: { paddingTop: 18 } },
      h('div', { style: { fontSize: 13, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 12 } }, 'Recent searches'),
      h('div', { style: { display: 'flex', flexWrap: 'wrap', gap: 9 } },
        recents.map(r => h('button', { key: r, onClick: () => onPick(r), className: 'chip' }, h(Icon, { name: 'search', size: 14, stroke: 2 }), r))),
      h('div', { style: { fontSize: 13, fontWeight: 700, color: 'var(--ink-2)', margin: '26px 0 12px' } }, 'Browse by category'),
      h('div', { style: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 } },
        D.CATEGORIES.map(c => h('button', { key: c.id, onClick: () => onCat(c.id), style: { position: 'relative', height: 92, borderRadius: 16, overflow: 'hidden', textAlign: 'left' } },
          h(Photo, { hue: c.hue, cat: c.icon, dim: true }),
          h('div', { style: { position: 'absolute', left: 14, bottom: 12, color: '#fff', fontSize: 15.5, fontWeight: 700 } }, c.name)))),
    );
  }

  function FilterBody({ cats, setCats, minR, setMinR, sort, setSort, onApply, onClear }) {
    const toggle = (id) => setCats(cs => cs.includes(id) ? cs.filter(x => x !== id) : [...cs, id]);
    return h('div', null,
      h('div', { style: { fontSize: 13.5, fontWeight: 700, margin: '8px 0 11px' } }, 'Category'),
      h('div', { style: { display: 'flex', flexWrap: 'wrap', gap: 9 } },
        D.CATEGORIES.map(c => h('button', { key: c.id, onClick: () => toggle(c.id), className: 'chip' + (cats.includes(c.id) ? ' is-active' : '') }, h(Icon, { name: c.icon, size: 15, stroke: 2 }), c.name))),
      h('div', { style: { fontSize: 13.5, fontWeight: 700, margin: '24px 0 11px' } }, 'Minimum rating'),
      h('div', { style: { display: 'flex', gap: 9 } },
        [0, 3, 4, 4.5].map(r => h('button', { key: r, onClick: () => setMinR(r), className: 'chip' + (minR === r ? ' is-active' : '') },
          r === 0 ? 'Any' : [h(StarSolid, { key: 's', size: 13, color: minR === r ? '#fff' : 'var(--star)' }), r + '+']))),
      h('div', { style: { fontSize: 13.5, fontWeight: 700, margin: '24px 0 11px' } }, 'Sort by'),
      h('div', { style: { display: 'flex', flexDirection: 'column', gap: 2 } },
        SORTS.map(s => h('button', { key: s.id, onClick: () => setSort(s.id), style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '13px 2px', fontSize: 15, fontWeight: 600, color: 'var(--ink)' } },
          s.label, sort === s.id && h(Icon, { name: 'check', size: 20, color: 'var(--primary)', stroke: 2.4 })))),
      h('div', { style: { display: 'flex', gap: 12, marginTop: 22 } },
        h('button', { className: 'btn btn-ghost', style: { flex: 1 }, onClick: onClear }, 'Clear all'),
        h('button', { className: 'btn btn-primary', style: { flex: 1.6 }, onClick: onApply }, 'Show results')),
    );
  }

  Object.assign(window, { CitySelect, Home, Search, ListingRow, FeaturedCard, HeartBtn, SectionHead });
})();
