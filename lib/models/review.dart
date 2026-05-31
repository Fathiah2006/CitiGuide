/// A user review for a listing. Mirrors the `reviews` (+ `review_likes`) tables.
class Review {
  final String user;
  final int rating; // 1..5
  final String date; // human friendly ("2 weeks ago", "Just now")
  final int likes;
  final bool liked;
  final String text;

  const Review({
    required this.user,
    required this.rating,
    required this.date,
    required this.likes,
    required this.liked,
    required this.text,
  });

  Review copyWith({int? likes, bool? liked}) => Review(
        user: user,
        rating: rating,
        date: date,
        likes: likes ?? this.likes,
        liked: liked ?? this.liked,
        text: text,
      );
}
