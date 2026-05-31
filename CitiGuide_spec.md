# CitiGuide — LLM Execution Spec

## 1. Project Summary

CitiGuide is a simple city-guide mobile app that helps residents and tourists discover attractions, restaurants, hotels, and events in a selected city. Users can browse places, view details, search/filter listings, see map locations, get directions, save favourites, and leave reviews/ratings.

The project should be kept simple by using a Backend-as-a-Service instead of building a custom backend.

## 2. North Star

Build a clean, functional mobile city-guide app where a user can:

1. Sign up or log in.
2. Select a city.
3. Browse places/events in that city.
4. Search and filter listings.
5. View details, images, map location, reviews, and ratings.
6. Save favourites.
7. Add a review/rating.
8. Allow an admin to manage cities, listings, events, and reviews.

Success means the app feels useful within the first 60 seconds of opening it.

## 3. Recommended Tech Stack

### Mobile App
- Flutter
- Dart
- Riverpod or Provider for state management
- GoRouter for navigation
- Google Maps Flutter or Mapbox Maps Flutter
- Supabase Flutter SDK

### Backend-as-a-Service
Use Supabase.

Reasons:
- Authentication is built in.
- PostgreSQL database is included.
- Storage is available for images.
- Row Level Security can protect user/admin data.
- Easy dashboard for managing records.
- Better fit than Firebase if relational data matters.

### Admin Dashboard
Use Supabase Studio for MVP admin management.

Optional upgrade:
- Build a simple web admin panel later using Next.js + Supabase.

### External Services
- Google Maps API or Mapbox
- Unsplash/Pexels only for placeholder images during development

## 4. MVP Features

### 4.1 Authentication
Users should be able to:
- Create an account.
- Log in.
- Log out.
- Reset password.
- Update profile.

Use Supabase Auth.

### 4.2 City Selection
Users should be able to:
- View available cities.
- Select a city.
- See city name, description, and image.

### 4.3 Listings
The app should show listings for:
- Attractions
- Restaurants
- Hotels
- Events

Each listing should include:
- Name
- Category
- Image
- Short description
- Rating
- Contact information
- Opening hours
- City
- Location coordinates

### 4.4 Listing Details
Users should be able to view:
- Full description
- Multiple images
- Address
- Map location
- Website link
- Contact details
- Opening hours
- Reviews
- Average rating

### 4.5 Search and Filters
Users should be able to:
- Search by name or keyword.
- Filter by category.
- Filter by rating.
- Sort by highest rated or newest.

### 4.6 Maps and Directions
Users should be able to:
- See a map marker for a listing.
- Open directions from their current location using Google Maps or Apple Maps.

For MVP, use external map apps for directions instead of building custom turn-by-turn navigation.

### 4.7 Reviews and Ratings
Authenticated users should be able to:
- Add a review.
- Add a star rating.
- Like helpful reviews.

Rules:
- One review per user per listing.
- Rating must be between 1 and 5.
- Reviews should show user name, comment, rating, and date.

### 4.8 Favourites
Authenticated users should be able to:
- Save listings as favourites.
- Remove listings from favourites.
- View saved favourites from profile.

### 4.9 User Profile
Users should be able to:
- View profile.
- Edit name.
- Upload/change profile picture.
- Manage favourite listings.
- Manage notification preference toggle.

### 4.10 Admin Management
For MVP, use Supabase Studio to:
- Add/edit/delete cities.
- Add/edit/delete listings.
- Add/edit/delete events.
- Review/delete inappropriate reviews.
- Upload images to Supabase Storage.

## 5. Non-Functional Requirements

- App interactions should feel fast, ideally within 1–2 seconds.
- UI should be mobile-first, clean, and beginner-friendly.
- Use clear fonts, readable spacing, and accessible contrast.
- Use graceful loading, empty, and error states.
- Protect private user data with Supabase Row Level Security.
- Keep the app simple enough to demo easily.
- Include user documentation, developer documentation, and a short demo video.

## 6. Database Schema

### profiles
Stores extra user profile data linked to Supabase Auth.

Fields:
- id uuid primary key references auth.users(id)
- full_name text
- avatar_url text nullable
- phone text nullable
- notification_enabled boolean default true
- role text default 'user'
- created_at timestamptz default now()
- updated_at timestamptz default now()

Allowed roles:
- user
- admin

### cities
Stores available cities.

Fields:
- id uuid primary key default gen_random_uuid()
- name text not null
- slug text unique not null
- description text
- image_url text
- country text
- is_active boolean default true
- created_at timestamptz default now()

### categories
Stores listing categories.

Fields:
- id uuid primary key default gen_random_uuid()
- name text not null
- slug text unique not null
- icon text nullable
- created_at timestamptz default now()

Seed categories:
- Attractions
- Restaurants
- Hotels
- Events

### listings
Stores attractions, restaurants, hotels, and events.

Fields:
- id uuid primary key default gen_random_uuid()
- city_id uuid references cities(id)
- category_id uuid references categories(id)
- name text not null
- slug text not null
- short_description text
- description text
- cover_image_url text
- website_url text nullable
- phone text nullable
- email text nullable
- address text
- latitude double precision
- longitude double precision
- opening_hours text nullable
- rating_average numeric default 0
- rating_count integer default 0
- is_featured boolean default false
- is_active boolean default true
- created_at timestamptz default now()
- updated_at timestamptz default now()

### listing_images
Stores extra listing images.

Fields:
- id uuid primary key default gen_random_uuid()
- listing_id uuid references listings(id) on delete cascade
- image_url text not null
- sort_order integer default 0
- created_at timestamptz default now()

### reviews
Stores listing reviews.

Fields:
- id uuid primary key default gen_random_uuid()
- listing_id uuid references listings(id) on delete cascade
- user_id uuid references auth.users(id)
- rating integer not null
- comment text
- created_at timestamptz default now()
- updated_at timestamptz default now()

Constraint:
- unique(listing_id, user_id)
- rating >= 1 and rating <= 5

### review_likes
Stores helpful review likes.

Fields:
- id uuid primary key default gen_random_uuid()
- review_id uuid references reviews(id) on delete cascade
- user_id uuid references auth.users(id)
- created_at timestamptz default now()

Constraint:
- unique(review_id, user_id)

### favourites
Stores saved listings.

Fields:
- id uuid primary key default gen_random_uuid()
- listing_id uuid references listings(id) on delete cascade
- user_id uuid references auth.users(id)
- created_at timestamptz default now()

Constraint:
- unique(listing_id, user_id)

## 7. Supabase Setup Tasks

1. Create a Supabase project.
2. Enable Email/Password auth.
3. Create database tables.
4. Enable Row Level Security on all tables.
5. Create policies:
   - Public can read active cities, categories, and listings.
   - Authenticated users can read and update only their own profile.
   - Authenticated users can create/update/delete their own reviews.
   - Authenticated users can create/delete their own favourites.
   - Admin users can manage cities, categories, listings, listing images, and reviews.
6. Create storage bucket:
   - `city-guide-images`
7. Add sample seed data:
   - 2 cities
   - 4 categories
   - 20 listings
   - Several images
   - Several demo reviews

## 8. Suggested Flutter Folder Structure

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
  core/
    constants/
    utils/
    widgets/
    services/
      supabase_service.dart
      location_service.dart
      map_launcher_service.dart
  features/
    auth/
      screens/
      widgets/
      providers/
    cities/
      screens/
      widgets/
      providers/
      models/
    listings/
      screens/
      widgets/
      providers/
      models/
    reviews/
      widgets/
      providers/
      models/
    favourites/
      screens/
      providers/
    profile/
      screens/
      providers/
```

## 9. Main App Screens

### Auth Screens
- Splash screen
- Login screen
- Signup screen
- Forgot password screen

### Main Screens
- City selection screen
- Home/listings screen
- Search screen
- Listing details screen
- Map preview screen
- Favourites screen
- Profile screen
- Edit profile screen

## 10. Navigation Flow

```text
Splash
  -> if logged in: City Selection or Home
  -> if not logged in: Login

Login
  -> Signup
  -> Forgot Password
  -> City Selection

City Selection
  -> Home

Home
  -> Listing Details
  -> Search
  -> Favourites
  -> Profile

Listing Details
  -> Map/Directions
  -> Reviews
```

## 11. UI Direction

Use a clean travel/discovery style.

Recommended visual direction:
- White or very light background
- Blue/teal primary color
- Card-based listings
- Rounded image cards
- Large city header image
- Category chips
- Star rating badges
- Clear CTA buttons
- Bottom navigation for Home, Search, Favourites, Profile

## 12. LLM Agent Execution Plan

### Phase 1: Project Setup
- Create Flutter project.
- Install required packages:
  - supabase_flutter
  - flutter_riverpod or provider
  - go_router
  - google_maps_flutter or mapbox_maps_flutter
  - geolocator
  - url_launcher
  - image_picker
  - cached_network_image
  - intl
- Configure app theme and routing.
- Connect Supabase.

### Phase 2: Supabase Backend
- Create tables.
- Add RLS policies.
- Create storage bucket.
- Insert seed data.
- Test auth, reads, reviews, and favourites from Supabase dashboard.

### Phase 3: Authentication
- Build signup.
- Build login.
- Build logout.
- Build password reset.
- Automatically create a profile record after signup.

### Phase 4: Cities
- Fetch active cities.
- Build city selection screen.
- Store selected city locally.
- Route user to home after selection.

### Phase 5: Listings
- Fetch listings by selected city.
- Show category filters.
- Show listing cards.
- Build listing details page.
- Display images, contact info, opening hours, website, and map preview.

### Phase 6: Search and Filters
- Add search input.
- Query listings by keyword.
- Filter by category.
- Sort by rating/newest.

### Phase 7: Reviews
- Display listing reviews.
- Add review form.
- Allow review likes.
- Recalculate average rating after review changes.

### Phase 8: Favourites
- Add favourite/unfavourite button.
- Build favourites screen.
- Show saved listings.

### Phase 9: Profile
- Build profile screen.
- Allow name update.
- Allow avatar upload.
- Add notification preference toggle.

### Phase 10: Polish
- Add loading states.
- Add empty states.
- Add error states.
- Improve UI spacing and responsiveness.
- Add basic documentation.
- Record demo video.

## 13. Acceptance Criteria

The project is complete when:

- User can sign up and log in.
- User can select a city.
- User can view listings for that city.
- User can filter/search listings.
- User can open listing details.
- User can see map location.
- User can open directions in map app.
- User can add a review/rating.
- User can like a review.
- User can save/remove favourites.
- User can edit profile.
- Admin can manage content through Supabase Studio.
- App has proper loading/error/empty states.
- Demo video shows the full working app.

## 14. Scope Control

Do not build these in MVP:
- Custom backend API.
- Complex admin dashboard.
- In-app chat.
- In-app booking.
- Payment system.
- Push notifications.
- AI recommendations.
- Offline sync.
- Turn-by-turn navigation.

These can be added after the MVP works.

## 15. Recommended Build Order

1. Supabase setup and seed data.
2. Flutter project setup.
3. Auth screens.
4. City selection.
5. Listings list.
6. Listing details.
7. Search/filter.
8. Reviews.
9. Favourites.
10. Profile.
11. Polish and documentation.
