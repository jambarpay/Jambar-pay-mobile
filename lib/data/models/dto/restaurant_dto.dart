import '../../../domain/entities/restaurant.dart';
import '../../../domain/entities/partner_category.dart';

class RestaurantDto {
  const RestaurantDto({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.updatedAt,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
    this.category = PartnerCategory.restaurant,
  });

  final String id;
  final String name;
  final double distanceKm;
  final DateTime updatedAt;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String address;
  final String status;
  final PartnerCategory category;

  factory RestaurantDto.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString().toUpperCase() ?? 'PENDING';
    final address =
        [json['street'], json['district'], json['city'], json['country']]
            .where((part) => part != null && part.toString().trim().isNotEmpty)
            .map((part) => part.toString().trim())
            .join(', ');
    return RestaurantDto(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      isOpen: json['isOpen'] as bool? ?? status == 'ACTIVE',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? address,
      status: status,
      category: PartnerCategory.fromApi(
        json['partnerType'] ?? json['category'],
      ),
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
    address: address,
    status: status,
    category: category,
  );
}
