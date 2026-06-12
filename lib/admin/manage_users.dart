import 'package:flutter/material.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/models/user_model.dart';
import 'package:aplikasi_kampus/services/user_service.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';

class ManageUsersScreen extends StatefulWidget {
  final UserService userService;
  const ManageUsersScreen({super.key, required this.userService});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> _users = [];
  List<UserModel> get _filtered {
    var result = _users;
    if (_roleFilter != null) {
      result = result.where((u) => u.role == _roleFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((u) => u.nama.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  String? _roleFilter;
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';

  static const _perPage = 20;
  static const _roles = <String?>[null, 'admin', 'dosen', 'mahasiswa'];
  static const _roleLabels = [AppStrings.labelSemua, AppStrings.labelAdmin, AppStrings.labelDosen, AppStrings.labelMahasiswa];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; _currentPage = 1; _hasMore = true; _users = []; });
    try {
      final result = await widget.userService.getUsersPage(page: _currentPage, perPage: _perPage);
      _users = result.items;
      _hasMore = result.hasMore;
      _currentPage = result.currentPage;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await widget.userService.getUsersPage(page: _currentPage + 1, perPage: _perPage);
      _users.addAll(result.items);
      _hasMore = result.hasMore;
      _currentPage = result.currentPage;
    } catch (_) {}
    if (mounted) setState(() => _isLoadingMore = false);
  }

  Future<bool> _delete(UserModel user) async {
    try {
      await widget.userService.deleteUser(user.id);
      if (mounted) {
        setState(() => _users.removeWhere((u) => u.id == user.id));
        SnackbarHelper.show(context, "${user.nama} berhasil dihapus");
      }
      return true;
    } catch (e) {
      if (mounted) SnackbarHelper.show(context, "Gagal: $e", isError: true);
      return false;
    }
  }

  Future<void> _editRole(UserModel user) async {
    final roles = AppStrings.allRoles;
    final current = roles.indexOf(user.role);
    if (current == -1) return;

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          var selected = current;
          return SimpleDialog(
            title: Text("${AppStrings.confirmUbahRole}: ${user.nama}"),
            children: [
              RadioGroup<int>(
                groupValue: selected,
                onChanged: (v) {
                  if (v != null) setDialogState(() => selected = v);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(roles.length, (i) => RadioListTile<int>(
                    title: Text(roles[i]),
                    value: i,
                  )),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: const Text(AppStrings.simpan),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    if (result == null || result == current) return;
    try {
      await widget.userService.updateUser(user.id, role: roles[result]);
      if (mounted) {
        _users[_users.indexWhere((u) => u.id == user.id)] = UserModel(
          id: user.id, nama: user.nama, email: user.email, role: roles[result],
        );
        setState(() {});
        SnackbarHelper.show(context, "Role ${user.nama} diubah ke ${roles[result]}");
      }
    } catch (e) {
      if (mounted) SnackbarHelper.show(context, "Gagal: $e", isError: true);
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case AppStrings.roleAdmin: return Colors.red;
      case AppStrings.roleDosen: return Colors.blue;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.titleKelolaUser)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(Responsive.padding(context), 8, Responsive.padding(context), 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context)),
              children: List.generate(_roles.length, (i) {
                final isSelected = _roleFilter == _roles[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_roleLabels[i], style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setState(() => _roleFilter = _roles[i]),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const ShimmerLoading(itemCount: 5, itemHeight: 80, padding: EdgeInsets.all(16))
                : _error != null
                    ? ErrorDisplayWidget(message: _error!, onRetry: _load)
                    : displayed.isEmpty
                        ? const EmptyStateWidget(icon: Icons.people_outline, title: AppStrings.emptyUser)
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: Responsive.screenPadding(context),
                              itemCount: displayed.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (i == displayed.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }
                                final u = displayed[i];
                                return AnimatedListItem(
                                  index: i,
                                  child: Dismissible(
                                  key: ValueKey('user_${u.id}'),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Text(AppStrings.confirmHapusUser),
                                        content: Text("Yakin ingin menghapus ${u.nama}?"),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true) return false;
                                    return _delete(u);
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)),
                                    child: const Icon(Icons.delete_outline, color: Colors.red),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: _roleColor(u.role).withValues(alpha: 0.1),
                                          child: Text(
                                            u.nama.isNotEmpty ? u.nama[0].toUpperCase() : '?',
                                            style: TextStyle(color: _roleColor(u.role), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(u.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text(u.email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _roleColor(u.role).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(u.role.toUpperCase(), style: TextStyle(color: _roleColor(u.role), fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.lock_outline, size: 20, color: Colors.blueGrey),
                                          onPressed: () => _editRole(u),
                                          tooltip: AppStrings.confirmUbahRole,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
        heroTag: 'add_user',
        onPressed: () async {
          final namaCtrl = TextEditingController();
          final emailCtrl = TextEditingController();
          final passCtrl = TextEditingController();
          String selectedRole = 'mahasiswa';
          await showDialog<bool>(
            context: context,
            builder: (ctx) {
              var isSubmitting = false;
              return StatefulBuilder(
                builder: (ctx, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text(AppStrings.confirmTambahUser),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                          items: AppStrings.allRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (v) { if (v != null) setDialogState(() => selectedRole = v); },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSubmitting ? null : () => Navigator.pop(ctx, false),
                      child: const Text(AppStrings.batal),
                    ),
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (namaCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
                                SnackbarHelper.show(ctx, AppStrings.msgSemuaFieldWajib, isError: true);
                                return;
                              }
                              setDialogState(() => isSubmitting = true);
                              try {
                                await widget.userService.createUser(nama: namaCtrl.text.trim(), email: emailCtrl.text.trim(), password: passCtrl.text.trim(), role: selectedRole);
                                if (ctx.mounted) Navigator.pop(ctx, true);
                                if (mounted) SnackbarHelper.show(context, AppStrings.successUserDitambahkan);
                                await _load();
                              } catch (e) {
                                if (ctx.mounted) setDialogState(() => isSubmitting = false);
                                if (mounted) SnackbarHelper.show(context, AppStrings.errorGagalUser, isError: true);
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(AppStrings.simpan),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
