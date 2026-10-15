/// A display category, independent of payment eligibility and permissions.
enum PartnerCategory {
  restaurant,
  shop,
  supermarket,
  market,
  other;

  static const selectable = [restaurant, shop, supermarket, market];

  static PartnerCategory fromApi(Object? value) {
    // Older API responses and offline caches contain only restaurants.
    if (value == null || value.toString().trim().isEmpty) return restaurant;
    return switch (value.toString().trim().toUpperCase()) {
      'RESTAURANT' => restaurant,
      'SHOP' || 'BOUTIQUE' => shop,
      'SUPERMARKET' || 'SUPERMARCHE' || 'SUPERMARCHÉ' => supermarket,
      'MARKET' || 'MARCHE' || 'MARCHÉ' => market,
      _ => other,
    };
  }
}
