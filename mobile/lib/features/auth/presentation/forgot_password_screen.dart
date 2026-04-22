import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;
  String? _devToken;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearError);
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _emailController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Vui lòng nhập địa chỉ email của bạn');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
          _devToken = result['resetToken'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('not found') || errStr.contains('404')) {
            _error = 'Email này chưa được đăng ký trong hệ thống.';
          } else {
            _error = 'Không thể gửi yêu cầu. Vui lòng kiểm tra lại kết nối.';
          }
        });
      }
    }
  }

  Widget _buildErrorBanner() {
    if (_error == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D0A0A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: GoogleFonts.montserrat(
                color: const Color(0xFFFFD1D1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D5B7).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 40,
              color: Color(0xFFD4AF37),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Quên mật khẩu?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập email đã đăng ký, chúng tôi sẽ gửi link đặt lại mật khẩu.',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF999999),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _buildErrorBanner(),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: 'Địa chỉ email',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFCCCCCC),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.mail_outline,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFE8D5B7), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFE8D5B7), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: Color(0xFFD4AF37),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8D5B7),
              foregroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A1A1A),
                    ),
                  )
                : Text(
                    'Gửi link đặt lại',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 50,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Kiểm tra email!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Chúng tôi đã gửi link đặt lại mật khẩu đến\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF999999),
            height: 1.5,
          ),
        ),
        if (_devToken != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'DEBUG TOKEN (Development Mode)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _devToken!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Vui lòng nhấn vào liên kết trong email để mở trình duyệt và tiến hành đặt lại mật khẩu của bạn.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF666666),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8D5B7),
              foregroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => context.pop(),
            child: Text(
              'Quay lại đăng nhập',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
