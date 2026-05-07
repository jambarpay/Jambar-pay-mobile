import '../value_objects/phone_number.dart';

class User {
  final String id;
  final String name;
  final PhoneNumber phone;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  User copyWith({
    String? id,
    String? name,
    PhoneNumber? phone,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => Object.hash(id, name, phone, avatarUrl);
}
