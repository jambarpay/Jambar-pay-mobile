class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.updatedAt,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.status = 'PENDING',
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

  bool get hasCoordinates => latitude != 0 || longitude != 0;
}
