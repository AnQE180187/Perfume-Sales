import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

import '../providers/auth_provider.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseProvideCredentials)),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).login(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.accessDenied}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getLuxuryGradient(brightness)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Minimal Branding
                  Text(
                    l10n.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 12,
                      fontSize: 40,
                      color: AppTheme.champagneGold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.atelierDeParfum,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 4,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Auth Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.welcomeBack,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    hint: l10n.emailAddress,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hint: l10n.password,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    showPassword: _showPassword,
                    onTogglePassword: () => setState(() => _showPassword = !_showPassword),
                  ),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.forgotPassword,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDb),
                            )
                          : Text(l10n.login),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Suggestion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          l10n.createAccount,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Social Logins
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l10n.or, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10)),
                      ),
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5)),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      _buildSocialButton(
                        l10n.google, 
                        FontAwesomeIcons.google,
                        const Color(0xFFDB4437), // Google Red
                        () => ref.read(authControllerProvider.notifier).signInWithGoogle()
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        l10n.facebook, 
                        FontAwesomeIcons.facebookF,
                        const Color(0xFF1877F2), // Facebook Blue
                        () => ref.read(authControllerProvider.notifier).signInWithFacebook()
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      style: GoogleFonts.montserrat(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.champagneGold.withValues(alpha: 0.5), size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.mutedSilver,
                  size: 18,
                ),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color iconColor, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 14, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 10, 
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

