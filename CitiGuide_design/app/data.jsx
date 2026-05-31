/* CitiGuide — seed data (Nigerian cities) */
(function () {
  const CATEGORIES = [
    { id: 'attractions', name: 'Attractions', icon: 'landmark', hue: 188 },
    { id: 'restaurants', name: 'Restaurants', icon: 'utensils', hue: 28 },
    { id: 'hotels',      name: 'Hotels',      icon: 'bed',      hue: 214 },
    { id: 'events',      name: 'Events',      icon: 'ticket',   hue: 280 },
  ];

  const CITIES = [
    { id: 'benin', name: 'Benin City', state: 'Edo State', hue: 168,
      tagline: 'Ancient kingdom of bronze & brotherhood',
      description: 'The historic heart of the Benin Kingdom — home to world-famous bronze casting, the Oba’s royal palace and centuries of living heritage.',
      lat: 6.34, lng: 5.62, places: 7 },
    { id: 'ph', name: 'Port Harcourt', state: 'Rivers State', hue: 200,
      tagline: 'The Garden City on the Bonny River',
      description: 'A lively riverside city known for its parks, pepper-soup joints and the colourful Carniriv carnival.',
      lat: 4.81, lng: 7.04, places: 6 },
    { id: 'lagos', name: 'Lagos', state: 'Lagos State', hue: 32,
      tagline: 'Nigeria’s restless creative capital',
      description: 'Beaches, art galleries and a nightlife that never sleeps — the cultural engine of West Africa.',
      lat: 6.45, lng: 3.39, places: 6 },
    { id: 'abuja', name: 'Abuja', state: 'FCT', hue: 256,
      tagline: 'The green & orderly capital',
      description: 'Planned, leafy and calm — rock formations, lakeside parks and modern dining beneath Aso Rock.',
      lat: 9.07, lng: 7.49, places: 5 },
  ];

  // helper to keep listings terse
  let _id = 0;
  const L = (city, cat, name, rating, count, short, opts = {}) => ({
    id: 'l' + (++_id), cityId: city, categoryId: cat, name,
    rating, ratingCount: count, short,
    description: opts.desc || short + ' A favourite among locals and visitors alike, offering a genuine taste of the city’s character and warm hospitality.',
    address: opts.address || '', phone: opts.phone || '+234 80' + (1000000 + _id * 13337).toString().slice(0, 7),
    website: opts.website || (name.toLowerCase().replace(/[^a-z]+/g, '') + '.ng'),
    hours: opts.hours || 'Open · 9:00 AM – 10:00 PM',
    openNow: opts.openNow !== false,
    price: opts.price || '',
    featured: !!opts.featured,
    images: opts.images || 3,
    hue: opts.hue,
    tags: opts.tags || [],
  });

  const LISTINGS = [
    // ── Benin City ──
    L('benin','attractions','Benin National Museum', 4.6, 312, 'Bronze plaques, ivory masks & royal regalia in Ring Road.', { featured:true, address:'Ring Road, Benin City', hours:'Open · 9:00 AM – 5:00 PM', tags:['History','Art','Family'] }),
    L('benin','attractions','Oba’s Palace', 4.8, 540, 'The living seat of the Benin monarchy and its court arts.', { featured:true, address:'Palace Road, Benin City', tags:['Heritage','Guided tour'] }),
    L('benin','attractions','Igun Bronze Casters Street', 4.5, 176, 'A UNESCO-listed street where bronze is still cast by hand.', { address:'Igun Street, Benin City', hours:'Open · 8:00 AM – 6:00 PM', tags:['Craft','Shopping'] }),
    L('benin','restaurants','Uyi Grand Kitchen', 4.4, 220, 'Rich Edo black soup & pounded yam done right.', { price:'₦₦', address:'Sapele Road, Benin City', tags:['Local','Dine-in'] }),
    L('benin','restaurants','Royal Palms Bistro', 4.3, 98, 'Garden dining with grills, jollof and chilled palm wine.', { price:'₦₦', address:'GRA, Benin City', tags:['Outdoor','Bar'] }),
    L('benin','hotels','Randekhi Royal Hotel', 4.5, 410, 'Polished rooms, pool and conference suites in the GRA.', { price:'₦₦₦', address:'Ihama Road, GRA, Benin City', hours:'Reception · 24 hours', featured:true, tags:['Pool','Wi-Fi'] }),
    L('benin','events','Igue Festival', 4.9, 89, 'The royal renewal festival of the Benin Kingdom, every December.', { hours:'Dec 18 – Dec 27 · Annual', address:'Oba’s Palace grounds', price:'Free', tags:['Culture','Annual'] }),

    // ── Port Harcourt ──
    L('ph','attractions','Port Harcourt Pleasure Park', 4.4, 388, 'Fountains, rides and lawns along the waterfront.', { featured:true, address:'Aba Road, Port Harcourt', tags:['Family','Outdoor'] }),
    L('ph','attractions','Isaac Boro Park', 4.1, 142, 'Central green space and city landmark for an easy stroll.', { address:'Station Road, Port Harcourt', price:'Free', tags:['Park','Relax'] }),
    L('ph','restaurants','Kilimanjaro PH', 4.2, 256, 'Fast, fresh jollof, grilled chicken and meat pies.', { price:'₦₦', address:'Olu Obasanjo Rd, Port Harcourt', tags:['Quick','Local'] }),
    L('ph','restaurants','Cilantro Restaurant', 4.6, 174, 'Upscale continental plates with a river view.', { price:'₦₦₦', address:'Aba Road, Port Harcourt', featured:true, tags:['Fine dining'] }),
    L('ph','hotels','Hotel Presidential', 4.0, 520, 'A storied Garden City landmark with gardens & pool.', { price:'₦₦₦', address:'Aba Road, Port Harcourt', hours:'Reception · 24 hours', tags:['Pool','Classic'] }),
    L('ph','events','Carniriv Carnival', 4.8, 64, 'Rivers State’s riot of colour, music and masquerade.', { hours:'Dec · Annual', address:'City-wide, Port Harcourt', price:'Free', featured:true, tags:['Carnival','Music'] }),

    // ── Lagos ──
    L('lagos','attractions','Lekki Conservation Centre', 4.7, 980, 'Canopy walkway and wildlife over coastal wetland.', { featured:true, address:'Lekki-Epe Expressway, Lagos', tags:['Nature','Adventure'] }),
    L('lagos','attractions','Nike Art Gallery', 4.6, 612, 'Five floors of contemporary Nigerian art & textiles.', { address:'Lekki Phase 1, Lagos', price:'Free', tags:['Art','Culture'] }),
    L('lagos','restaurants','Terra Kulture', 4.5, 430, 'Nigerian cuisine, theatre and art under one roof.', { price:'₦₦₦', address:'Victoria Island, Lagos', featured:true, tags:['Culture','Dine-in'] }),
    L('lagos','restaurants','RSVP Lagos', 4.4, 358, 'Chic rooftop dining and cocktails in VI.', { price:'₦₦₦₦', address:'Victoria Island, Lagos', tags:['Rooftop','Bar'] }),
    L('lagos','hotels','Eko Hotel & Suites', 4.3, 1240, 'Lagoon-side icon with pools, spa and convention halls.', { price:'₦₦₦₦', address:'Victoria Island, Lagos', hours:'Reception · 24 hours', featured:true, tags:['Pool','Spa'] }),
    L('lagos','events','Lagos Jazz Series', 4.6, 120, 'Open-air evenings of jazz, soul and afrobeat.', { hours:'Apr · Annual', address:'Muri Okunola Park, Lagos', price:'₦₦', tags:['Music','Nightlife'] }),

    // ── Abuja ──
    L('abuja','attractions','Millennium Park', 4.5, 470, 'Abuja’s largest park — lawns, fountains and river.', { featured:true, address:'Maitama, Abuja', price:'Free', tags:['Park','Family'] }),
    L('abuja','attractions','Jabi Lake & Boardwalk', 4.4, 388, 'Lakeside boardwalk, boats and waterfront cafés.', { address:'Jabi, Abuja', tags:['Lake','Relax'] }),
    L('abuja','attractions','Zuma Rock Viewpoint', 4.7, 210, 'The monolithic “Gateway to Abuja” at Niger State edge.', { address:'Madalla, near Abuja', price:'Free', tags:['Nature','Photo'] }),
    L('abuja','restaurants','Wakkis', 4.5, 296, 'Beloved North-Indian spot — rich curries and naan.', { price:'₦₦₦', address:'Wuse 2, Abuja', featured:true, tags:['Indian','Dine-in'] }),
    L('abuja','hotels','Transcorp Hilton Abuja', 4.4, 1560, 'The capital’s flagship hotel — pools, spa & dining.', { price:'₦₦₦₦', address:'Maitama, Abuja', hours:'Reception · 24 hours', featured:true, tags:['Pool','Spa','Wi-Fi'] }),
  ];

  const REVIEWS = {
    // keyed by listing id; a couple seeded, rest generated
    l1: [
      { user:'Adaeze O.', rating:5, date:'2 weeks ago', likes:14, liked:false, text:'Incredible collection of bronzes. The guide was so knowledgeable about the kingdom’s history — worth every minute.' },
      { user:'Tunde A.',  rating:4, date:'1 month ago', likes:6,  liked:false, text:'Fascinating exhibits. Wish the building was a little cooler inside, but the artefacts make up for it.' },
    ],
    l2: [
      { user:'Ngozi E.', rating:5, date:'5 days ago', likes:22, liked:true, text:'A profound experience. Seeing the court art in its living context is unlike any museum.' },
      { user:'David M.', rating:5, date:'3 weeks ago', likes:9, liked:false, text:'Book the guided tour — the storytelling brings 600 years of history alive.' },
    ],
  };

  const PROFILE = {
    name: 'Amara Okonkwo',
    email: 'amara.okonkwo@gmail.com',
    initials: 'AO',
    phone: '+234 803 114 2200',
    joined: 'Joined March 2025',
    notifications: true,
  };

  window.CG_DATA = { CATEGORIES, CITIES, LISTINGS, REVIEWS, PROFILE };

  // ── lightweight data helpers ──
  window.CG_DATA.catById = (id) => CATEGORIES.find(c => c.id === id);
  window.CG_DATA.cityById = (id) => CITIES.find(c => c.id === id);
  window.CG_DATA.listingById = (id) => LISTINGS.find(l => l.id === id);
  window.CG_DATA.byCity = (cityId) => LISTINGS.filter(l => l.cityId === cityId);
  window.CG_DATA.reviewsFor = (id) => {
    if (REVIEWS[id]) return REVIEWS[id];
    // deterministic generated reviews so every listing has some
    const names = ['Chidi N.','Funke B.','Emeka I.','Sade A.','Ibrahim K.','Grace U.'];
    const texts = [
      'Lovely spot — exactly what the city is about. Will definitely return.',
      'Good value and friendly staff. A solid choice for first-timers.',
      'Really enjoyed our visit. Got a bit busy in the afternoon, so go early.',
      'Clean, well-run and easy to find. Recommended.',
    ];
    const seed = id.charCodeAt(1) || 3;
    return [0,1].map(i => ({
      user: names[(seed + i) % names.length],
      rating: 5 - ((seed + i) % 2),
      date: ['1 week ago','2 weeks ago','last month'][(seed + i) % 3],
      likes: 2 + ((seed * (i+2)) % 11), liked:false,
      text: texts[(seed + i) % texts.length],
    }));
  };
})();
