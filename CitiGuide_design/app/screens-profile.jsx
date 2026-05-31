/* CitiGuide — reviews, favourites, profile & states */
(function () {
  const { Icon, StarSolid, DeviceShell, Photo, Stars, TopBar, BottomNav, EmptyState, ListingRow, ReviewItem, RatingSummary } = window;
  const D = window.CG_DATA;
  const h = React.createElement;
  const { useState } = React;

  function Toggle({ on, onChange }) {
    return h('button', { onClick: () => onChange(!on), style: {
      width: 50, height: 30, borderRadius: 100, background: on ? 'var(--primary)' : 'var(--bg-alt-2)',
      padding: 3, display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start', transition: 'background .2s', flexShrink: 0,
    } }, h('div', { style: { width: 24, height: 24, borderRadius: 999, background: '#fff', boxShadow: 'var(--sh-1)', transition: 'all .2s' } }));
  }

  /* ── All reviews ── */
  function Reviews({ l, onBack, onAdd, reviews }) {
    const revs = reviews || D.reviewsFor(l.id);
    return h(DeviceShell, { statusTone: 'dark' },
      h(TopBar, { title: 'Reviews', sub: l.name, onBack }),
      h('div', { className: 'cg-scroll', style: { padding: '4px 20px 0' } },
        h('div', { style: { padding: '14px 0 4px' } }, h(RatingSummary, { l, onAdd })),
        h('div', { className: 'hr', style: { margin: '4px 0 0' } }),
        revs.map((r, i) => h(ReviewItem, { key: i, r })),
        h('div', { style: { height: 90 } }),
      ),
      h('div', { style: { position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 20px 30px', background: 'rgba(255,255,255,.94)', backdropFilter: 'blur(10px)', borderTop: '1px solid var(--line)' } },
        h('button', { onClick: onAdd, className: 'btn btn-primary' }, h(Icon, { name: 'plus', size: 19, stroke: 2.4 }), 'Write a review')),
    );
  }

  /* ── Add review ── */
  function AddReview({ l, onBack, onSubmit }) {
    const [rating, setRating] = useState(0);
    const [text, setText] = useState('');
    const cat = D.catById(l.categoryId);
    const labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];
    return h(DeviceShell, { statusTone: 'dark' },
      h(TopBar, { title: 'Write a review', onBack }),
      h('div', { className: 'cg-scroll', style: { padding: '8px 20px 0' } },
        h('div', { style: { display: 'flex', gap: 12, alignItems: 'center', padding: '8px 0 18px' } },
          h('div', { style: { width: 56, height: 56, borderRadius: 14, overflow: 'hidden', flexShrink: 0 } }, h(Photo, { hue: l.hue ?? cat.hue, cat: cat.icon })),
          h('div', null, h('div', { className: 't-title', style: { fontSize: 16.5 } }, l.name), h('div', { style: { fontSize: 13, color: 'var(--muted)', marginTop: 2 } }, l.address))),
        h('div', { className: 'hr' }),
        h('div', { style: { textAlign: 'center', padding: '22px 0' } },
          h('div', { style: { fontSize: 15, fontWeight: 700, marginBottom: 14 } }, 'How was your visit?'),
          h('div', { style: { display: 'flex', justifyContent: 'center', gap: 8 } },
            [1,2,3,4,5].map(n => h('button', { key: n, onClick: () => setRating(n), style: { transform: rating >= n ? 'scale(1.05)' : 'scale(1)', transition: 'transform .12s' } },
              h(StarSolid, { size: 40, color: rating >= n ? 'var(--star)' : '#E2E7EB' })))),
          h('div', { style: { height: 20, marginTop: 12, fontSize: 15, fontWeight: 700, color: 'var(--star)' } }, labels[rating])),
        h('div', { className: 'field', style: { height: 'auto', alignItems: 'flex-start', padding: 16 } },
          h('textarea', { value: text, onChange: e => setText(e.target.value), placeholder: 'Share details of your experience — what stood out?', rows: 5, style: { flex: 1, border: 'none', outline: 'none', resize: 'none', fontSize: 15, lineHeight: 1.5, color: 'var(--ink)', background: 'none', width: '100%' } })),
        h('div', { style: { display: 'flex', alignItems: 'center', gap: 8, marginTop: 14, color: 'var(--muted)' } },
          h('button', { style: { display: 'flex', alignItems: 'center', gap: 7, fontSize: 13.5, fontWeight: 700, color: 'var(--primary)', border: '1.5px dashed var(--line)', padding: '10px 14px', borderRadius: 12 } }, h(Icon, { name: 'camera', size: 18, stroke: 2 }), 'Add photos')),
        h('div', { style: { height: 100 } }),
      ),
      h('div', { style: { position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 20px 30px', background: 'rgba(255,255,255,.94)', backdropFilter: 'blur(10px)', borderTop: '1px solid var(--line)' } },
        h('button', { onClick: () => onSubmit && onSubmit(rating, text), disabled: rating === 0, className: 'btn btn-primary', style: { opacity: rating === 0 ? .5 : 1 } }, 'Post review')),
    );
  }

  /* ── Favourites ── */
  function Favourites({ cityId, favs, onOpen, onFav, onNav, onBrowse, active = 'favourites' }) {
    const list = D.LISTINGS.filter(l => favs.has(l.id));
    return h(DeviceShell, { statusTone: 'dark' },
      h('div', { style: { padding: '52px 20px 10px', flexShrink: 0 } },
        h('div', { className: 't-display', style: { fontSize: 30 } }, 'Saved'),
        h('div', { style: { fontSize: 14.5, color: 'var(--muted)', marginTop: 4 } }, list.length ? `${list.length} place${list.length > 1 ? 's' : ''} you love` : 'Your favourite places, in one spot')),
      list.length === 0
        ? h(EmptyState, { icon: 'heart', title: 'No favourites yet', body: 'Tap the heart on any place to save it here for quick access later.', action: h('button', { className: 'btn btn-primary', onClick: onBrowse }, 'Explore places') })
        : h('div', { className: 'cg-scroll', style: { padding: '6px 20px 16px' } },
            list.map(l => h(React.Fragment, { key: l.id },
              h(ListingRow, { l, isFav: true, onFav: () => onFav(l.id), onOpen }),
              h('div', { className: 'hr', style: { margin: '4px 0' } }))),
            h('div', { style: { height: 8 } })),
      h(BottomNav, { active, onNav }),
    );
  }

  /* ── Profile ── */
  function Profile({ profile, favCount, reviewCount, onNav, onEdit, onLogout, notif, onNotif, active = 'profile' }) {
    const menu = [
      { icon: 'edit', label: 'Edit profile', onClick: onEdit },
      { icon: 'star', label: 'My reviews', meta: reviewCount },
      { icon: 'mapPin', label: 'Change city' },
      { icon: 'info', label: 'Help & support' },
    ];
    return h(DeviceShell, { statusTone: 'dark', bg: 'var(--bg-alt)' },
      h('div', { className: 'cg-scroll' },
        // header card
        h('div', { style: { padding: '52px 20px 20px', background: '#fff', borderBottom: '1px solid var(--line)' } },
          h('div', { style: { display: 'flex', alignItems: 'center', gap: 15 } },
            h('div', { style: { width: 72, height: 72, borderRadius: 999, background: 'var(--primary)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 26, flexShrink: 0 } }, profile.initials),
            h('div', { style: { flex: 1, minWidth: 0 } },
              h('div', { className: 't-title', style: { fontSize: 21 } }, profile.name),
              h('div', { style: { fontSize: 13.5, color: 'var(--muted)', marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' } }, profile.email),
              h('div', { style: { fontSize: 12.5, color: 'var(--muted-2)', marginTop: 3 } }, profile.joined)),
            h('button', { onClick: onEdit, style: window.iconBtn }, h(Icon, { name: 'edit', size: 20, color: 'var(--primary)' }))),
          // stats
          h('div', { style: { display: 'flex', marginTop: 20, background: 'var(--bg-alt)', borderRadius: 16, padding: '14px 0' } },
            [['Saved', favCount], ['Reviews', reviewCount], ['Cities', 4]].map(([k, v], i) =>
              h('div', { key: k, style: { flex: 1, textAlign: 'center', borderLeft: i ? '1px solid var(--line)' : 'none' } },
                h('div', { className: 't-title', style: { fontSize: 21, color: 'var(--primary)' } }, v),
                h('div', { style: { fontSize: 12, color: 'var(--muted)', marginTop: 2, fontWeight: 600 } }, k)))),
        ),
        // menu
        h('div', { style: { padding: '16px 20px' } },
          h('div', { className: 'card', style: { padding: '4px 16px' } },
            menu.map((m, i) => h('button', { key: m.label, onClick: m.onClick, style: { display: 'flex', alignItems: 'center', gap: 14, width: '100%', padding: '15px 0', borderBottom: i < menu.length - 1 ? '1px solid var(--line-2)' : 'none', textAlign: 'left' } },
              h('div', { style: { width: 38, height: 38, borderRadius: 11, background: 'var(--primary-tint)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' } }, h(Icon, { name: m.icon, size: 19, stroke: 1.9 })),
              h('span', { style: { flex: 1, fontSize: 15.5, fontWeight: 600 } }, m.label),
              m.meta != null && h('span', { style: { fontSize: 13.5, color: 'var(--muted)', fontWeight: 600 } }, m.meta),
              h(Icon, { name: 'chevR', size: 19, color: 'var(--muted-2)' })))),
          // notifications row
          h('div', { className: 'card', style: { padding: '15px 16px', marginTop: 14, display: 'flex', alignItems: 'center', gap: 14 } },
            h('div', { style: { width: 38, height: 38, borderRadius: 11, background: 'var(--primary-tint)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' } }, h(Icon, { name: 'bell', size: 19, stroke: 1.9 })),
            h('div', { style: { flex: 1 } }, h('div', { style: { fontSize: 15.5, fontWeight: 600 } }, 'Notifications'), h('div', { style: { fontSize: 12.5, color: 'var(--muted)', marginTop: 1 } }, 'Events & new places')),
            h(Toggle, { on: notif, onChange: onNotif })),
          h('button', { onClick: onLogout, className: 'card', style: { padding: '15px 16px', marginTop: 14, display: 'flex', alignItems: 'center', gap: 14, width: '100%', color: 'var(--danger)' } },
            h('div', { style: { width: 38, height: 38, borderRadius: 11, background: 'rgba(216,85,63,.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' } }, h(Icon, { name: 'logout', size: 19, stroke: 1.9 })),
            h('span', { style: { fontSize: 15.5, fontWeight: 700 } }, 'Log out')),
          h('div', { style: { textAlign: 'center', fontSize: 12, color: 'var(--muted-2)', marginTop: 18 } }, 'CitiGuide v1.0 · MVP'),
        ),
      ),
      h(BottomNav, { active, onNav }),
    );
  }

  /* ── Edit profile ── */
  function EditProfile({ profile, onBack, onSave, notif, onNotif }) {
    const [name, setName] = useState(profile.name);
    const [phone, setPhone] = useState(profile.phone);
    return h(DeviceShell, { statusTone: 'dark' },
      h(TopBar, { title: 'Edit profile', onBack, right: h('button', { onClick: onSave, style: { fontSize: 15, fontWeight: 800, color: 'var(--primary)', padding: '0 12px' } }, 'Save') }),
      h('div', { className: 'cg-scroll', style: { padding: '8px 20px 0' } },
        h('div', { style: { display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '14px 0 24px' } },
          h('div', { style: { position: 'relative' } },
            h('div', { style: { width: 96, height: 96, borderRadius: 999, background: 'var(--primary)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 34 } }, profile.initials),
            h('button', { style: { position: 'absolute', right: -2, bottom: -2, width: 34, height: 34, borderRadius: 999, background: '#fff', boxShadow: 'var(--sh-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)', border: '2px solid #fff' } }, h(Icon, { name: 'camera', size: 17, stroke: 2 }))),
          h('button', { style: { marginTop: 12, fontSize: 13.5, fontWeight: 700, color: 'var(--primary)' } }, 'Change photo')),
        h(window.Input, { icon: 'user', label: 'Full name', value: name, onChange: setName }),
        h(window.Input, { icon: 'phone', label: 'Phone', value: phone, onChange: setPhone }),
        h('label', { style: { display: 'block', marginBottom: 16 } },
          h('span', { className: 'field-label' }, 'Email'),
          h('div', { className: 'field', style: { background: 'var(--bg-alt)', borderColor: 'var(--line-2)' } },
            h(Icon, { name: 'mail', size: 19, color: 'var(--muted-2)' }),
            h('input', { value: profile.email, disabled: true, style: { color: 'var(--muted)' } }),
            h(Icon, { name: 'lock', size: 16, color: 'var(--muted-2)' }))),
        h('div', { style: { display: 'flex', alignItems: 'center', gap: 14, padding: '6px 2px 0' } },
          h('div', { style: { flex: 1 } }, h('div', { style: { fontSize: 15, fontWeight: 600 } }, 'Push notifications'), h('div', { style: { fontSize: 12.5, color: 'var(--muted)', marginTop: 1 } }, 'Events & recommendations')),
          h(Toggle, { on: notif, onChange: onNotif })),
      ),
    );
  }

  /* ── Loading (skeleton) ── */
  function LoadingHome() {
    return h(DeviceShell, { statusTone: 'light', bg: 'var(--bg-alt)' },
      h('div', { className: 'cg-scroll' },
        h('div', { className: 'skeleton', style: { height: 268, borderRadius: 0 } }),
        h('div', { style: { padding: '0 20px', marginTop: -26 } }, h('div', { className: 'skeleton', style: { height: 54, borderRadius: 16 } })),
        h('div', { style: { display: 'flex', gap: 9, padding: '20px 20px 4px' } }, [60, 96, 90, 80].map((w, i) => h('div', { key: i, className: 'skeleton', style: { width: w, height: 38, borderRadius: 100 } }))),
        h('div', { style: { display: 'flex', gap: 14, padding: '18px 20px' } }, [0, 1].map(i => h('div', { key: i, className: 'skeleton', style: { width: 246, height: 232, borderRadius: 20, flexShrink: 0 } }))),
        h('div', { style: { padding: '8px 20px', display: 'flex', flexDirection: 'column', gap: 18 } },
          [0, 1, 2].map(i => h('div', { key: i, style: { display: 'flex', gap: 13 } },
            h('div', { className: 'skeleton', style: { width: 92, height: 92, borderRadius: 16, flexShrink: 0 } }),
            h('div', { style: { flex: 1, paddingTop: 6 } },
              h('div', { className: 'skeleton', style: { width: '40%', height: 11, marginBottom: 10 } }),
              h('div', { className: 'skeleton', style: { width: '75%', height: 16, marginBottom: 10 } }),
              h('div', { className: 'skeleton', style: { width: '55%', height: 12 } }))))),
      ),
    );
  }

  /* ── Error state ── */
  function ErrorState({ onRetry }) {
    return h(DeviceShell, { statusTone: 'dark' },
      h(EmptyState, { icon: 'cloud', title: 'No connection', body: 'We couldn’t load places right now. Check your internet and try again.', action: h('button', { className: 'btn btn-primary', onClick: onRetry }, h(Icon, { name: 'refresh', size: 18, stroke: 2.2 }), 'Try again') }),
    );
  }

  Object.assign(window, { Reviews, AddReview, Favourites, Profile, EditProfile, LoadingHome, ErrorState, Toggle });
})();
