import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/models/bookmark.dart';
import 'package:aplikasi_kampus/providers/bookmark_provider.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/func/informasi_detail.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _load();
      }
    });
  }

  void _load() {
    if (!mounted) return;
    try {
      context.read<BookmarkProvider>().loadBookmarks();
    } catch (e) {
      debugPrint('Failed to load bookmarks: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookmarkProvider>();
    final bookmarks = bp.bookmarks;

    final eventBookmarks = bookmarks.where((b) => b.type == BookmarkableType.event).toList();
    final infoBookmarks = bookmarks.where((b) => b.type == BookmarkableType.informasi).toList();

    final eventBookmarksFiltered = eventBookmarks.where((b) {
      final data = b.bookmarkable;
      if (data == null) return false;
      final title = (data['judul'] ?? '').toString().toLowerCase();
      return _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
    }).toList();

    final infoBookmarksFiltered = infoBookmarks.where((b) {
      final data = b.bookmarkable;
      if (data == null) return false;
      final title = (data['judul'] ?? '').toString().toLowerCase();
      return _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: context.surfaceColor,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.onSurfaceColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(AppStrings.titleBookmark,
            style: TextStyle(color: context.onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: "Event (${eventBookmarks.length})"),
            Tab(text: "Informasi (${infoBookmarks.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari bookmark...',
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
            child: bp.isLoading
                ? const ShimmerLoading()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _bookmarkList(eventBookmarksFiltered, isEvent: true),
                      _bookmarkList(infoBookmarksFiltered, isEvent: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bookmarkList(List<Bookmark> items, {required bool isEvent}) {
    if (items.isEmpty) {
      return const EmptyStateWidget(title: AppStrings.emptyBookmark, icon: Icons.bookmark_border);
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final bookmark = items[index];
          final data = bookmark.bookmarkable;

          if (data == null) return const SizedBox();

          final title = data['judul'] ?? 'Tanpa Judul';
          final date = data['tanggal'] ?? '';
          final creator = data['creator'] is Map ? data['creator']['nama'] ?? '-' : '-';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: context.surfaceColor,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isEvent
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  child: Icon(
                    isEvent ? Icons.event : Icons.info_outline,
                    color: isEvent ? AppColors.primary : Colors.orange,
                  ),
                ),
                title: Text(title.toString(), style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text("$creator • ${_formatDate(date)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text(AppStrings.confirmHapusBookmark),
                        content: const Text(AppStrings.msgYakinHapusBookmark),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context.read<BookmarkProvider>().toggle(
                        isEvent ? AppStrings.bookmarkTypeEvent : AppStrings.bookmarkTypeInformasi,
                        bookmark.bookmarkableId,
                      );
                    }
                  },
                ),
                onTap: () {
                  if (!context.mounted) return;
                  if (isEvent) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EventDetailScreen(eventId: bookmark.bookmarkableId),
                    )).then((_) {
                      if (mounted) _load();
                    });
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => InformasiDetailScreen(informasiId: bookmark.bookmarkableId),
                    )).then((_) {
                      if (mounted) _load();
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormatter.fullDate(dt);
    } catch (_) {
      return date;
    }
  }
}