import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_kampus/InApp/dashboard_screen.dart';
import 'package:aplikasi_kampus/func/events.dart';
import 'package:aplikasi_kampus/func/profile.dart';
import 'package:aplikasi_kampus/func/lecturer_analytics_screen.dart';
import 'package:aplikasi_kampus/providers/notifikasi_provider.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  bool _isInitialized = false;

  final _pages = [
    const DashboardScreen(),
    const BookingListScreen(),
    const LecturerAnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _loadData();
      }
    });
  }

  void _loadData() {
    if (!mounted) return;
    try {
      context.read<NotifikasiProvider>().load();
      context.read<EventProvider>().loadEvents();
    } catch (e) {
      debugPrint('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
 onPressed: () => _showCreateEventModal(context),
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: context.surfaceColor, boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home, AppStrings.labelBeranda),
                _navItem(1, Icons.calendar_today_outlined, Icons.calendar_today, AppStrings.labelEvent),
                _navItem(2, Icons.analytics_outlined, Icons.analytics, AppStrings.labelAnalytics),
                _navItem(3, Icons.person_outline, Icons.person, AppStrings.titleProfil),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, IconData activeIcon, String label) {
    final active = _index == i;
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 16 : 24, vertical: 8),
        decoration: BoxDecoration(color: active ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: active ? AppColors.primary : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: active ? AppColors.primary : Colors.grey, fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

void _showCreateEventModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateEventModal(),
  );
}

class _CreateEventModal extends StatefulWidget {
  @override
  State<_CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends State<_CreateEventModal> {
  final _titleCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _kategori = AppStrings.catSeminar;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  DateTime? _selectedDateSelesai;
  TimeOfDay? _selectedTimeSelesai;
  DateTime? _batasDaftarDate;
  bool _isSubmitting = false;
  List<int>? _imageBytes;
  String? _imageName;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    _notesCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      if (!mounted) return;
      SnackbarHelper.show(context, AppStrings.valGambarMax2MB, isError: true);
      return;
    }

    setState(() {
      _imageBytes = bytes.toList();
      _imageName = picked.name;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null && mounted) setState(() => _selectedTime = time);
  }

  Future<void> _pickDateSelesai() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateSelesai ?? _selectedDate.add(const Duration(hours: 2)),
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTimeSelesai ?? TimeOfDay.fromDateTime(_selectedDate.add(const Duration(hours: 2))),
    );
    if (time != null && mounted) {
      setState(() {
        _selectedDateSelesai = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _selectedTimeSelesai = time;
      });
    }
  }

  Future<void> _pickBatasDaftar() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _batasDaftarDate ?? _selectedDate,
      firstDate: DateTime.now(),
      lastDate: _selectedDate,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_batasDaftarDate ?? _selectedDate),
    );
    if (time != null && mounted) {
      setState(() {
        _batasDaftarDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      });
    }
  }

  Future<void> _confirmClose() async {
    final hasData = _titleCtrl.text.trim().isNotEmpty ||
        _linkCtrl.text.trim().isNotEmpty ||
        _notesCtrl.text.trim().isNotEmpty ||
        _capacityCtrl.text.trim().isNotEmpty ||
        _imageBytes != null;
    if (!hasData) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmBatalkan),
        content: const Text("Data yang sudah diisi akan hilang. Yakin ingin menutup?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.lanjutkanIsi)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.tutup, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && mounted) Navigator.pop(context);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      if (!mounted) return;
      SnackbarHelper.show(context, AppStrings.valJudulEventWajib, isError: true);
      return;
    }

    final selectedDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    if (selectedDateTime.isBefore(DateTime.now())) {
      if (!mounted) return;
      SnackbarHelper.show(context, AppStrings.valTanggalMasaLalu, isError: true);
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    try {
      final eventProv = context.read<EventProvider>();
      final tanggal = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);
      final capacityText = _capacityCtrl.text.trim();
      final kapasitas = capacityText.isEmpty ? null : int.tryParse(capacityText);
      if (capacityText.isNotEmpty && (kapasitas == null || kapasitas < 1)) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        SnackbarHelper.show(context, AppStrings.valKapasitasMin1, isError: true);
        return;
      }
      final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
      final ok = await eventProv.createEvent(
        judul: _titleCtrl.text.trim(),
        tanggal: tanggal,
        tanggalSelesai: _selectedDateSelesai != null ? fmt.format(_selectedDateSelesai!) : null,
        batasDaftar: _batasDaftarDate != null ? fmt.format(_batasDaftarDate!) : null,
        lokasi: _linkCtrl.text.trim().isEmpty ? 'Online' : _linkCtrl.text.trim(),
        deskripsi: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        kategori: _kategori,
        kapasitas: kapasitas,
        gambar: _imageBytes,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (ok) {
        SnackbarHelper.show(context, AppStrings.successEventDikirim);
        Navigator.pop(context);
      } else {
        SnackbarHelper.show(context, eventProv.error ?? AppStrings.errorGagalMembuatEvent, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      SnackbarHelper.show(context, "Gagal membuat event: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _confirmClose();
      },
      child: Container(
      height: Responsive.bottomSheetHeight(context),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -6))],
      ),
      padding: EdgeInsets.all(Responsive.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: context.textSecondaryColor, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.titleBuatEvent, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Ajukan agenda akademik UBG", style: TextStyle(color: context.textSecondaryColor, fontSize: 13)),
                ],
              ),
              IconButton.filledTonal(onPressed: _confirmClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppStrings.labelJudul),
                  const SizedBox(height: 8),
                  _field("Seminar Akademik", controller: _titleCtrl),
                  const SizedBox(height: 20),
                  _label(AppStrings.labelTanggal),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: context.scaffoldBgColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: context.textSecondaryColor),
                          const SizedBox(width: 12),
                          Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: TextStyle(fontSize: 14, color: context.onSurfaceColor)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label("WAKTU"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: context.scaffoldBgColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text("${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label("TANGGAL SELESAI (OPSIONAL)"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDateSelesai,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDateSelesai != null
                                ? '${_selectedDateSelesai!.day}/${_selectedDateSelesai!.month}/${_selectedDateSelesai!.year} ${_selectedTimeSelesai!.hour.toString().padLeft(2, '0')}:${_selectedTimeSelesai!.minute.toString().padLeft(2, '0')}'
                                : 'Atur waktu selesai',
                            style: TextStyle(fontSize: 14, color: _selectedDateSelesai != null ? Colors.black87 : Colors.black38),
                          ),
                          if (_selectedDateSelesai != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => setState(() { _selectedDateSelesai = null; _selectedTimeSelesai = null; }),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label("BATAS PENDAFTARAN (OPSIONAL)"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickBatasDaftar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _batasDaftarDate != null
                                ? '${_batasDaftarDate!.day}/${_batasDaftarDate!.month}/${_batasDaftarDate!.year} ${_batasDaftarDate!.hour.toString().padLeft(2, '0')}:${_batasDaftarDate!.minute.toString().padLeft(2, '0')}'
                                : 'Atur deadline pendaftaran',
                            style: TextStyle(fontSize: 14, color: _batasDaftarDate != null ? Colors.black87 : Colors.black38),
                          ),
                          if (_batasDaftarDate != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => setState(() { _batasDaftarDate = null; }),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label(AppStrings.labelKategori),
                  const SizedBox(height: 8),
                  _categoryField(),
                  const SizedBox(height: 20),
                  _label("TAUTAN MEETING"),
                  const SizedBox(height: 8),
                  _field("https://meet.google.com/...", icon: Icons.link, controller: _linkCtrl),
                  const SizedBox(height: 20),
                  _label(AppStrings.labelKapasitas),
                  const SizedBox(height: 8),
                  _field("Opsional, contoh: 50", icon: Icons.people_outline, controller: _capacityCtrl, keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _label(AppStrings.labelGambarEvent),
                  const SizedBox(height: 8),
                  if (_imageBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          Uint8List.fromList(_imageBytes!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _imageName ?? 'Pilih gambar dari komputer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: _imageName == null ? Colors.black38 : context.onSurfaceColor),
                            ),
                          ),
                          if (_imageName != null)
                            IconButton(
                              onPressed: () => setState(() {
                                _imageBytes = null;
                                _imageName = null;
                              }),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label(AppStrings.labelCatatan),
                  const SizedBox(height: 8),
                  _field("Tambahkan agenda, topik...", isLong: true, controller: _notesCtrl),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Menunggu approval", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 4),
                  Row(children: [Icon(Icons.circle, size: 8, color: AppColors.primary), SizedBox(width: 4), Icon(Icons.circle, size: 8, color: Colors.grey)]),
                ],
              ),
              const SizedBox(width: 40),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Buat Event →"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _label(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey));

  Widget _field(String hint, {IconData? icon, bool isLong = false, TextEditingController? controller, TextInputType? keyboardType}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: isLong ? 3 : 1,
      decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black38), border: InputBorder.none, suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null),
    ),
  );

  Widget _categoryField() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: DropdownButtonFormField<String>(
      initialValue: _kategori,
      decoration: const InputDecoration(border: InputBorder.none),
      items: AppStrings.allCategories
          .map((kategori) => DropdownMenuItem(value: kategori, child: Text(kategori)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _kategori = value);
      },
    ),
  );
}
