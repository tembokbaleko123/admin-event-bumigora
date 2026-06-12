import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/providers/informasi_provider.dart';
import 'package:aplikasi_kampus/func/informasi_detail.dart';
import 'package:aplikasi_kampus/models/informasi_model.dart';

class ManageInformasiScreen extends StatefulWidget {
  const ManageInformasiScreen({super.key});

  @override
  State<ManageInformasiScreen> createState() => _ManageInformasiScreenState();
}

class _ManageInformasiScreenState extends State<ManageInformasiScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InformasiProvider>().loadInformasi();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<InformasiProvider>().loadMoreInformasi();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _showForm({InformasiModel? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _InformasiForm(existing: existing),
    );
    if (mounted) context.read<InformasiProvider>().loadInformasi();
  }

  Future<void> _confirmDelete(InformasiModel info) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmHapusInformasi),
        content: Text('${AppStrings.msgYakinHapus} informasi "${info.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final prov = context.read<InformasiProvider>();
      final ok = await prov.deleteInformasi(info.id);
      if (mounted) {
        SnackbarHelper.show(context, ok ? AppStrings.successInformasiDihapus : (prov.error ?? AppStrings.errorGagalHapus));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InformasiProvider>();
    final list = prov.informasiList.where((i) =>
        _searchQuery.isEmpty || i.judul.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.titleKelolaInfo)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(Responsive.padding(context), 8, Responsive.padding(context), 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari informasi...',
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
          Expanded(
            child: prov.isLoading
                ? const ShimmerLoading(itemCount: 4, itemHeight: 100)
                : prov.error != null
                    ? ErrorDisplayWidget(message: prov.error!, onRetry: () => prov.loadInformasi())
                    : list.isEmpty
                        ? const EmptyStateWidget(icon: Icons.article_outlined, title: AppStrings.emptyInformasi)
                        : RefreshIndicator(
                            onRefresh: () => prov.loadInformasi(),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: Responsive.screenPadding(context),
                              itemCount: list.length + (prov.isLoadingMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (i == list.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }
                                final info = list[i];
                                return AnimatedListItem(
                                  index: i,
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
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.article, color: Colors.blue, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(info.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 4),
                                            Text(info.tanggal, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                        onPressed: () => _showForm(existing: info),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.blue),
                                        onPressed: () => Navigator.push(context, RouteTransitions.slideFromRight(InformasiDetailScreen(informasiId: info.id))).then((_) {
                                          if (mounted) context.read<InformasiProvider>().loadInformasi();
                                        }),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                        onPressed: () => _confirmDelete(info),
                                      ),
                                    ],
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
        heroTag: 'add_info',
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InformasiForm extends StatefulWidget {
  final InformasiModel? existing;
  const _InformasiForm({this.existing});

  @override
  State<_InformasiForm> createState() => _InformasiFormState();
}

class _InformasiFormState extends State<_InformasiForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late DateTime _tanggal;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.existing?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.existing?.isi ?? '');
    _tanggal = widget.existing != null
        ? (DateTime.tryParse(widget.existing!.tanggal) ?? DateTime.now())
        : DateTime.now();
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final prov = context.read<InformasiProvider>();
    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    bool ok;
    if (widget.existing == null) {
      ok = await prov.createInformasi(
        judul: _judulCtrl.text.trim(),
        isi: _isiCtrl.text.trim(),
        tanggal: fmt.format(_tanggal),
      );
    } else {
      ok = await prov.updateInformasi(
        id: widget.existing!.id,
        judul: _judulCtrl.text.trim(),
        isi: _isiCtrl.text.trim(),
        tanggal: fmt.format(_tanggal),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      SnackbarHelper.show(context, widget.existing == null ? AppStrings.successInformasiDibuat : AppStrings.successInformasiDiupdate);
      Navigator.pop(context);
    } else {
      SnackbarHelper.show(context, prov.error ?? AppStrings.errorGagalSimpan, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) Navigator.pop(context);
      },
      child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existing == null ? 'Buat Informasi' : 'Edit Informasi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.labelJudul, style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _judulCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Judul informasi'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.valJudulWajib : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(AppStrings.labelTanggal, style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (date != null && mounted) setState(() => _tanggal = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text('${_tanggal.day}/${_tanggal.month}/${_tanggal.year}'),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('ISI', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _isiCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Isi informasi'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.valIsiWajib : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text(AppStrings.simpan),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
