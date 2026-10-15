import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/data/models/dto/restaurant_dto.dart';
import 'package:jambar_pay_mobile/domain/entities/partner_category.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'package:jambar_pay_mobile/domain/use_cases/restaurants/filter_partners.dart';

void main() {
  test('legacy API responses and caches remain restaurants', () {
    for (final value in [null, '', '  ', 'RESTAURANT']) {
      expect(PartnerCategory.fromApi(value), PartnerCategory.restaurant);
    }
    expect(
      RestaurantDto.fromJson({'id': 'old'}).toDomain().category,
      PartnerCategory.restaurant,
    );
  });

  test('API categories reach the domain without changing payment metadata', () {
    for (final entry in {
      'RESTAURANT': PartnerCategory.restaurant,
      'SHOP': PartnerCategory.shop,
      'BOUTIQUE': PartnerCategory.shop,
      'SUPERMARKET': PartnerCategory.supermarket,
      'SUPERMARCHÉ': PartnerCategory.supermarket,
      'MARKET': PartnerCategory.market,
      'MARCHE': PartnerCategory.market,
    }.entries) {
      final partner = RestaurantDto.fromJson({
        'id': 'existing-id',
        'name': 'Partenaire',
        'partnerType': entry.key,
        'status': 'SUSPENDED',
        'isOpen': false,
        'latitude': 14.7,
        'longitude': -17.4,
      }).toDomain();
      expect(partner.category, entry.value);
      expect(partner.id, 'existing-id');
      expect(partner.status, 'SUSPENDED');
      expect(partner.isOpen, isFalse);
      expect(partner.latitude, 14.7);
    }
  });

  test('explicit unknown categories appear only in all partners', () {
    final partner = RestaurantDto.fromJson({
      'category': 'FUTURE_TYPE',
    }).toDomain();
    expect(partner.category, PartnerCategory.other);
    expect(filterPartners([partner]), [partner]);
    for (final category in PartnerCategory.selectable) {
      expect(filterPartners([partner], category: category), isEmpty);
    }
  });

  test('category and name/address search combine without mutating input', () {
    final partners = [
      _partner('Restaurant Dakar', PartnerCategory.restaurant, 'Plateau'),
      _partner('Boutique Awa', PartnerCategory.shop, 'Grand Yoff'),
      _partner('Super Dakar', PartnerCategory.supermarket, 'Plateau'),
      _partner('Marché local', PartnerCategory.market, 'Dakar'),
    ];
    expect(filterPartners(partners), partners);
    expect(filterPartners(partners, category: PartnerCategory.shop), [
      partners[1],
    ]);
    expect(filterPartners(partners, query: '  DAKAR  '), [
      partners[0],
      partners[2],
      partners[3],
    ]);
    expect(
      filterPartners(partners, category: PartnerCategory.shop, query: 'yoff'),
      [partners[1]],
    );
    expect(
      filterPartners(partners, category: PartnerCategory.shop, query: 'Dakar'),
      isEmpty,
    );
    expect(partners.length, 4);
  });
}

Restaurant _partner(String name, PartnerCategory category, String address) =>
    Restaurant(
      id: name,
      name: name,
      category: category,
      address: address,
      distanceKm: 0,
      updatedAt: DateTime(2026),
      isOpen: true,
      latitude: 0,
      longitude: 0,
    );
