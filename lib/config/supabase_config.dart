/// Supabase connection settings.
///
/// Paste your project's values below (Supabase dashboard →
/// Project Settings → API). The anon/public key is safe to ship in a client
/// app — Row-Level Security protects your data.
///
/// You can also override these at run/build time without editing the file:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// When left blank, the app runs fully offline against the bundled seed data.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lupckubetqghlhltjibb.supabase.co',
  );

  // anon / public key — safe to ship in a client app (RLS protects the data).
  // NOTE: never put the `sb_secret_...` service key here.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1cGNrdWJldHFnaGxobHRqaWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NjUyNDAsImV4cCI6MjA5NjI0MTI0MH0.s7QGuO_w306t94K4vvFgga8w2KqrqrWYnHKKswFLsc4',
  );

  /// True when both values are present, enabling the live backend.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
