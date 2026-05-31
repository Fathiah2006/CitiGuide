/// The signed-in user's profile. Mirrors the `profiles` table.
class Profile {
  final String name;
  final String email;
  final String phone;
  final String joined;

  const Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.joined,
  });

  /// Uppercase initials derived from the name, e.g. "Amara Okonkwo" -> "AO".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Profile copyWith({String? name, String? email, String? phone, String? joined}) =>
      Profile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        joined: joined ?? this.joined,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'phone': phone, 'joined': joined};

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
        joined: j['joined'] as String,
      );
}
