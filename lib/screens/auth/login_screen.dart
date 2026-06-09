import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _busy = false;

  Future<void> _login() async {
    if (_busy) return;
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Enter your email and password.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await context
          .read<AppState>()
          .login(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.city, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_friendly(e))));
    }
  }

  String _friendly(Object e) {
    final m = e.toString();
    if (m.contains('Invalid login')) return 'Wrong email or password.';
    return 'Could not log in. Check your details and connection.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Logo(size: 48),
              const SizedBox(height: 28),
              Text('Welcome back', style: AppTheme.display(30)),
              const SizedBox(height: 6),
              Text('Log in to pick up where you left off.',
                  style: AppTheme.body(15, color: AppColors.muted)),
              const SizedBox(height: 30),
              AppTextField(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  hint: 'you@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              AppPasswordField(controller: _password),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(Routes.forgot),
                  child: Text('Forgot password?',
                      style: AppTheme.body(13.5,
                          weight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 22),
              CgButton(
                  label: _busy ? 'Logging in…' : 'Log in',
                  enabled: !_busy,
                  onPressed: _login),
              const SizedBox(height: 22),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.line)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('OR',
                      style: AppTheme.body(12.5,
                          weight: FontWeight.w600, color: AppColors.muted2)),
                ),
                const Expanded(child: Divider(color: AppColors.line)),
              ]),
              const SizedBox(height: 22),
              CgButton(
                label: 'Continue with Google',
                variant: CgButtonVariant.outline,
                icon: Icons.g_mobiledata,
                onPressed: _login,
              ),
              const SizedBox(height: 26),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'New to CitiGuide? ',
                    style: AppTheme.body(14.5, color: AppColors.muted),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed(Routes.signup),
                          child: Text('Create account',
                              style: AppTheme.body(14.5,
                                  weight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
