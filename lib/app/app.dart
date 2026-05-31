import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/prefs_service.dart';
import '../state/app_state.dart';
import 'router.dart';
import 'routes.dart';
import 'theme.dart';

/// Root application widget — installs the [AppState] provider and the router.
class CitiGuideApp extends StatelessWidget {
  final PrefsService prefs;
  const CitiGuideApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(prefs),
      child: MaterialApp(
        title: 'CitiGuide',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
