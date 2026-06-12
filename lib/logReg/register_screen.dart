import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/validators.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
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
    _nama.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final hasData = _nama.text.isNotEmpty || _email.text.isNotEmpty || _password.text.isNotEmpty;
    if (!hasData) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmBatalkanPendaftaran),
        content: const Text(AppStrings.msgDataHilang),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.lanjutkanIsi)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.yaKembali, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.register(
      nama: _nama.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      passwordConfirmation: _passwordConfirmation.text,
    );
    if (!mounted) return;
    if (auth.status != AuthStatus.authenticated) {
      SnackbarHelper.show(context, auth.error ?? AppStrings.errorRegistrasi, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMobile = Responsive.isMobile(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: !(_nama.text.isNotEmpty || _email.text.isNotEmpty || _password.text.isNotEmpty),
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) Navigator.of(context).pop();
          }
        },
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
                          decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(isMobile ? 16 : 20), boxShadow: [
                            BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                          ]),
                          child: Icon(Icons.person_add, color: Colors.white, size: isMobile ? 32 : 40),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        Text("Daftar Akun", style: TextStyle(fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Daftar untuk mengakses informasi pendidikan\ndan event akademik Universitas Bumigora.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        SizedBox(height: isMobile ? 40 : 48),
                        const Text("NAMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        _field(controller: _nama, hint: "Nama Lengkap", icon: Icons.person_outline, validator: (v) => Validators.required(v, 'Nama')),
                        const SizedBox(height: 20),
                        const Text("EMAIL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        _field(controller: _email, hint: "hello@yourmail.com", icon: Icons.email_outlined, validator: Validators.email),
                        const SizedBox(height: 20),
                        const Text("PASSWORD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                          _field(
                            controller: _password,
                            hint: "Min. 8 karakter, huruf besar/kecil, angka, simbol",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isConfirm: false,
                            validator: Validators.password,
                          ),
                        const SizedBox(height: 20),
                        const Text("KONFIRMASI PASSWORD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        _field(
                          controller: _passwordConfirmation,
                          hint: "Ulangi password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isConfirm: true,
                          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.valKonfirmasiKosong;
            if (v != _password.text) return AppStrings.valPasswordTidakCocok;
                            return null;
                          },
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: auth.status == AuthStatus.loading ? null : _submit,
                            child: auth.status == AuthStatus.loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Text(AppStrings.daftar, style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun? "),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(AppStrings.masuk, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _field({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool isConfirm = false, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? (isConfirm ? _obscureConfirm : _obscure) : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon((isConfirm ? _obscureConfirm : _obscure) ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: () => setState(() {
                    if (isConfirm) {
                      _obscureConfirm = !_obscureConfirm;
                    } else {
                      _obscure = !_obscure;
                    }
                  }),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
