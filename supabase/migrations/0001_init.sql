-- ============================================================================
-- CitiGuide — full backend schema, security, triggers, seed data & storage
-- Paste this whole file into the Supabase SQL Editor and click "Run".
-- Safe to re-run: it drops and recreates the CitiGuide objects.
-- ============================================================================

-- ── extensions ──────────────────────────────────────────────────────────────
create extension if not exists pgcrypto;          -- gen_random_uuid()

-- ── clean slate (so the script is idempotent) ───────────────────────────────
drop table if exists public.favourites    cascade;
drop table if exists public.review_likes  cascade;
drop table if exists public.reviews       cascade;
drop table if exists public.listing_images cascade;
drop table if exists public.listings      cascade;
drop table if exists public.categories    cascade;
drop table if exists public.cities        cascade;
drop table if exists public.profiles      cascade;

-- ============================================================================
-- TABLES
-- ============================================================================

create table public.profiles (
  id                   uuid primary key references auth.users(id) on delete cascade,
  full_name            text,
  avatar_url           text,
  phone                text,
  notification_enabled boolean default true,
  role                 text default 'user' check (role in ('user','admin')),
  created_at           timestamptz default now(),
  updated_at           timestamptz default now()
);

create table public.cities (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text unique not null,
  state       text,                                 -- e.g. "Edo State"
  tagline     text,
  description text,
  image_url   text,
  latitude    double precision,
  longitude   double precision,
  hue         double precision default 200,         -- placeholder fallback tint
  is_active   boolean default true,
  sort_order  integer default 0,
  created_at  timestamptz default now()
);

create table public.categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  slug       text unique not null,
  icon       text,
  hue        double precision default 200,
  created_at timestamptz default now()
);

create table public.listings (
  id                uuid primary key default gen_random_uuid(),
  city_id           uuid references public.cities(id) on delete cascade,
  category_id       uuid references public.categories(id),
  name              text not null,
  slug              text unique not null,
  short_description text,
  description       text,
  cover_image_url   text,
  website_url       text,
  phone             text,
  email             text,
  address           text,
  latitude          double precision,
  longitude         double precision,
  opening_hours     text,
  price             text,                            -- "₦₦", "Free", ...
  open_now          boolean default true,
  rating_average    numeric default 0,
  rating_count      integer default 0,
  tags              text[] default '{}',
  is_featured       boolean default false,
  is_active         boolean default true,
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

create table public.listing_images (
  id         uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete cascade,
  image_url  text not null,
  sort_order integer default 0,
  created_at timestamptz default now()
);

-- NOTE: user_id is nullable and author_name is denormalised so (a) we can seed
-- demo reviews without a user, and (b) we can display an author without needing
-- read access to other people's profiles (which RLS forbids).
create table public.reviews (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid references public.listings(id) on delete cascade,
  user_id     uuid references auth.users(id) on delete cascade,
  author_name text,
  rating      integer not null check (rating between 1 and 5),
  comment     text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now(),
  unique (listing_id, user_id)
);

create table public.review_likes (
  id         uuid primary key default gen_random_uuid(),
  review_id  uuid references public.reviews(id) on delete cascade,
  user_id    uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  unique (review_id, user_id)
);

create table public.favourites (
  id         uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete cascade,
  user_id    uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  unique (listing_id, user_id)
);

-- ============================================================================
-- HELPER FUNCTIONS & TRIGGERS
-- ============================================================================

-- is the current user an admin?
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

-- auto-create a profile row when a new auth user signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', 'New User'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- keep updated_at fresh
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create trigger trg_profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();
create trigger trg_listings_touch before update on public.listings
  for each row execute function public.touch_updated_at();

-- Post a review (or update your existing one) and blend the listing rating.
-- Keeps the curated historical rating_count meaningful instead of resetting it.
create or replace function public.add_review(
  p_listing_id uuid, p_rating integer, p_comment text)
returns void
language plpgsql security definer set search_path = public as $$
declare
  v_name text;
  v_avg numeric;
  v_cnt integer;
begin
  if auth.uid() is null then raise exception 'Must be signed in'; end if;

  select full_name into v_name from public.profiles where id = auth.uid();

  insert into public.reviews (listing_id, user_id, author_name, rating, comment)
  values (p_listing_id, auth.uid(), coalesce(v_name,'A user'), p_rating, p_comment)
  on conflict (listing_id, user_id)
  do update set rating = excluded.rating, comment = excluded.comment, updated_at = now();

  select rating_average, rating_count into v_avg, v_cnt
  from public.listings where id = p_listing_id;

  -- blended weighted average against the curated baseline
  update public.listings
  set rating_average = round(((coalesce(v_avg,0) * v_cnt) + p_rating) / (v_cnt + 1), 1),
      rating_count   = v_cnt + 1
  where id = p_listing_id;
end;
$$;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.profiles       enable row level security;
alter table public.cities         enable row level security;
alter table public.categories     enable row level security;
alter table public.listings       enable row level security;
alter table public.listing_images enable row level security;
alter table public.reviews        enable row level security;
alter table public.review_likes   enable row level security;
alter table public.favourites     enable row level security;

-- profiles: read/update your own; admins manage all
create policy profiles_self_read   on public.profiles for select using (auth.uid() = id or public.is_admin());
create policy profiles_self_insert on public.profiles for insert with check (auth.uid() = id);
create policy profiles_self_update on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy profiles_admin_all   on public.profiles for all using (public.is_admin()) with check (public.is_admin());

-- public catalogue tables: everyone reads; admins write
create policy cities_read   on public.cities     for select using (is_active or public.is_admin());
create policy cities_admin  on public.cities     for all    using (public.is_admin()) with check (public.is_admin());
create policy cats_read     on public.categories for select using (true);
create policy cats_admin    on public.categories for all    using (public.is_admin()) with check (public.is_admin());
create policy listings_read on public.listings   for select using (is_active or public.is_admin());
create policy listings_admin on public.listings  for all    using (public.is_admin()) with check (public.is_admin());
create policy limg_read     on public.listing_images for select using (true);
create policy limg_admin    on public.listing_images for all using (public.is_admin()) with check (public.is_admin());

-- reviews: everyone reads; authors manage their own; admins moderate
create policy reviews_read       on public.reviews for select using (true);
create policy reviews_own_insert on public.reviews for insert with check (auth.uid() = user_id);
create policy reviews_own_update on public.reviews for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy reviews_own_delete on public.reviews for delete using (auth.uid() = user_id);
create policy reviews_admin_del  on public.reviews for delete using (public.is_admin());

-- review likes: everyone reads; you manage your own
create policy likes_read   on public.review_likes for select using (true);
create policy likes_insert on public.review_likes for insert with check (auth.uid() = user_id);
create policy likes_delete on public.review_likes for delete using (auth.uid() = user_id);

-- favourites: private to the owner
create policy favs_read   on public.favourites for select using (auth.uid() = user_id);
create policy favs_insert on public.favourites for insert with check (auth.uid() = user_id);
create policy favs_delete on public.favourites for delete using (auth.uid() = user_id);

-- ============================================================================
-- STORAGE  (public bucket for city / listing imagery)
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('city-guide-images', 'city-guide-images', true)
on conflict (id) do nothing;

drop policy if exists cg_img_read   on storage.objects;
drop policy if exists cg_img_write  on storage.objects;
drop policy if exists cg_img_update on storage.objects;
drop policy if exists cg_img_delete on storage.objects;

create policy cg_img_read   on storage.objects for select using (bucket_id = 'city-guide-images');
create policy cg_img_write  on storage.objects for insert with check (bucket_id = 'city-guide-images' and public.is_admin());
create policy cg_img_update on storage.objects for update using (bucket_id = 'city-guide-images' and public.is_admin());
create policy cg_img_delete on storage.objects for delete using (bucket_id = 'city-guide-images' and public.is_admin());

-- ============================================================================
-- SEED DATA
-- ============================================================================

insert into public.categories (name, slug, icon, hue) values
  ('Attractions', 'attractions', 'landmark', 188),
  ('Restaurants', 'restaurants', 'utensils', 28),
  ('Hotels',      'hotels',      'bed',      214),
  ('Events',      'events',      'ticket',   280);

insert into public.cities (name, slug, state, tagline, description, image_url, latitude, longitude, hue, sort_order) values
  ('Benin City','benin','Edo State','Ancient kingdom of bronze & brotherhood',
   'The historic heart of the Benin Kingdom — home to world-famous bronze casting, the Oba''s royal palace and centuries of living heritage.',
   'https://loremflickr.com/800/600/benin,city?lock=11', 6.34, 5.62, 168, 1),
  ('Port Harcourt','ph','Rivers State','The Garden City on the Bonny River',
   'A lively riverside city known for its parks, pepper-soup joints and the colourful Carniriv carnival.',
   'https://loremflickr.com/800/600/river,city?lock=12', 4.81, 7.04, 200, 2),
  ('Lagos','lagos','Lagos State','Nigeria''s restless creative capital',
   'Beaches, art galleries and a nightlife that never sleeps — the cultural engine of West Africa.',
   'https://loremflickr.com/800/600/lagos,city?lock=13', 6.45, 3.39, 32, 3),
  ('Abuja','abuja','FCT','The green & orderly capital',
   'Planned, leafy and calm — rock formations, lakeside parks and modern dining beneath Aso Rock.',
   'https://loremflickr.com/800/600/abuja,city?lock=14', 9.07, 7.49, 256, 4);

-- listings (helper: image keyword per category keeps photos topical)
insert into public.listings
  (city_id, category_id, name, slug, short_description, description, cover_image_url,
   address, opening_hours, price, tags, is_featured, rating_average, rating_count, open_now,
   latitude, longitude)
select c.id, cat.id, v.name, v.slug, v.short, v.descr, v.img, v.addr, v.hours, v.price,
       v.tags, v.feat, v.rating, v.cnt, true, ci.latitude, ci.longitude
from (values
  -- city_slug, cat_slug, name, slug, short, descr, img, addr, hours, price, tags, featured, rating, count
  ('benin','attractions','Benin National Museum','benin-national-museum','Bronze plaques, ivory masks & royal regalia in Ring Road.','Bronze plaques, ivory masks & royal regalia in Ring Road. A favourite among locals and visitors alike.','https://loremflickr.com/800/600/museum?lock=101','Ring Road, Benin City','Open · 9:00 AM – 5:00 PM','',array['History','Art','Family'],true,4.6,312),
  ('benin','attractions','Oba''s Palace','benin-obas-palace','The living seat of the Benin monarchy and its court arts.','The living seat of the Benin monarchy and its court arts. A genuine taste of the city''s heritage.','https://loremflickr.com/800/600/palace?lock=102','Palace Road, Benin City','Open · 9:00 AM – 10:00 PM','',array['Heritage','Guided tour'],true,4.8,540),
  ('benin','attractions','Igun Bronze Casters Street','benin-igun-street','A UNESCO-listed street where bronze is still cast by hand.','A UNESCO-listed street where bronze is still cast by hand.','https://loremflickr.com/800/600/bronze,craft?lock=103','Igun Street, Benin City','Open · 8:00 AM – 6:00 PM','',array['Craft','Shopping'],false,4.5,176),
  ('benin','restaurants','Uyi Grand Kitchen','benin-uyi-grand','Rich Edo black soup & pounded yam done right.','Rich Edo black soup & pounded yam done right.','https://loremflickr.com/800/600/restaurant,food?lock=104','Sapele Road, Benin City','Open · 9:00 AM – 10:00 PM','₦₦',array['Local','Dine-in'],false,4.4,220),
  ('benin','restaurants','Royal Palms Bistro','benin-royal-palms','Garden dining with grills, jollof and chilled palm wine.','Garden dining with grills, jollof and chilled palm wine.','https://loremflickr.com/800/600/bistro,dining?lock=105','GRA, Benin City','Open · 9:00 AM – 10:00 PM','₦₦',array['Outdoor','Bar'],false,4.3,98),
  ('benin','hotels','Randekhi Royal Hotel','benin-randekhi','Polished rooms, pool and conference suites in the GRA.','Polished rooms, pool and conference suites in the GRA.','https://loremflickr.com/800/600/hotel,room?lock=106','Ihama Road, GRA, Benin City','Reception · 24 hours','₦₦₦',array['Pool','Wi-Fi'],true,4.5,410),
  ('benin','events','Igue Festival','benin-igue-festival','The royal renewal festival of the Benin Kingdom, every December.','The royal renewal festival of the Benin Kingdom, every December.','https://loremflickr.com/800/600/festival?lock=107','Oba''s Palace grounds','Dec 18 – Dec 27 · Annual','Free',array['Culture','Annual'],false,4.9,89),

  ('ph','attractions','Port Harcourt Pleasure Park','ph-pleasure-park','Fountains, rides and lawns along the waterfront.','Fountains, rides and lawns along the waterfront.','https://loremflickr.com/800/600/park,fountain?lock=108','Aba Road, Port Harcourt','Open · 9:00 AM – 10:00 PM','',array['Family','Outdoor'],true,4.4,388),
  ('ph','attractions','Isaac Boro Park','ph-isaac-boro','Central green space and city landmark for an easy stroll.','Central green space and city landmark for an easy stroll.','https://loremflickr.com/800/600/park,green?lock=109','Station Road, Port Harcourt','Open · 9:00 AM – 10:00 PM','Free',array['Park','Relax'],false,4.1,142),
  ('ph','restaurants','Kilimanjaro PH','ph-kilimanjaro','Fast, fresh jollof, grilled chicken and meat pies.','Fast, fresh jollof, grilled chicken and meat pies.','https://loremflickr.com/800/600/jollof,food?lock=110','Olu Obasanjo Rd, Port Harcourt','Open · 9:00 AM – 10:00 PM','₦₦',array['Quick','Local'],false,4.2,256),
  ('ph','restaurants','Cilantro Restaurant','ph-cilantro','Upscale continental plates with a river view.','Upscale continental plates with a river view.','https://loremflickr.com/800/600/fine,dining?lock=111','Aba Road, Port Harcourt','Open · 9:00 AM – 10:00 PM','₦₦₦',array['Fine dining'],true,4.6,174),
  ('ph','hotels','Hotel Presidential','ph-presidential','A storied Garden City landmark with gardens & pool.','A storied Garden City landmark with gardens & pool.','https://loremflickr.com/800/600/hotel,pool?lock=112','Aba Road, Port Harcourt','Reception · 24 hours','₦₦₦',array['Pool','Classic'],false,4.0,520),
  ('ph','events','Carniriv Carnival','ph-carniriv','Rivers State''s riot of colour, music and masquerade.','Rivers State''s riot of colour, music and masquerade.','https://loremflickr.com/800/600/carnival?lock=113','City-wide, Port Harcourt','Dec · Annual','Free',array['Carnival','Music'],true,4.8,64),

  ('lagos','attractions','Lekki Conservation Centre','lagos-lekki-conservation','Canopy walkway and wildlife over coastal wetland.','Canopy walkway and wildlife over coastal wetland.','https://loremflickr.com/800/600/nature,forest?lock=114','Lekki-Epe Expressway, Lagos','Open · 9:00 AM – 10:00 PM','',array['Nature','Adventure'],true,4.7,980),
  ('lagos','attractions','Nike Art Gallery','lagos-nike-art','Five floors of contemporary Nigerian art & textiles.','Five floors of contemporary Nigerian art & textiles.','https://loremflickr.com/800/600/art,gallery?lock=115','Lekki Phase 1, Lagos','Open · 9:00 AM – 10:00 PM','Free',array['Art','Culture'],false,4.6,612),
  ('lagos','restaurants','Terra Kulture','lagos-terra-kulture','Nigerian cuisine, theatre and art under one roof.','Nigerian cuisine, theatre and art under one roof.','https://loremflickr.com/800/600/restaurant,african?lock=116','Victoria Island, Lagos','Open · 9:00 AM – 10:00 PM','₦₦₦',array['Culture','Dine-in'],true,4.5,430),
  ('lagos','restaurants','RSVP Lagos','lagos-rsvp','Chic rooftop dining and cocktails in VI.','Chic rooftop dining and cocktails in VI.','https://loremflickr.com/800/600/rooftop,cocktail?lock=117','Victoria Island, Lagos','Open · 9:00 AM – 10:00 PM','₦₦₦₦',array['Rooftop','Bar'],false,4.4,358),
  ('lagos','hotels','Eko Hotel & Suites','lagos-eko-hotel','Lagoon-side icon with pools, spa and convention halls.','Lagoon-side icon with pools, spa and convention halls.','https://loremflickr.com/800/600/luxury,hotel?lock=118','Victoria Island, Lagos','Reception · 24 hours','₦₦₦₦',array['Pool','Spa'],true,4.3,1240),
  ('lagos','events','Lagos Jazz Series','lagos-jazz','Open-air evenings of jazz, soul and afrobeat.','Open-air evenings of jazz, soul and afrobeat.','https://loremflickr.com/800/600/jazz,concert?lock=119','Muri Okunola Park, Lagos','Apr · Annual','₦₦',array['Music','Nightlife'],false,4.6,120),

  ('abuja','attractions','Millennium Park','abuja-millennium-park','Abuja''s largest park — lawns, fountains and river.','Abuja''s largest park — lawns, fountains and river.','https://loremflickr.com/800/600/park,lawn?lock=120','Maitama, Abuja','Open · 9:00 AM – 10:00 PM','Free',array['Park','Family'],true,4.5,470),
  ('abuja','attractions','Jabi Lake & Boardwalk','abuja-jabi-lake','Lakeside boardwalk, boats and waterfront cafés.','Lakeside boardwalk, boats and waterfront cafés.','https://loremflickr.com/800/600/lake,boardwalk?lock=121','Jabi, Abuja','Open · 9:00 AM – 10:00 PM','',array['Lake','Relax'],false,4.4,388),
  ('abuja','attractions','Zuma Rock Viewpoint','abuja-zuma-rock','The monolithic Gateway to Abuja at Niger State edge.','The monolithic Gateway to Abuja at Niger State edge.','https://loremflickr.com/800/600/rock,mountain?lock=122','Madalla, near Abuja','Open · 9:00 AM – 10:00 PM','Free',array['Nature','Photo'],false,4.7,210),
  ('abuja','restaurants','Wakkis','abuja-wakkis','Beloved North-Indian spot — rich curries and naan.','Beloved North-Indian spot — rich curries and naan.','https://loremflickr.com/800/600/indian,curry?lock=123','Wuse 2, Abuja','Open · 9:00 AM – 10:00 PM','₦₦₦',array['Indian','Dine-in'],true,4.5,296),
  ('abuja','hotels','Transcorp Hilton Abuja','abuja-transcorp-hilton','The capital''s flagship hotel — pools, spa & dining.','The capital''s flagship hotel — pools, spa & dining.','https://loremflickr.com/800/600/hotel,luxury?lock=124','Maitama, Abuja','Reception · 24 hours','₦₦₦₦',array['Pool','Spa','Wi-Fi'],true,4.4,1560)
) as v(city_slug, cat_slug, name, slug, short, descr, img, addr, hours, price, tags, feat, rating, cnt)
join public.cities ci      on ci.slug  = v.city_slug
join public.cities c       on c.slug   = v.city_slug
join public.categories cat on cat.slug = v.cat_slug;

-- a few seeded demo reviews (author_name only, no user_id)
insert into public.reviews (listing_id, author_name, rating, comment, created_at)
select l.id, r.author, r.rating, r.comment, now() - (r.days || ' days')::interval
from (values
  ('benin-national-museum','Adaeze O.',5,'Incredible collection of bronzes. The guide was so knowledgeable about the kingdom''s history — worth every minute.',14),
  ('benin-national-museum','Tunde A.',4,'Fascinating exhibits. Wish the building was a little cooler inside, but the artefacts make up for it.',32),
  ('benin-obas-palace','Ngozi E.',5,'A profound experience. Seeing the court art in its living context is unlike any museum.',5),
  ('benin-obas-palace','David M.',5,'Book the guided tour — the storytelling brings 600 years of history alive.',21),
  ('lagos-lekki-conservation','Funke B.',5,'The canopy walkway is thrilling and the monkeys are everywhere. Go early.',7),
  ('abuja-transcorp-hilton','Emeka I.',4,'Solid, dependable luxury. The pool area is the highlight.',12)
) as r(slug, author, rating, comment, days)
join public.listings l on l.slug = r.slug;

-- ============================================================================
-- DONE.
--  • Sign up in the app, then promote yourself to admin:
--      update public.profiles set role = 'admin'
--      where id = (select id from auth.users where email = 'YOUR_EMAIL_HERE');
-- ============================================================================
