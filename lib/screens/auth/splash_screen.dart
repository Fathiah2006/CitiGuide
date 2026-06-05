import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/logo.dart';

/// Branded splash that auto-advances to login / city / home depending on the
/// persisted session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bar =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..repeat();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Load catalogue + session while the splash animation plays, honouring a
    // minimum on-screen duration so the splash never just flashes.
    final app = context.read<AppState>();
    await Future.wait([
      app.bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);
    _advance();
  }

  void _advance() {
    if (!mounted) return;
    final app = context.read<AppState>();
    final String next;
    if (!app.isLoggedIn) {
      next = Routes.login;
    } else if (app.selectedCityId == null) {
      next = Routes.city;
    } else {
      next = Routes.main;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(next, (_) => false);
  }

  @override
  void dispose() {
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.1,
            colors: [AppColors.primary600, AppColors.primary, AppColors.primary700],
            stops: [0, 0.46, 1],
          ),
        ),
        child: Stack(
          children: [
            // warm guiding-light glow behind the mark
            const Align(
              alignment: Alignment(0, -0.4),
              child: _Glow(),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14)),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x80031E2D),
                            blurRadius: 60,
                            offset: Offset(0, 24)),
                      ],
                    ),
                    child: const Center(child: LogoMark(size: 76, light: true)),
                  ),
                  const SizedBox(height: 26),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'Citi',
                          style: AppTheme.display(40, color: Colors.white)),
                      TextSpan(
                          text: 'Guide',
                          style: AppTheme.display(40,
                              color: Colors.white.withValues(alpha: 0.5))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Text('Discover your city, like a local',
                      style: AppTheme.body(14.5,
                          color: Colors.white.withValues(alpha: 0.72))),
                ],
              ),
            ),
            // indeterminate loading bar
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      width: 120,
                      height: 3,
                      child: AnimatedBuilder(
                        animation: _bar,
                        builder: (context, _) {
                          return Stack(children: [
                            Container(
                                color: Colors.white.withValues(alpha: 0.16)),
                            Align(
                              alignment: Alignment(_bar.value * 2 - 1, 0),
                              child: FractionallySizedBox(
                                widthFactor: 0.42,
                                child: Container(
                                    decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(3),
                                )),
                              ),
                            ),
                          ]);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'FINDING PLACES NEAR YOU',
                    style: AppTheme.body(10.5,
                        weight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x57E8A23D), Color(0x00E8A23D)],
          stops: [0, 0.62],
        ),
      ),
    );
  }
}
