/* CitiGuide — app orchestrator (navigation + state + tweaks) */
(function () {
  const h = React.createElement;
  const { useState, useEffect, useCallback } = React;
  const D = window.CG_DATA;

  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "primary": "#0B3D5C",
    "accent": "#E2603B",
    "corners": "rounded",
    "typeface": "Plus Jakarta Sans"
  }/*EDITMODE-END*/;

  const CORNERS = {
    sharp:   { sm: '4px',  md: '8px',  lg: '12px', xl: '16px' },
    soft:    { sm: '8px',  md: '12px', lg: '16px', xl: '20px' },
    rounded: { sm: '10px', md: '16px', lg: '22px', xl: '28px' },
  };

  function App({ start = 'splash', autoStart = true, initialCity = 'benin', overrideTweaks }) {
    const [t, setTweak] = window.useTweaks ? window.useTweaks(TWEAK_DEFAULTS) : [TWEAK_DEFAULTS, () => {}];
    const tw = overrideTweaks || t;

    const [stack, setStack] = useState([{ s: start }]);
    const frame = stack[stack.length - 1];
    const [cityId, setCityId] = useState(initialCity);
    const [favs, setFavs] = useState(new Set(['l2', 'l14', 'l8']));
    const [notif, setNotif] = useState(D.PROFILE.notifications);
    const [reviewsByListing, setReviewsByListing] = useState({});
    const [reviewCount, setReviewCount] = useState(7);
    const [toast, setToast] = useState(null);
    const [tab, setTab] = useState('home');

    const screen = frame.s;
    const activeId = frame.id;
    const activeListing = activeId ? D.listingById(activeId) : null;

    const push = useCallback((s, id) => setStack(st => [...st, { s, id: id ?? st[st.length - 1].id }]), []);
    const back = useCallback(() => setStack(st => st.length > 1 ? st.slice(0, -1) : st), []);
    const reset = useCallback((s) => setStack([{ s }]), []);

    const showToast = (msg) => { setToast(msg); clearTimeout(window.__cgToast); window.__cgToast = setTimeout(() => setToast(null), 2200); };

    // splash auto-advance
    useEffect(() => {
      if (screen === 'splash' && autoStart) {
        const id = setTimeout(() => reset('login'), 2200);
        return () => clearTimeout(id);
      }
    }, [screen, autoStart, reset]);

    const toggleFav = (id) => setFavs(f => { const n = new Set(f); if (n.has(id)) n.delete(id); else { n.add(id); showToast('Saved to favourites'); } return n; });

    const onNav = (id) => { setTab(id); reset(id); };

    const reviewsFor = (id) => [...(reviewsByListing[id] || []), ...D.reviewsFor(id)];
    const submitReview = (rating, text) => {
      const id = activeId;
      setReviewsByListing(m => ({ ...m, [id]: [{ user: D.PROFILE.name, rating, date: 'Just now', likes: 0, liked: false, text: text || 'Great place — highly recommend.' }, ...(m[id] || [])] }));
      setReviewCount(c => c + 1);
      back(); showToast('Review posted · thank you!');
    };

    // ── route table ──
    let view;
    switch (screen) {
      case 'splash':  view = h(window.Splash); break;
      case 'login':   view = h(window.Login, { onLogin: () => reset('city'), onSignup: () => push('signup'), onForgot: () => push('forgot') }); break;
      case 'signup':  view = h(window.Signup, { onCreate: () => reset('city'), onLogin: () => back() }); break;
      case 'forgot':  view = h(window.Forgot, { onBack: back, onSend: () => push('forgotSent') }); break;
      case 'forgotSent': view = h(window.Forgot, { sent: true, onBack: () => reset('login') }); break;
      case 'city':    view = h(window.CitySelect, { selected: cityId, onSelect: (id) => { setCityId(id); setTab('home'); reset('home'); } }); break;
      case 'home':    view = h(window.Home, { cityId, favs, onOpen: (id) => push('details', id), onFav: toggleFav, onNav, onSearch: () => { setTab('search'); reset('search'); }, onChangeCity: () => push('city'), active: 'home' }); break;
      case 'search':  view = h(window.Search, { cityId, favs, onOpen: (id) => push('details', id), onFav: toggleFav, onNav, active: 'search' }); break;
      case 'details': view = h(window.Details, { l: activeListing, isFav: favs.has(activeId), onBack: back, onFav: () => toggleFav(activeId), onMap: () => push('map'), onReviews: () => push('reviews'), onAddReview: () => push('addReview'), reviews: reviewsFor(activeId) }); break;
      case 'map':     view = h(window.MapView, { l: activeListing, onBack: back }); break;
      case 'reviews': view = h(window.Reviews, { l: activeListing, onBack: back, onAdd: () => push('addReview'), reviews: reviewsFor(activeId) }); break;
      case 'addReview': view = h(window.AddReview, { l: activeListing, onBack: back, onSubmit: submitReview }); break;
      case 'favourites': view = h(window.Favourites, { cityId, favs, onOpen: (id) => push('details', id), onFav: toggleFav, onNav, onBrowse: onNav.bind(null, 'home'), active: 'favourites' }); break;
      case 'profile': view = h(window.Profile, { profile: D.PROFILE, favCount: favs.size, reviewCount, onNav, onEdit: () => push('editProfile'), onLogout: () => reset('splash'), notif, onNotif: setNotif, active: 'profile' }); break;
      case 'editProfile': view = h(window.EditProfile, { profile: D.PROFILE, onBack: back, onSave: () => { back(); showToast('Profile updated'); }, notif, onNotif: setNotif }); break;
      case 'loading': view = h(window.LoadingHome); break;
      case 'error':   view = h(window.ErrorState, { onRetry: () => reset('home') }); break;
      default: view = h(window.Splash);
    }

    // apply tweak vars
    const c = CORNERS[tw.corners] || CORNERS.rounded;
    const rootStyle = {
      width: '100%', height: '100%',
      '--primary': tw.primary, '--coral': tw.accent, '--star': tw.accent === '#E2603B' ? '#E8A23D' : tw.accent,
      '--r-sm': c.sm, '--r-md': c.md, '--r-lg': c.lg, '--r-xl': c.xl,
      '--font': `'${tw.typeface}', system-ui, sans-serif`,
    };

    return h('div', { style: rootStyle },
      h('div', { key: screen + (activeId || ''), style: { width: '100%', height: '100%' } }, view),
      toast && h('div', { className: 'cg-toast', style: {
        position: 'absolute', bottom: 92, left: '50%', transform: 'translateX(-50%)', zIndex: 90,
        background: 'var(--ink)', color: '#fff', padding: '12px 20px', borderRadius: 100, fontSize: 13.5,
        fontWeight: 600, boxShadow: 'var(--sh-3)', whiteSpace: 'nowrap', display: 'flex', alignItems: 'center', gap: 8,
      } }, h(window.Icon, { name: 'check', size: 16, color: 'var(--success)', stroke: 3 }), toast),

      // Tweaks panel (only when host enables it)
      window.TweaksPanel && !overrideTweaks && h(window.TweaksPanel, null,
        h(window.TweakSection, { label: 'Brand colour' }),
        h(window.TweakColor, { label: 'Primary', value: tw.primary, options: ['#0B3D5C', '#1E5EFF', '#0E7C86', '#1A1A1A'], onChange: v => setTweak('primary', v) }),
        h(window.TweakColor, { label: 'Accent', value: tw.accent, options: ['#E2603B', '#E8A23D', '#2F9E73', '#7A5AE0'], onChange: v => setTweak('accent', v) }),
        h(window.TweakSection, { label: 'Shape & type' }),
        h(window.TweakRadio, { label: 'Corners', value: tw.corners, options: ['sharp', 'soft', 'rounded'], onChange: v => setTweak('corners', v) }),
        h(window.TweakSelect, { label: 'Typeface', value: tw.typeface, options: ['Plus Jakarta Sans', 'Manrope', 'Sora'], onChange: v => setTweak('typeface', v) }),
      ),
    );
  }

  window.CitiGuideApp = App;
  window.CG_TWEAK_DEFAULTS = TWEAK_DEFAULTS;
  window.CG_CORNERS = CORNERS;
})();
