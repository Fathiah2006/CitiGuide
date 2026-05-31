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
  final _name = TextEditingController(text: 'Amara Okonkwo');
  final _email = TextEditingController(text: 'amara.okonkwo@gmail.com');
  final _password = TextEditingController(text: 'citiguide');
  bool _agree = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _create() {
    if (!_agree) return;
    context.read<AppState>().signup(_name.text.trim(), _email.text.trim());
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.city, (_) => false);
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
                  hint: 'Amara Okonkwo',
                  controller: _name),
              const SizedBox(height: 16),
              AppTextField(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  hint: 'you@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              AppPasswordField(
                  label: 'Create password',
                  hint: 'At least 8 characters',
                  controller: _password),
              const SizedBox(height: 4),
              GestureDetector(
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
                        border: _agree
                            ? null
                            : Border.all(color: AppColors.line, width: 1.5),
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
                          style: AppTheme.body(13,
                              color: AppColors.muted, height: 1.5),
                          children: [
                            TextSpan(
                                text: 'Terms',
                                style: AppTheme.body(13,
                                    weight: FontWeight.w700,
                                    color: AppColors.primary)),
                            const TextSpan(text: ' and '),
                            TextSpan(
                                text: 'Privacy Policy',
                                style: AppTheme.body(13,
                                    weight: FontWeight.w700,
                                    color: AppColors.primary)),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              CgButton(label: 'Create account', onPressed: _create, enabled: _agree),
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
}
