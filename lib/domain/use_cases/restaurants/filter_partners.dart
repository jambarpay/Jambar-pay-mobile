import '../../entities/partner_category.dart';
import '../../entities/restaurant.dart';

List<Restaurant> filterPartners(
  Iterable<Restaurant> partners, {
  PartnerCategory? category,
  String query = '',
}) {
  final search = query.trim().toLowerCase();
  return partners
      .where((partner) {
        return (category == null || partner.category == category) &&
            (search.isEmpty ||
                partner.name.toLowerCase().contains(search) ||
                partner.address.toLowerCase().contains(search));
      })
      .toList(growable: false);
}
