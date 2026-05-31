/* CitiGuide — all-screens overview (mounts every screen as a pinned artboard) */
(function () {
  const h = React.createElement;
  const D = window.CG_DATA;
  const noop = () => {};
  const favs = new Set(['l2', 'l1', 'l3']);
  const L = D.listingById('l2'); // Oba's Palace

  // mini device frame
  function Frame({ children }) {
    return h('div', { style: {
      width: '100%', height: '100%', borderRadius: 34, overflow: 'hidden', position: 'relative',
      background: '#fff', boxShadow: '0 0 0 7px #1b1e21, 0 18px 40px rgba(0,0,0,.18)',
    } }, children);
  }

  const PROFILE = D.PROFILE;

  const SECTIONS = [
    { id: 'auth', title: 'Onboarding & Auth', subtitle: 'First run → account → into the app', boards: [
      { id: 'splash', label: 'Splash', node: () => h(window.Splash) },
      { id: 'login', label: 'Log in', node: () => h(window.Login, { onLogin: noop, onSignup: noop, onForgot: noop }) },
      { id: 'signup', label: 'Sign up', node: () => h(window.Signup, { onCreate: noop, onLogin: noop }) },
      { id: 'forgot', label: 'Forgot password', node: () => h(window.Forgot, { onBack: noop, onSend: noop }) },
      { id: 'forgotSent', label: 'Reset link sent', node: () => h(window.Forgot, { sent: true, onBack: noop }) },
    ] },
    { id: 'discover', title: 'Discover', subtitle: 'Choose a city, browse & search', boards: [
      { id: 'city', label: 'City selection', node: () => h(window.CitySelect, { selected: 'benin', onSelect: noop }) },
      { id: 'home', label: 'Home / Explore', node: () => h(window.Home, { cityId: 'benin', favs, onOpen: noop, onFav: noop, onNav: noop, onSearch: noop, onChangeCity: noop, active: 'home' }) },
      { id: 'search', label: 'Search · suggestions', node: () => h(window.Search, { cityId: 'benin', favs, onOpen: noop, onFav: noop, onNav: noop, active: 'search' }) },
      { id: 'searchres', label: 'Search · results', node: () => h(window.Search, { cityId: 'benin', favs, onOpen: noop, onFav: noop, onNav: noop, active: 'search', initialQuery: 'Museum' }) },
    ] },
    { id: 'listing', title: 'Listing & reviews', subtitle: 'Details → map → reviews', boards: [
      { id: 'details', label: 'Listing details', node: () => h(window.Details, { l: L, isFav: true, onBack: noop, onFav: noop, onMap: noop, onReviews: noop, onAddReview: noop }) },
      { id: 'map', label: 'Map & directions', node: () => h(window.MapView, { l: L, onBack: noop }) },
      { id: 'reviews', label: 'All reviews', node: () => h(window.Reviews, { l: L, onBack: noop, onAdd: noop }) },
      { id: 'addreview', label: 'Write a review', node: () => h(window.AddReview, { l: L, onBack: noop, onSubmit: noop }) },
    ] },
    { id: 'you', title: 'Saved & profile', subtitle: 'Favourites and account', boards: [
      { id: 'favs', label: 'Favourites', node: () => h(window.Favourites, { cityId: 'benin', favs, onOpen: noop, onFav: noop, onNav: noop, onBrowse: noop, active: 'favourites' }) },
      { id: 'profile', label: 'Profile', node: () => h(window.Profile, { profile: PROFILE, favCount: 3, reviewCount: 7, onNav: noop, onEdit: noop, onLogout: noop, notif: true, onNotif: noop, active: 'profile' }) },
      { id: 'edit', label: 'Edit profile', node: () => h(window.EditProfile, { profile: PROFILE, onBack: noop, onSave: noop, notif: true, onNotif: noop }) },
    ] },
    { id: 'states', title: 'System states', subtitle: 'Loading · empty · error', boards: [
      { id: 'loading', label: 'Loading (skeleton)', node: () => h(window.LoadingHome) },
      { id: 'empty', label: 'Empty · no favourites', node: () => h(window.Favourites, { cityId: 'benin', favs: new Set(), onOpen: noop, onFav: noop, onNav: noop, onBrowse: noop, active: 'favourites' }) },
      { id: 'error', label: 'Error · offline', node: () => h(window.ErrorState, { onRetry: noop }) },
    ] },
  ];

  function Overview() {
    return h(window.DesignCanvas, null,
      SECTIONS.map(sec => h(window.DCSection, { key: sec.id, id: sec.id, title: sec.title, subtitle: sec.subtitle },
        sec.boards.map(b => h(window.DCArtboard, { key: b.id, id: b.id, label: b.label, width: 344, height: 718 },
          h(Frame, null, b.node())
        ))
      ))
    );
  }

  window.CitiGuideOverview = Overview;
})();
