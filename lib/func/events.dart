import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final TabController _tabCtrl;
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) setState(() => _tab = _tabCtrl.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final position = _scrollCtrl.position;
      if (position.pixels > position.maxScrollExtent - 260) {
        context.read<EventProvider>().loadMoreEvents();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      
      appBar: AppBar(
        title: const Text(AppStrings.labelJadwal),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: const Icon(Icons.notifications_none, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: AppStrings.labelMendatang),
                  Tab(text: AppStrings.labelSelesai),
                  Tab(text: AppStrings.labelSemua),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari event...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? context.watch<EventProvider>().state == LoadState.loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                        : IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); _search(); })
                    : null,
                filled: true,
                fillColor: context.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (_) => _search(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    final eventProv = context.watch<EventProvider>();
    if (eventProv.state == LoadState.loading) {
      return const ShimmerLoading(itemCount: 5, itemHeight: 90, padding: EdgeInsets.all(16));
    }
    if (eventProv.state == LoadState.error) {
      return ErrorDisplayWidget(message: eventProv.error ?? 'Gagal memuat event', onRetry: () => eventProv.loadEvents(force: true));
    }

    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final sourceEvents = user?.isDosen == true
        ? eventProv.events.where((event) => event.createdBy == user!.id).toList()
        : eventProv.events;
    final list = _eventsForTab(sourceEvents);
    if (list.isEmpty) {
      return const EmptyStateWidget(icon: Icons.calendar_today_rounded, title: AppStrings.emptyJadwal, subtitle: "Jadwal kamu akan tampil di sini.");
    }

    return RefreshIndicator(
      onRefresh: () => eventProv.loadEvents(force: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: EdgeInsets.all(Responsive.padding(context)),
        itemCount: list.length + 2,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                user?.isDosen == true ? "${list.length} event saya" : "${list.length} event",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            );
          }
          if (i == list.length + 1) {
            if (!eventProv.hasMore) return const SizedBox(height: 20);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: eventProv.isLoadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () => eventProv.loadMoreEvents(),
                        child: const Text(AppStrings.muatLagi),
                      ),
              ),
            );
          }
          return _managementCard(list[i - 1], i - 1);
        },
      ),
    );
  }

  Widget _managementCard(EventModel event, int index) {
    return AnimatedListItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _statusColor(event.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.event_note, color: _statusColor(event.status), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.judul, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${DateFormatter.formatTime(event.tanggal)} - ${event.lokasi}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(event.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, RouteTransitions.slideFromRight(EventDetailScreen(eventId: event.id, title: event.judul))),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text(AppStrings.detail),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditSheet(event),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(AppStrings.edit),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () => _confirmDelete(event),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(EventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmHapusEvent),
        content: Text('Yakin ingin menghapus ${event.judul}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<EventProvider>();
    final ok = await provider.deleteEvent(event.id);
    if (!mounted) return;
    SnackbarHelper.show(context, ok ? AppStrings.successEventDihapusSingkat : provider.error ?? AppStrings.errorGagalEventDihapus, isError: !ok);
  }

  Future<void> _showEditSheet(EventModel event) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditEventModal(event: event),
    );
    if (changed == true && mounted) {
      context.read<EventProvider>().loadEvents(force: true);
    }
  }

  void _search() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<EventProvider>().loadEvents(search: _searchCtrl.text.trim());
      setState(() {});
    });
  }

  List<EventModel> _eventsForTab(List<EventModel> events) {
    final now = DateTime.now();
    bool isPast(EventModel event) {
      final date = DateTime.tryParse(event.tanggal);
      if (date == null) return false;
      return date.isBefore(DateTime(now.year, now.month, now.day));
    }

    if (_tab == 0) return events.where((event) => !isPast(event)).toList();
    if (_tab == 1) return events.where(isPast).toList();
    return events;
  }

  Widget _statusBadge(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(_statusLabel(status), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case AppStrings.statusPending:
        return Colors.orange;
      case AppStrings.statusPublished:
        return Colors.green;
      case AppStrings.statusRejected:
        return Colors.red;
      case AppStrings.statusCompleted:
        return Colors.blueGrey;
      case AppStrings.statusCancelled:
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case AppStrings.statusPending:
        return 'Pending';
      case AppStrings.statusPublished:
        return 'Published';
      case AppStrings.statusRejected:
        return 'Ditolak';
      case AppStrings.statusCompleted:
        return 'Selesai';
      case AppStrings.statusCancelled:
        return 'Batal';
      default:
        return status ?? '-';
    }
  }
}

class _EditEventModal extends StatefulWidget {
  final EventModel event;

  const _EditEventModal({required this.event});

  @override
  State<_EditEventModal> createState() => _EditEventModalState();
}

class _EditEventModalState extends State<_EditEventModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _capacityCtrl;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  DateTime? _selectedDateSelesai;
  TimeOfDay? _selectedTimeSelesai;
  DateTime? _batasDaftarDate;
  late String _kategori;
  bool _isSubmitting = false;
  List<int>? _imageBytes;
  String? _imageName;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    final parsedDate = DateTime.tryParse(widget.event.tanggal) ?? DateTime.now().add(const Duration(hours: 1));
    _titleCtrl = TextEditingController(text: widget.event.judul);
    _locationCtrl = TextEditingController(text: widget.event.lokasi);
    _notesCtrl = TextEditingController(text: widget.event.deskripsi ?? '');
    _capacityCtrl = TextEditingController(text: widget.event.kapasitas?.toString() ?? '');
    _selectedDate = parsedDate;
    _selectedTime = TimeOfDay.fromDateTime(parsedDate);
    _kategori = widget.event.kategori ?? AppStrings.catSeminar;
    _batasDaftarDate = widget.event.batasDaftar != null ? DateTime.tryParse(widget.event.batasDaftar!) : null;
    final selesai = widget.event.tanggalSelesai;
    if (selesai != null) {
      final dt = DateTime.tryParse(selesai);
      if (dt != null) {
        _selectedDateSelesai = dt;
        _selectedTimeSelesai = TimeOfDay.fromDateTime(dt);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(DateTime.now()) ? DateTime.now() : _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null && mounted) setState(() => _selectedTime = time);
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
      _removeImage = false;
    });
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
    final hasData = _titleCtrl.text.trim() != widget.event.judul ||
        _locationCtrl.text.trim() != widget.event.lokasi ||
        _notesCtrl.text.trim() != (widget.event.deskripsi ?? '') ||
        _capacityCtrl.text.trim() != (widget.event.kapasitas?.toString() ?? '') ||
        _kategori != widget.event.kategori ||
        _imageBytes != null || _removeImage;
    if (!hasData) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmBatalkan),
        content: const Text("Perubahan yang sudah dibuat akan hilang. Yakin ingin menutup?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.lanjutkanEdit)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.tutup, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && mounted) Navigator.pop(context);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      SnackbarHelper.show(context, AppStrings.valJudulLokasiWajib, isError: true);
      return;
    }

    final capacityText = _capacityCtrl.text.trim();
    final kapasitas = capacityText.isEmpty ? null : int.tryParse(capacityText);
    if (capacityText.isNotEmpty && (kapasitas == null || kapasitas < 1)) {
      SnackbarHelper.show(context, AppStrings.valKapasitasMin1, isError: true);
      return;
    }

    final selectedDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    if (selectedDateTime.isBefore(DateTime.now())) {
      SnackbarHelper.show(context, AppStrings.valTanggalMasaLalu, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<EventProvider>();
    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    final ok = await provider.updateEvent(
      id: widget.event.id,
      judul: _titleCtrl.text.trim(),
      tanggal: fmt.format(selectedDateTime),
      tanggalSelesai: _selectedDateSelesai != null ? fmt.format(_selectedDateSelesai!) : null,
      batasDaftar: _batasDaftarDate != null ? fmt.format(_batasDaftarDate!) : null,
      lokasi: _locationCtrl.text.trim(),
      deskripsi: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      kategori: _kategori,
      kapasitas: kapasitas,
      gambar: _imageBytes,
      hapusGambar: _removeImage,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      SnackbarHelper.show(context, AppStrings.successEventDiperbarui);
      Navigator.pop(context, true);
    } else {
      SnackbarHelper.show(context, provider.error ?? AppStrings.errorGagalMemperbaruiEvent, isError: true);
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
      padding: EdgeInsets.all(Responsive.padding(context)),
      decoration: BoxDecoration(color: context.surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.titleEditEvent, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(onPressed: _confirmClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppStrings.labelJudul),
                  _field(_titleCtrl, 'Judul event'),
                  const SizedBox(height: 16),
                  _label(AppStrings.labelLokasi),
                  _field(_locationCtrl, 'Lokasi'),
                  const SizedBox(height: 16),
                  _label(AppStrings.labelTanggal),
                  _pickerTile(Icons.calendar_today, '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', _pickDate),
                  const SizedBox(height: 16),
                  _label('WAKTU'),
                  _pickerTile(Icons.access_time, '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}', _pickTime),
                  const SizedBox(height: 16),
                  _label('TANGGAL SELESAI (OPSIONAL)'),
                  GestureDetector(
                    onTap: _pickDateSelesai,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.event, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDateSelesai != null ? '${_selectedDateSelesai!.day}/${_selectedDateSelesai!.month}/${_selectedDateSelesai!.year} ${_selectedTimeSelesai!.hour.toString().padLeft(2, '0')}:${_selectedTimeSelesai!.minute.toString().padLeft(2, '0')}' : 'Atur waktu selesai',
                              style: TextStyle(fontSize: 14, color: _selectedDateSelesai != null ? Colors.black87 : Colors.black38),
                            ),
                          ),
                          if (_selectedDateSelesai != null)
                            GestureDetector(
                              onTap: () => setState(() { _selectedDateSelesai = null; _selectedTimeSelesai = null; }),
                              child: const Icon(Icons.close, size: 16, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('BATAS PENDAFTARAN (OPSIONAL)'),
                  GestureDetector(
                    onTap: _pickBatasDaftar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _batasDaftarDate != null ? '${_batasDaftarDate!.day}/${_batasDaftarDate!.month}/${_batasDaftarDate!.year} ${_batasDaftarDate!.hour.toString().padLeft(2, '0')}:${_batasDaftarDate!.minute.toString().padLeft(2, '0')}' : 'Atur deadline pendaftaran',
                              style: TextStyle(fontSize: 14, color: _batasDaftarDate != null ? Colors.black87 : Colors.black38),
                            ),
                          ),
                          if (_batasDaftarDate != null)
                            GestureDetector(
                              onTap: () => setState(() { _batasDaftarDate = null; }),
                              child: const Icon(Icons.close, size: 16, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label(AppStrings.labelKategori),
                  DropdownButtonFormField<String>(
                    initialValue: _kategori,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: AppStrings.allCategories.map((kategori) => DropdownMenuItem(value: kategori, child: Text(kategori))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _kategori = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _label(AppStrings.labelKapasitas),
                  _field(_capacityCtrl, 'Opsional', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _label(AppStrings.labelGambarEvent),
                  _imagePicker(),
                  const SizedBox(height: 16),
                  _label(AppStrings.labelCatatan),
                  _field(_notesCtrl, 'Catatan', maxLines: 3),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text(AppStrings.simpanPerubahan),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      );

  Widget _field(TextEditingController controller, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  Widget _imagePicker() {
    final hasCurrentImage = (widget.event.gambarUrl ?? widget.event.gambar)?.isNotEmpty == true;
    final label = _imageName ?? (_removeImage
        ? 'Gambar akan dihapus'
        : hasCurrentImage
            ? 'Gambar saat ini tersedia'
            : 'Pilih gambar dari komputer');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          )
        else if (hasCurrentImage && !_removeImage && widget.event.gambarUrl != null && widget.event.gambarUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.event.gambarUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(height: 120, color: Colors.grey.shade100),
                errorWidget: (_, _, _) => Container(height: 120, color: Colors.grey.shade100, child: const Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(_removeImage ? Icons.hide_image_outlined : Icons.image_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _removeImage ? Colors.red : Colors.grey.shade700),
                  ),
                ),
                if (_imageName != null || hasCurrentImage)
                  IconButton(
                    tooltip: 'Hapus gambar',
                    onPressed: () => setState(() {
                      _imageBytes = null;
                      _imageName = null;
                      _removeImage = hasCurrentImage;
                    }),
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pickerTile(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 10), Text(text)]),
      ),
    );
  }
}
