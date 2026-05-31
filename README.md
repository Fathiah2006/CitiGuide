# CitiGuide

A clean, travel-discovery mobile app that helps residents and tourists explore
attractions, restaurants, hotels and events across Nigerian cities. Browse
places, search and filter, view rich details with a map, save favourites and
leave reviews — built in Flutter from the **CitiGuide All Screens** design.

> Implements every screen in the design system with a deep-navy primary palette,
> Plus Jakarta Sans typography and the design's card-based, rounded-image style.

---

## ✨ Features

| Area | What you can do |
|------|-----------------|
| **Auth** | Splash → Login / Signup / Forgot-password (with sent state) |
| **City selection** | Pick from Benin City, Port Harcourt, Lagos & Abuja |
| **Home / Explore** | City hero, category chips, featured carousel, popular list |
| **Search** | Keyword search, category + min-rating filters, sort (rated / reviewed / A–Z) |
| **Listing details** | Gallery, quick actions, about, info rows, map preview, reviews |
| **Maps & directions** | Hands off to Google / Apple Maps via `url_launcher` |
| **Reviews & ratings** | View all reviews, "helpful" likes, write a review (1–5 stars) |
| **Favourites** | Save / remove places, dedicated Saved tab with empty state |
| **Profile** | Stats, notification toggle, edit profile, change city, log out |
| **States** | Loading-aware widgets, empty states, snackbar toasts |

Session, favourites, selected city, profile and the notification preference all
**persist across launches** via `shared_preferences`.

---

## 🚀 Getting started

```bash
flutter pub get
flutter run            # any connected device / emulator
```

Other targets:

```bash
flutter run -d chrome  # web
flutter test           # widget smoke tests
flutter analyze        # static analysis (clean)
```

Requires Flutter 3.32+ / Dart 3.8+.

---

## 🧱 Architecture

The project is intentionally modular. Each concern lives in its own folder:

```text
lib/
  main.dart                  # entry point — boots PrefsService, runs the app
  app/
    app.dart                 # root widget + Provider wiring
    router.dart              # onGenerateRoute table
    routes.dart              # route-name constants
    theme.dart               # ThemeData + text-style helpers (Plus Jakarta Sans)
  models/                    # City, Category, Listing, Review, Profile
  services/
    seed_data.dart           # in-memory dataset (stands in for Supabase)
    prefs_service.dart       # SharedPreferences persistence
    map_launcher_service.dart# external maps / call / website
  state/
    app_state.dart           # ChangeNotifier — auth, city, favourites, reviews
  utils/                     # colors, radii, shadows, icon mapping
  widgets/                   # reusable UI (CgPhoto, cards, chips, sheet, …)
  screens/
    auth/  city/  home/  search/  details/  reviews/  favourites/  profile/
    main_shell.dart          # bottom-nav IndexedStack for the 4 primary tabs
```

**State management:** `provider` (a single `AppState` `ChangeNotifier`, mirroring
the design's single state container).

**Imagery:** the design ships no photo assets — instead it renders deterministic
duotone placeholders (`CgPhoto`) with a contour texture and category glyph. That
is reproduced here with gradients + a `CustomPainter`, so the app needs **no
network images or API keys** to look complete.

**Navigation:** named routes through `AppRouter.onGenerateRoute`. The four main
tabs live in `MainShell` (an `IndexedStack`); detail/map/reviews/edit pages are
pushed on top.

---

## 🔌 Backend (Supabase) — current status & swap path

The spec calls for **Supabase** as the backend. To keep the app fully functional
offline (and free of credentials), data is currently served from
`services/seed_data.dart`, whose public API (`byCity`, `listingById`,
`reviewsFor`, …) deliberately mirrors what a `SupabaseService` would expose, and
all mutations go through `AppState`.

To move to Supabase later:

1. Add `supabase_flutter` and initialise it in `main.dart`.
2. Create a `SupabaseService` implementing the same read methods as `SeedData`.
3. Point `AppState` at it (auth, favourites, reviews become network calls).
4. Apply the schema and policies in [`docs/SUPABASE.md`](docs/SUPABASE.md).

No screen or widget needs to change — they depend on models and `AppState`, not
on the data source.

See **[`docs/USER_GUIDE.md`](docs/USER_GUIDE.md)** for the end-user walkthrough.
