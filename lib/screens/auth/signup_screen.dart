import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = true;
  bool _busy = false;

  static const _minLen = 6;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _passwordOk => _password.text.length >= _minLen;
  bool get _confirmOk => _confirm.text.isNotEmpty && _confirm.text == _password.text;
  bool get _formOk =>
      _name.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _passwordOk &&
      _confirmOk &&
      _agree;

  Future<void> _create() async {
    if (!_formOk || _busy) return;
    setState(() => _busy = true);
    try {
      await context
          .read<AppState>()
          .signup(_name.text.trim(), _email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.city, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      final m = e.toString();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(m.contains('already')
                ? 'That email is already registered.'
                : 'Could not create account. Try again.')));
    }
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
              Text('Create account', style: AppTheme.display(30)),
              const SizedBox(height: 6),
              Text('Save favourites and review the places you love.',
                  style: AppTheme.body(15, color: AppColors.muted)),
              const SizedBox(height: 30),
              AppTextField(
                icon: Icons.person_outline,
                label: 'Full name',
                hint: 'e.g. Amara Okonkwo',
                controller: _name,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppTextField(
                icon: Icons.mail_outline,
                label: 'Email',
                hint: 'you@email.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppPasswordField(
                label: 'Create password',
                hint: 'At least $_minLen characters',
                controller: _password,
                onChanged: (_) => setState(() {}),
              ),
              _passwordHint(),
              const SizedBox(height: 16),
              AppPasswordField(
                label: 'Confirm password',
                hint: 'Re-enter your password',
                controller: _confirm,
                onChanged: (_) => setState(() {}),
              ),
              _confirmHint(),
              const SizedBox(height: 18),
              _agreeRow(),
              const SizedBox(height: 22),
              CgButton(
                  label: _busy ? 'Creating…' : 'Create account',
                  onPressed: _create,
                  enabled: _formOk && !_busy),
              const SizedBox(height: 24),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: AppTheme.body(14.5, color: AppColors.muted),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text('Log in',
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

  Widget _passwordHint() {
    if (_password.text.isEmpty) {
      return _hint('Use at least $_minLen characters.', AppColors.muted);
    }
    if (!_passwordOk) {
      return _hint('Password must be at least $_minLen characters.',
          AppColors.danger, Icons.error_outline);
    }
    return _hint('Password length looks good.', AppColors.success, Icons.check_circle_outline);
  }

  Widget _confirmHint() {
    if (_confirm.text.isEmpty) return const SizedBox(height: 6);
    if (!_confirmOk) {
      return _hint('Passwords don’t match.', AppColors.danger, Icons.error_outline);
    }
    return _hint('Passwords match.', AppColors.success, Icons.check_circle_outline);
  }

  Widget _hint(String text, Color color, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(text, style: AppTheme.body(12.5, color: color)),
        ],
      ),
    );
  }

  Widget _agreeRow() {
    return GestureDetector(
      onTap: () => setState(() => _agree = !_agree),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agree ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border:
                  _agree ? null : Border.all(color: AppColors.line, width: 1.5),
            ),
            child: _agree
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: AppTheme.body(13, color: AppColors.muted, height: 1.5),
                children: [
                  TextSpan(
                      text: 'Terms',
                      style: AppTheme.body(13,
                          weight: FontWeight.w700, color: AppColors.primary)),
                  const TextSpan(text: ' and '),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: AppTheme.body(13,
                          weight: FontWeight.w700, color: AppColors.primary)),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
