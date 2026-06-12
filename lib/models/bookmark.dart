enum BookmarkableType { event, informasi }

class Bookmark {
  final int id;
  final int userId;
  final int bookmarkableId;
  final BookmarkableType type;
  final String createdAt;
  final Map<String, dynamic>? bookmarkable;

  Bookmark({
    required this.id,
    required this.userId,
    required this.bookmarkableId,
    required this.type,
    required this.createdAt,
    this.bookmarkable,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final rawType = (json['bookmarkable_type'] as String? ?? '');
    return Bookmark(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookmarkableId: json['bookmarkable_id'] ?? 0,
      type: rawType.contains('Event') ? BookmarkableType.event : BookmarkableType.informasi,
      createdAt: json['created_at'] ?? '',
      bookmarkable: json['bookmarkable'] is Map<String, dynamic>
          ? json['bookmarkable'] as Map<String, dynamic>
          : null,
    );
  }
}
