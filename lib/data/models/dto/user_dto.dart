import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/phone_number.dart';

class UserDto {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const UserDto({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }

  User toDomain() => User(
        id: id,
        name: name,
        phone: PhoneNumber(phone),
        avatarUrl: avatarUrl,
      );

  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      phone: user.phone.value,
      avatarUrl: user.avatarUrl,
    );
  }
}
