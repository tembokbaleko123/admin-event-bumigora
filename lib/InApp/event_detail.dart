import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/providers/registration_provider.dart';
import 'package:aplikasi_kampus/providers/bookmark_provider.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/models/creator.dart';
import 'package:aplikasi_kampus/providers/attendance_provider.dart';
import 'package:aplikasi_kampus/admin/participants_screen.dart';
import 'package:aplikasi_kampus/admin/attendance_report_screen.dart';
import 'package:aplikasi_kampus/func/scan_qr_screen.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/func/show_qr_screen.dart';
import 'package:aplikasi_kampus/func/event_analytics_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final int? eventId;
  final String? title;
  final String? location;
  final String? time;
  final String? type;

  const EventDetailScreen({
    super.key,
    this.eventId,
    this.title,
    this.location,
    this.time,
    this.type,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventModel? _event;
  bool _isLoading = true;
  String? _error;
  bool _regLoading = false;

  @override
  void initState() {
    super.initState();
    // Load event after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvent();
    });
  }

  Future<void> _loadEvent() async {
    if (!mounted) return;
    if (widget.eventId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // Get providers safely
      final eventProv = context.read<EventProvider>();
      final regProv = context.read<RegistrationProvider>();
      final attProv = context.read<AttendanceProvider>();
      final bmProv = context.read<BookmarkProvider>();

      // Load event detail
      final event = await eventProv.getDetail(widget.eventId!);

      if (!mounted) return;

      setState(() {
        _event = event;
        _isLoading = false;
        if (event == null) _error = AppStrings.errorDetailEvent;
      });

      // Load registration, attendance, and bookmark status in parallel
      if (widget.eventId != null && mounted) {
        await Future.wait([
          regProv.checkRegistration(widget.eventId!),
          attProv.checkAttendance(widget.eventId!),
        ]);
        bmProv.checkStatus(AppStrings.bookmarkTypeEvent, widget.eventId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.errorTerjadiKesalahan;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (widget.eventId == null || !mounted) return;

    setState(() => _regLoading = true);

    try {
      final regProv = context.read<RegistrationProvider>();
      final ok = await regProv.register(widget.eventId!);

      if (!mounted) return;

      setState(() => _regLoading = false);

      SnackbarHelper.show(
        context,
        ok ? AppStrings.successPendaftaran : regProv.error ?? AppStrings.errorGagalDaftar,
        isError: !ok,
      );

      if (ok) {
        await _loadEvent();
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _regLoading = false);
      SnackbarHelper.show(context, AppStrings.errorGagalDaftar, isError: true);
    }
  }

  Future<void> _handleCancel() async {
    if (widget.eventId == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmBatalkanPendaftaran),
        content: const Text(AppStrings.msgYakinBatalkanPendaftaran),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.tidak)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.yaBatalkan, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _regLoading = true);

    try {
      final regProv = context.read<RegistrationProvider>();
      final ok = await regProv.cancel(widget.eventId!);

      if (!mounted) return;

      setState(() => _regLoading = false);

      SnackbarHelper.show(
        context,
        ok ? AppStrings.successPendaftaranDibatalkan : regProv.error ?? AppStrings.errorGagalBatalkan,
        isError: !ok,
      );

      if (ok) {
        await _loadEvent();
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _regLoading = false);
      SnackbarHelper.show(context, AppStrings.errorGagalBatalkan, isError: true);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmHapusEvent),
        content: const Text(AppStrings.msgYakinHapusEvent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final eventProv = context.read<EventProvider>();
      final ok = await eventProv.deleteEvent(widget.eventId!);

      if (!mounted) return;

      if (ok) {
        SnackbarHelper.show(context, AppStrings.successEventDihapus);
        if (mounted) Navigator.pop(context, true);
      } else {
        SnackbarHelper.show(context, eventProv.error ?? AppStrings.errorGagalEventDihapus, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, AppStrings.errorGagalEventDihapus, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.screenPadding(context);
    final displayTitle = _event?.judul ?? widget.title ?? AppStrings.titleDetailEvent;
    final displayType = _event?.kategori ?? widget.type ?? 'EVENT';
    final eventDate = _event != null ? DateTime.tryParse(_event!.tanggal) : null;

    final displayTime = _event != null ? DateFormatter.formatTime(_event!.tanggal) : (widget.time ?? '');
    final deadLine = _event?.batasDaftar != null ? DateTime.tryParse(_event!.batasDaftar!) : null;
    final registrationCountdown = deadLine != null
        ? DateFormatter.countdown(deadLine)
        : (eventDate != null ? DateFormatter.countdown(eventDate) : '');
    final displayLocation = _event?.lokasi ?? widget.location ?? '-';

    final user = context.watch<AuthProvider>().user;
    final isMhs = user?.isMahasiswa ?? false;
    final isDosen = user?.isDosen ?? false;
    final isAdmin = user?.isAdmin ?? false;
    final regProv = context.watch<RegistrationProvider>();
    final registered = widget.eventId != null ? regProv.isRegistered(widget.eventId!) : false;
    final regStatus = widget.eventId != null ? regProv.registrationStatusFor(widget.eventId!) : null;
    final attProv = context.watch<AttendanceProvider>();
    final alreadyAttended = widget.eventId != null ? attProv.hasAttended(widget.eventId!) : false;

    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const ShimmerLoading(),
      );
    }

    if (_error != null && _event == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadEvent,
                  icon: const Icon(Icons.refresh),
                  label: const Text(AppStrings.cobaLagi),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: pad,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_event?.gambarUrl != null && _event!.gambarUrl!.isNotEmpty) ...[
              _imageSection(_event!.gambarUrl!),
              const SizedBox(height: 16),
            ],
            _mainCard(displayTitle, displayType, displayTime, displayLocation, _event?.deskripsi),
            const SizedBox(height: 16),

            if (_event?.kapasitas != null || _event?.totalPendaftar != null) ...[
              _statsCard(),
              const SizedBox(height: 16),
            ],

            _actionCard(icon: Icons.location_on_outlined, iconBg: AppColors.primary, title: "Location", subtitle: displayLocation, trailing: const Icon(Icons.chevron_right, color: Colors.grey)),
            if (_event != null && _event!.creator != null) ...[
              const SizedBox(height: 16),
              _creatorCard(_event!.creator!),
            ],
            const SizedBox(height: 16),

            if (isMhs && _event != null) ...[
              if (registered && !alreadyAttended)
                _scanQrButton(),
              if (!alreadyAttended)
                _registrationButton(registered, regStatus, registrationCountdown: registrationCountdown),
            ],

            if (isDosen || isAdmin) ...[
              _qrManagementButtons(),
              const SizedBox(height: 8),
              _viewParticipantsButton(),
              const SizedBox(height: 8),
              _analyticsButton(),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _statsCard() {
    final kapasitas = _event?.kapasitas;
    final total = _event?.totalPendaftar ?? 0;
    final sisa = _event?.sisaKuota;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.people_outline, AppStrings.labelPendaftar, total.toString()),
          if (kapasitas != null) ...[
            Container(width: 1, height: 30, color: Colors.grey.shade200),
            _statItem(Icons.group_add_outlined, AppStrings.labelKuota, kapasitas.toString()),
            Container(width: 1, height: 30, color: Colors.grey.shade200),
            _statItem(Icons.flight_takeoff_outlined, AppStrings.labelSisa, sisa.toString()),
          ],
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _registrationButton(bool registered, String? status, {String registrationCountdown = ''}) {
    if (status == AppStrings.statusAttended) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Anda sudah hadir", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (status == AppStrings.statusAbsent) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text("Tidak hadir", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (registered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(AppStrings.labelTerdaftar, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _regLoading ? null : _handleCancel,
              icon: _regLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cancel_outlined, color: Colors.red),
              label: Text(_regLoading ? "Memproses..." : AppStrings.confirmBatalkanPendaftaran,
                  style: const TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    final disabledReason = _registrationDisabledReason();
    final canRegister = disabledReason == null && !_regLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (registrationCountdown.isNotEmpty && disabledReason == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Text('Sisa waktu pendaftaran: $registrationCountdown',
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canRegister ? _handleRegister : null,
            icon: _regLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.event_seat_outlined),
            label: Text(_regLoading ? "Memproses..." : disabledReason ?? "Daftar Event"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }

  String? _registrationDisabledReason() {
    final event = _event;
    if (event == null) return 'Event tidak tersedia';

    switch (event.status) {
      case AppStrings.statusPublished:
        break;
      case AppStrings.statusPending:
        return 'Menunggu Approval';
      case AppStrings.statusRejected:
        return 'Event Ditolak';
      case AppStrings.statusCancelled:
        return 'Event Dibatalkan';
      case AppStrings.statusCompleted:
        return 'Event Selesai';
      default:
        return 'Event Belum Tersedia';
    }

    final eventDate = DateTime.tryParse(event.tanggal);
    if (eventDate != null && eventDate.isBefore(DateTime.now())) {
      return 'Event Sudah Lewat';
    }

    final deadline = event.batasDaftar != null ? DateTime.tryParse(event.batasDaftar!) : null;
    if (deadline != null && deadline.isBefore(DateTime.now())) {
      return 'Pendaftaran Ditutup';
    }

    if (event.kapasitas != null && (event.sisaKuota ?? 0) <= 0) {
      return 'Kuota Penuh';
    }

    return null;
  }

  Widget _viewParticipantsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _event != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParticipantsScreen(
                      eventId: _event!.id,
                      eventTitle: _event!.judul,
                    ),
                  ),
                );
              }
            : null,
        icon: const Icon(Icons.people_outline),
        label: Text("Lihat Peserta (${_event?.totalPendaftar ?? 0})"),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _analyticsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _event != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventAnalyticsScreen(
                      eventId: _event!.id,
                      eventTitle: _event!.judul,
                    ),
                  ),
                );
              }
            : null,
        icon: const Icon(Icons.analytics_outlined),
        label: const Text("Analytics Event"),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = context.watch<AuthProvider>().user;
    final canDelete = _event != null && (user?.isAdmin == true || (user?.isDosen == true && _event!.createdBy == user?.id));
    final bmProv = context.watch<BookmarkProvider>();
    final bookmarked = widget.eventId != null ? bmProv.isBookmarked(AppStrings.bookmarkTypeEvent, widget.eventId!) : false;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(backgroundColor: context.surfaceColor, child: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.onSurfaceColor), onPressed: () => Navigator.pop(context))),
      ),
      title: Text(AppStrings.titleDetailEvent, style: TextStyle(color: context.onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        IconButton(
          icon: Icon(
            bookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: bookmarked ? AppColors.primary : Colors.grey.shade600,
          ),
          onPressed: widget.eventId != null
              ? () {
                  bmProv.toggle(AppStrings.bookmarkTypeEvent, widget.eventId!);
                }
              : null,
        ),
        if (canDelete)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            onSelected: (v) {
              if (v == 'delete') _confirmDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Row(
                children: [Icon(Icons.delete_outline, color: Colors.red, size: 20), SizedBox(width: 8), Text(AppStrings.confirmHapusEvent, style: TextStyle(color: Colors.red))],
              )),
            ],
          ),
      ],
    );
  }

  Widget _imageSection(String imageUrl) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(height: 200, color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (_, _, _) => Container(height: 200, color: Colors.grey.shade100, child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _mainCard(String titleText, String typeText, String timeText, String locationText, String? deskripsi) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8C8EF1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tag(typeText, Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              _tag(
                _event?.status?.toUpperCase() ?? "PUBLISHED",
                Colors.white.withValues(alpha: 0.2),
                isStatus: true,
                statusColor: _eventStatusColor(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(titleText, style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 22), fontWeight: FontWeight.bold)),
          if (deskripsi != null && deskripsi.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(deskripsi, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 5, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 20),
          _iconText(Icons.location_on_outlined, locationText),
          const SizedBox(height: 12),
          _iconText(Icons.calendar_today, _event != null ? DateFormatter.fullDate(DateTime.parse(_event!.tanggal)) : ''),
          const SizedBox(height: 12),
          _iconText(Icons.access_time, timeText),
          if (_event?.tanggalSelesai != null) ...[
            const SizedBox(height: 8),
            _iconText(Icons.timer_outlined, 'Durasi: ${DateFormatter.formatDuration(DateTime.parse(_event!.tanggal), DateTime.parse(_event!.tanggalSelesai!))}'),
          ],
        ],
      ),
    );
  }

  Widget _creatorCard(Creator creator) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              creator.nama.isNotEmpty ? creator.nama[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Created by", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(creator.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, {Color textColor = Colors.white, bool isStatus = false, Color statusColor = Colors.greenAccent}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStatus) ...[Icon(Icons.circle, color: statusColor, size: 8), const SizedBox(width: 6)],
          Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _eventStatusColor() {
    switch (_event?.status) {
      case AppStrings.statusPending:
        return Colors.orangeAccent;
      case AppStrings.statusPublished:
        return Colors.greenAccent;
      case AppStrings.statusRejected:
        return Colors.redAccent;
      case AppStrings.statusCancelled:
        return Colors.grey;
      case AppStrings.statusCompleted:
        return Colors.lightBlueAccent;
      default:
        return Colors.white70;
    }
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _qrManagementButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _event != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShowQrScreen(
                          eventId: _event!.id,
                          eventTitle: _event!.judul,
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.qr_code_2_rounded),
            label: const Text("Kelola QR Absensi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _event != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceReportScreen(
                          eventId: _event!.id,
                          eventTitle: _event!.judul,
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.assessment_outlined),
            label: const Text("Laporan Absensi"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _scanQrButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _event != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanQrScreen(
                      eventId: _event!.id,
                      eventTitle: _event!.judul,
                    ),
                  ),
                ).then((_) {
                  if (mounted) {
                    final attProv = context.read<AttendanceProvider>();
                    final regProv = context.read<RegistrationProvider>();
                    attProv.checkAttendance(_event!.id);
                    regProv.checkRegistration(_event!.id);
                    _loadEvent();
                  }
                });
              }
            : null,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text(AppStrings.titleScanQR),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: Colors.teal.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _actionCard({required IconData icon, required Color iconBg, Color iconColor = Colors.white, required String title, required String subtitle, Color subtitleColor = Colors.black, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: subtitleColor), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
