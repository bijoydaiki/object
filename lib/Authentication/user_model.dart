class User {
  final String userId;
  final String name;

  User({required this.userId, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    final userId = json['id']?.toString() ?? '';
    if (userId.isEmpty) {
      throw Exception('User ID is missing or invalid in API response');
    }
    return User(
      userId: userId,
      name: json['name'] ?? '',
    );
  }
}