# CitiGuide — Supabase schema reference

This is the backend the app is designed to plug into (per the project spec). The
app currently runs on the in-memory `SeedData` mirror; use this when promoting to
a real Supabase project.

## Tables

```sql
-- profiles (extends auth.users)
create table profiles (
  id uuid primary key references auth.users(id),
  full_name text,
  avatar_url text,
  phone text,
  notification_enabled boolean default true,
  role text default 'user',                 -- 'user' | 'admin'
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table cities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text,
  image_url text,
  country text,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  icon text,
  created_at timestamptz default now()
);

create table listings (
  id uuid primary key default gen_random_uuid(),
  city_id uuid references cities(id),
  category_id uuid references categories(id),
  name text not null,
  slug text not null,
  short_description text,
  description text,
  cover_image_url text,
  website_url text,
  phone text,
  email text,
  address text,
  latitude double precision,
  longitude double precision,
  opening_hours text,
  rating_average numeric default 0,
  rating_count integer default 0,
  is_featured boolean default false,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table listing_images (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references listings(id) on delete cascade,
  image_url text not null,
  sort_order integer default 0,
  created_at timestamptz default now()
);

create table reviews (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references listings(id) on delete cascade,
  user_id uuid references auth.users(id),
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (listing_id, user_id)
);

create table review_likes (
  id uuid primary key default gen_random_uuid(),
  review_id uuid references reviews(id) on delete cascade,
  user_id uuid references auth.users(id),
  created_at timestamptz default now(),
  unique (review_id, user_id)
);

create table favourites (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references listings(id) on delete cascade,
  user_id uuid references auth.users(id),
  created_at timestamptz default now(),
  unique (listing_id, user_id)
);
```

## Row Level Security (summary)

- Public: read active `cities`, `categories`, `listings`, `listing_images`.
- Authenticated: read/update **own** `profile`; CRUD **own** `reviews`,
  `review_likes`, `favourites`.
- Admin (`profiles.role = 'admin'`): manage all content.

## Setup checklist

1. Create the Supabase project; enable **Email/Password** auth.
2. Create the tables above; enable RLS on all of them and add the policies.
3. Create storage bucket `city-guide-images`.
4. Seed: 4 categories, the cities and listings (mirror `lib/services/seed_data.dart`).
5. Wire `supabase_flutter` in `main.dart` and a `SupabaseService` that mirrors
   the `SeedData` read API; swap `AppState`'s data source over.

Admin content management for the MVP is handled through **Supabase Studio**.
