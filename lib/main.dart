import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PrefsService.create();
  runApp(CitiGuideApp(prefs: prefs));
}
