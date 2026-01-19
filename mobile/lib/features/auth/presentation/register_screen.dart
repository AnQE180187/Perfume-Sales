import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _showPassword = false;

  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillFields)),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseAcceptTerms)),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone.isNotEmpty ? phone : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registrationSuccessful)),
        );
        context.pop();
      }
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
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),
              
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       // Minimal Branding
                      Text(
                        l10n.appName.toUpperCase(),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          letterSpacing: 12,
                          fontSize: 32,
                          color: AppTheme.champagneGold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.dnaScent.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 3,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.joinTheAtelier,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Fields
                      _buildTextField(controller: _fullNameController, hint: l10n.fullName, icon: Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _emailController, hint: l10n.emailAddress, icon: Icons.email_outlined),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        hint: l10n.password,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        showPassword: _showPassword,
                        onTogglePassword: () => setState(() => _showPassword = !_showPassword),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _phoneController, hint: l10n.phoneOptional, icon: Icons.phone_android_outlined),
                      const SizedBox(height: 30),

                      // Terms Checkbox
                      Theme(
                        data: ThemeData(unselectedWidgetColor: AppTheme.champagneGold.withValues(alpha: 0.3)),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor: AppTheme.champagneGold,
                                checkColor: AppTheme.primaryDb,
                                side: BorderSide(color: AppTheme.champagneGold.withValues(alpha: 0.5)),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                                child: Text(
                                  l10n.agreeToTerms,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleRegister,
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDb),
                                )
                              : Text(l10n.createAccount.toUpperCase()),
                        ),
                      ),

                      const SizedBox(height: 40),

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
                            const Color(0xFFDB4437),
                            () => ref.read(authControllerProvider.notifier).signInWithGoogle()
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            l10n.facebook, 
                            FontAwesomeIcons.facebookF,
                            const Color(0xFF1877F2),
                            () => ref.read(authControllerProvider.notifier).signInWithFacebook()
                          ),
                        ],
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
      style: GoogleFonts.montserrat(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
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
