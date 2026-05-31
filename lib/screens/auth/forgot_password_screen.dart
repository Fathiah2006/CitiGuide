import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/buttons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController(text: 'amara.okonkwo@gmail.com');
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _sent ? _buildSent() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.lock_outline, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('Reset password', style: AppTheme.display(28)),
          const SizedBox(height: 6),
          Text(
              'Enter your email and we’ll send you a link to reset your password.',
              style: AppTheme.body(15, color: AppColors.muted, height: 1.5)),
          const SizedBox(height: 28),
          AppTextField(
              icon: Icons.mail_outline,
              label: 'Email',
              hint: 'you@email.com',
              controller: _email,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 22),
          CgButton(
              label: 'Send reset link',
              onPressed: () => setState(() => _sent = true)),
        ],
      ),
    );
  }

  Widget _buildSent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.mail_outline, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text('Check your inbox', style: AppTheme.display(26)),
          const SizedBox(height: 8),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'We’ve sent a password-reset link to ',
              style: AppTheme.body(15, color: AppColors.muted, height: 1.55),
              children: [
                TextSpan(
                    text: _email.text,
                    style: AppTheme.body(15,
                        weight: FontWeight.w700, color: AppColors.ink)),
                const TextSpan(text: '. It expires in 30 minutes.'),
              ],
            ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: CgButton(
              label: 'Back to log in',
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.login, (_) => false),
            ),
          ),
          const SizedBox(height: 14),
          Text('Didn’t get it? Resend',
              style: AppTheme.body(14,
                  weight: FontWeight.w600, color: AppColors.muted)),
        ],
      ),
    );
  }
}
