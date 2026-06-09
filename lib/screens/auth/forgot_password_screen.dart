import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/buttons.dart';

enum _Step { email, code, password }

/// Password reset via a 6-digit email code:
///   enter email → enter code → set a new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _minLen = 6;

  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  _Step _step = _Step.email;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  AppState get _app => context.read<AppState>();

  void _toast(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _run(Future<void> Function() action, {String? onError}) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      _toast(onError ?? 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode({bool resend = false}) async {
    if (_email.text.trim().isEmpty) {
      _toast('Enter your email first.');
      return;
    }
    await _run(() async {
      await _app.sendResetCode(_email.text.trim());
      if (!mounted) return;
      setState(() => _step = _Step.code);
      if (resend) _toast('Code resent.');
    }, onError: 'Could not send the code. Check the email and try again.');
  }

  Future<void> _verify() async {
    if (_code.text.trim().length < 6) {
      _toast('Enter the 6-digit code.');
      return;
    }
    await _run(() async {
      await _app.verifyResetCode(_email.text.trim(), _code.text.trim());
      if (!mounted) return;
      setState(() => _step = _Step.password);
    }, onError: 'That code is invalid or expired.');
  }

  Future<void> _updatePassword() async {
    if (_password.text.length < _minLen) {
      _toast('Password must be at least $_minLen characters.');
      return;
    }
    if (_password.text != _confirm.text) {
      _toast('Passwords don’t match.');
      return;
    }
    await _run(() async {
      await _app.updatePassword(_password.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
      _toast('Password updated — please log in.');
    }, onError: 'Could not update the password. Try again.');
  }

  void _back() {
    switch (_step) {
      case _Step.email:
        Navigator.of(context).pop();
      case _Step.code:
        setState(() => _step = _Step.email);
      case _Step.password:
        setState(() => _step = _Step.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: _back),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: switch (_step) {
            _Step.email => _emailStep(),
            _Step.code => _codeStep(),
            _Step.password => _passwordStep(),
          },
        ),
      ),
    );
  }

  Widget _badge(IconData icon) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 28, color: AppColors.primary),
      );

  // ── step 1: email ──
  Widget _emailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge(Icons.lock_outline),
        const SizedBox(height: 24),
        Text('Reset password', style: AppTheme.display(28)),
        const SizedBox(height: 6),
        Text('Enter your email and we’ll send you a 6-digit code.',
            style: AppTheme.body(15, color: AppColors.muted, height: 1.5)),
        const SizedBox(height: 28),
        AppTextField(
          icon: Icons.mail_outline,
          label: 'Email',
          hint: 'you@email.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 22),
        CgButton(
            label: _busy ? 'Sending…' : 'Send code',
            enabled: !_busy,
            onPressed: _sendCode),
      ],
    );
  }

  // ── step 2: code ──
  Widget _codeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge(Icons.mark_email_read_outlined),
        const SizedBox(height: 24),
        Text('Enter code', style: AppTheme.display(28)),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: 'We sent a 6-digit code to ',
            style: AppTheme.body(15, color: AppColors.muted, height: 1.5),
            children: [
              TextSpan(
                  text: _email.text.trim(),
                  style: AppTheme.body(15,
                      weight: FontWeight.w700, color: AppColors.ink)),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _CodeField(controller: _code, onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        CgButton(
            label: _busy ? 'Verifying…' : 'Verify code',
            enabled: !_busy && _code.text.trim().length == 6,
            onPressed: _verify),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _busy ? null : () => _sendCode(resend: true),
            child: Text('Didn’t get it? Resend code',
                style: AppTheme.body(14,
                    weight: FontWeight.w700, color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  // ── step 3: new password ──
  Widget _passwordStep() {
    final pwOk = _password.text.length >= _minLen;
    final match = _confirm.text.isNotEmpty && _confirm.text == _password.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge(Icons.password_outlined),
        const SizedBox(height: 24),
        Text('New password', style: AppTheme.display(28)),
        const SizedBox(height: 6),
        Text('Choose a new password for your account.',
            style: AppTheme.body(15, color: AppColors.muted, height: 1.5)),
        const SizedBox(height: 28),
        AppPasswordField(
          label: 'New password',
          hint: 'At least $_minLen characters',
          controller: _password,
          onChanged: (_) => setState(() {}),
        ),
        if (_password.text.isNotEmpty && !pwOk)
          _hint('Password must be at least $_minLen characters.',
              AppColors.danger),
        const SizedBox(height: 16),
        AppPasswordField(
          label: 'Confirm new password',
          hint: 'Re-enter your password',
          controller: _confirm,
          onChanged: (_) => setState(() {}),
        ),
        if (_confirm.text.isNotEmpty)
          _hint(match ? 'Passwords match.' : 'Passwords don’t match.',
              match ? AppColors.success : AppColors.danger,
              match ? Icons.check_circle_outline : Icons.error_outline),
        const SizedBox(height: 24),
        CgButton(
            label: _busy ? 'Updating…' : 'Update password',
            enabled: !_busy && pwOk && match,
            onPressed: _updatePassword),
      ],
    );
  }

  Widget _hint(String text, Color color, [IconData? icon]) => Padding(
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

/// A single 6-digit code input, centred with wide letter-spacing.
class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _CodeField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        cursorColor: AppColors.primary,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTheme.title(26).copyWith(letterSpacing: 14),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: '------',
          hintStyle:
              AppTheme.title(26, color: AppColors.muted2).copyWith(letterSpacing: 14),
        ),
      ),
    );
  }
}
