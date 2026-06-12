import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/validators.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/logReg/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (auth.status != AuthStatus.authenticated) {
      SnackbarHelper.show(context, auth.error ?? AppStrings.errorLogin, isError: true);
    }
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Lupa Password"),
        content: const Text("Fitur reset password akan segera tersedia. Silakan hubungi administrator sistem."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMobile = Responsive.isMobile(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)]),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context)),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isMobile ? 20 : 40),
                        IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => Navigator.pop(context)),
                        SizedBox(height: isMobile ? 20 : 32),
                        Container(
                          width: isMobile ? 64 : 80,
                          height: isMobile ? 64 : 80,
                          decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(isMobile ? 16 : 20), boxShadow: [
                            BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
                          ]),
                          child: Icon(Icons.calendar_today, color: Colors.white, size: isMobile ? 32 : 40),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        Text("Selamat Datang", style: TextStyle(fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Masuk ke sistem informasi pendidikan\ndan event akademik Universitas Bumigora.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        SizedBox(height: isMobile ? 40 : 48),
                        const Text("EMAIL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        _field(controller: _email, hint: "hello@yourmail.com", icon: Icons.email_outlined, validator: Validators.email),
                        const SizedBox(height: 20),
                        const Text("PASSWORD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        _field(
                          controller: _password,
                          hint: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: Validators.loginPassword,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPassword,
                            child: const Text("Lupa Password?", style: TextStyle(color: Colors.blue)),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: auth.status == AuthStatus.loading ? null : _submit,
                            child: auth.status == AuthStatus.loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Text(AppStrings.masuk, style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(child: Text("atau masuk dengan", style: TextStyle(color: Colors.grey))),
                        const SizedBox(height: 20),
                        _social("Lanjutkan dengan Google", "assets/images/Google.png", Icons.g_mobiledata),
                        const SizedBox(height: 12),
                        _social("Lanjutkan dengan Apple", "assets/images/apple.png", Icons.apple),
                        const SizedBox(height: 30),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Belum punya akun? "),
                              GestureDetector(
                                onTap: () => Navigator.push(context, RouteTransitions.slideFromRight(const RegisterScreen())),
                                child: const Text(AppStrings.daftar, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscure : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure = !_obscure))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _social(String label, String path, IconData fallback) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(path, width: 24, height: 24, errorBuilder: (_, _, _) => Icon(fallback, size: 24)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
