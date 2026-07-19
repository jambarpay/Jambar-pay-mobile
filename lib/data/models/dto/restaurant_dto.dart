import '../../../domain/entities/restaurant.dart';

class RestaurantDto {
  const RestaurantDto({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.updatedAt,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double distanceKm;
  final DateTime updatedAt;
  final bool isOpen;
  final double latitude;
  final double longitude;

  factory RestaurantDto.fromJson(Map<String, dynamic> json) {
    return RestaurantDto(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isOpen: json['isOpen'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Restaurant toDomain() => Restaurant(
    id: id,
    name: name,
    distanceKm: distanceKm,
    updatedAt: updatedAt,
    isOpen: isOpen,
    latitude: latitude,
    longitude: longitude,
  );
}
