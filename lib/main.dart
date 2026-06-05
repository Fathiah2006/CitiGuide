import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/prefs_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Connects to Supabase when configured; otherwise the app runs offline
  // against the bundled seed data.
  await SupabaseService.initialize();
  final prefs = await PrefsService.create();
  runApp(CitiGuideApp(prefs: prefs));
}
