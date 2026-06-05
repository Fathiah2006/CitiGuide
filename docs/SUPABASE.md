# CitiGuide × Supabase — setup & operations

The app talks to Supabase through `lib/services/supabase_service.dart`. When no
credentials are configured it transparently falls back to the bundled seed data,
so the app always runs.

## 1. Connect the app to your project

Get your **Project URL** and **anon / public** key from
Supabase → Project Settings → **API**, then either:

**Option A — edit the config file** (`lib/config/supabase_config.dart`):

```dart
static const String url     = 'https://YOUR-REF.supabase.co';
static const String anonKey = 'eyJ...your anon public key...';
```

**Option B — pass at run/build time** (keeps keys out of source):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

The anon key is safe in a client app — Row-Level Security guards the data.

## 2. Create the schema + seed data

Open the Supabase **SQL Editor**, paste the entire contents of
[`supabase/migrations/0001_init.sql`](../supabase/migrations/0001_init.sql) and
**Run**. This creates all tables, RLS policies, triggers, the
`city-guide-images` storage bucket, and seeds 4 categories, 4 cities, 23
listings and a few demo reviews. It is safe to re-run.

## 3. Disable email confirmation (for smooth sign-up)

Authentication → **Sign In / Providers → Email** → turn **off** "Confirm email".
New sign-ups then receive a session immediately.

## 4. Become an admin

Sign up once in the app, then run this in the SQL Editor (the in-app **Admin
dashboard** appears on your Profile after you re-open the app):

```sql
update public.profiles set role = 'admin'
where id = (select id from auth.users where email = 'YOUR_EMAIL_HERE');
```

## What the app uses

| Feature | Supabase mechanism |
|---------|--------------------|
| Sign up / in / out | `auth` (email + password) |
| Profile auto-created on signup | `handle_new_user` trigger → `profiles` |
| Cities / categories / listings | public `select` (RLS), hydrated at launch |
| Favourites | `favourites` table (per-user, RLS) |
| Reviews | `reviews` + `add_review()` RPC (blends rating) |
| Admin CRUD | `listings` / `cities` writes gated by `is_admin()` |
| Review moderation | admin `delete` on `reviews` |
| Images | `city-guide-images` Storage bucket (admin upload, public read) |

## Schema notes / deviations from the original spec

- `reviews.author_name` (denormalised) + nullable `user_id` — lets us seed demo
  reviews and display an author without granting read access to other users'
  profiles (which RLS forbids).
- `cities` gained `state`, `tagline`, `hue`, `sort_order`; `listings` gained
  `price`, `open_now`, `tags`, `hue` to match the app's design fields.
- `rating_average` / `rating_count` are curated baselines; `add_review()` blends
  new ratings in rather than resetting the count to the number of stored rows.

## Images

Listings and cities seed reliable, topical photo URLs (LoremFlickr) so the app
looks populated immediately. Admins can upload real photos via the listing/city
forms — they land in the `city-guide-images` bucket and replace the cover URL.
Any image that fails to load falls back to the deterministic placeholder, so the
UI never looks broken.
