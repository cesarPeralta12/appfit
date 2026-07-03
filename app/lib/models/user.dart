class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? photo;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photo,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'] ?? 'coach',
        phone: json['phone'],
        photo: json['photo'],
      );
}
