/// A user review for a listing. Mirrors the `reviews` (+ `review_likes`) tables.
class Review {
  final String? id; // present for reviews loaded from the backend
  final String user;
  final int rating; // 1..5
  final String date; // human friendly ("2 weeks ago", "Just now")
  final int likes;
  final bool liked;
  final String text;

  const Review({
    this.id,
    required this.user,
    required this.rating,
    required this.date,
    required this.likes,
    required this.liked,
    required this.text,
  });

  Review copyWith({int? likes, bool? liked}) => Review(
        id: id,
        user: user,
        rating: rating,
        date: date,
        likes: likes ?? this.likes,
        liked: liked ?? this.liked,
        text: text,
      );

  factory Review.fromMap(Map<String, dynamic> m) => Review(
        id: m['id'] as String?,
        user: (m['author_name'] ?? 'A user') as String,
        rating: (m['rating'] as num?)?.toInt() ?? 5,
        date: _relative(m['created_at'] as String?),
        likes: 0,
        liked: false,
        text: (m['comment'] ?? '') as String,
      );

  static String _relative(String? iso) {
    if (iso == null) return 'Recently';
    final then = DateTime.tryParse(iso);
    if (then == null) return 'Recently';
    final d = DateTime.now().difference(then);
    if (d.inDays >= 60) return '${(d.inDays / 30).floor()} months ago';
    if (d.inDays >= 30) return '1 month ago';
    if (d.inDays >= 14) return '2 weeks ago';
    if (d.inDays >= 7) return '1 week ago';
    if (d.inDays >= 1) return '${d.inDays} days ago';
    if (d.inHours >= 1) return '${d.inHours} hours ago';
    return 'Just now';
  }
}
