import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/core/utils/validators.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _currentPasswordCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _confirmPasswordCtrl;
  bool _isLoading = false;
  bool _showPasswordFields = false;
  late String _initialNama;
  late String _initialEmail;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _initialNama = user?.nama ?? '';
    _initialEmail = user?.email ?? '';
    _namaCtrl = TextEditingController(text: _initialNama);
    _emailCtrl = TextEditingController(text: _initialEmail);
    _currentPasswordCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
    _namaCtrl.addListener(_onFieldChanged);
    _emailCtrl.addListener(_onFieldChanged);
    _currentPasswordCtrl.addListener(_onFieldChanged);
    _passwordCtrl.addListener(_onFieldChanged);
    _confirmPasswordCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_isDirty) {
      final changed = _namaCtrl.text != _initialNama ||
          _emailCtrl.text != _initialEmail ||
          _currentPasswordCtrl.text.isNotEmpty ||
          _passwordCtrl.text.isNotEmpty ||
          _confirmPasswordCtrl.text.isNotEmpty;
      if (changed) setState(() => _isDirty = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty || _isLoading) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmBatalkanPerubahan),
        content: const Text(AppStrings.msgPerubahanBelumSimpan),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.lanjutkanEdit)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.yaBatalkan, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _namaCtrl.removeListener(_onFieldChanged);
    _emailCtrl.removeListener(_onFieldChanged);
    _currentPasswordCtrl.removeListener(_onFieldChanged);
    _passwordCtrl.removeListener(_onFieldChanged);
    _confirmPasswordCtrl.removeListener(_onFieldChanged);
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      nama: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      currentPassword: _showPasswordFields ? _currentPasswordCtrl.text : null,
      password: _showPasswordFields ? _passwordCtrl.text : null,
      passwordConfirmation: _showPasswordFields ? _confirmPasswordCtrl.text : null,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      SnackbarHelper.show(context, AppStrings.successProfilDiperbarui);
      Navigator.pop(context);
    } else {
      SnackbarHelper.show(context, auth.error ?? AppStrings.errorProfil, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return PopScope(
      canPop: !_isDirty || _isLoading,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        
      appBar: AppBar(title: const Text(AppStrings.titleEditProfil)),
      body: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF5B5FEF).withValues(alpha: 0.1),
                    child: Text(
                      ((auth.user?.nama ?? '').isNotEmpty ? (auth.user?.nama ?? '?')[0].toUpperCase() : '?'),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF5B5FEF)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF5B5FEF), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _label(AppStrings.labelNamaLengkap),
              const SizedBox(height: 8),
              _field(_namaCtrl, "Nama Lengkap", Icons.person_outline, (v) => Validators.required(v, 'Nama')),
              const SizedBox(height: 20),
              _label(AppStrings.labelEmail),
              const SizedBox(height: 8),
              _field(_emailCtrl, "Email", Icons.email_outlined, Validators.email),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.labelGantiPassword, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Aktifkan jika ingin memperbarui password akun"),
                value: _showPasswordFields,
                onChanged: (value) => setState(() => _showPasswordFields = value),
              ),
              if (_showPasswordFields) ...[
                const SizedBox(height: 12),
                _label(AppStrings.labelPasswordSaatIni),
                const SizedBox(height: 8),
                _field(
                  _currentPasswordCtrl,
                  "Password Saat Ini",
                  Icons.lock_outline,
                  (v) => Validators.required(v, 'Password saat ini'),
                  obscure: true,
                ),
                const SizedBox(height: 20),
                _label(AppStrings.labelPasswordBaru),
                const SizedBox(height: 8),
                _field(
                  _passwordCtrl,
                  "Minimal 8 karakter",
                  Icons.lock_reset,
                  (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return AppStrings.valPasswordWajib;
                    if (value.length < 8) return AppStrings.valPasswordMin8;
                    return null;
                  },
                  obscure: true,
                ),
                const SizedBox(height: 20),
                _label(AppStrings.labelKonfirmasiPassword),
                const SizedBox(height: 8),
                _field(
                  _confirmPasswordCtrl,
                  "Ulangi Password Baru",
                  Icons.lock_outline,
                  (v) => v == _passwordCtrl.text ? null : AppStrings.valKonfirmasiTidakSama,
                  obscure: true,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text(AppStrings.simpanPerubahan),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey));

  Widget _field(TextEditingController ctrl, String hint, IconData icon, String? Function(String?)? validator, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
