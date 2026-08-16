import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_service.dart';
import '../../core/network/base_url.dart';

class KkiapayCheckoutService {
  KkiapayCheckoutService(this._apiService);

  static const _callbackScheme = 'jambaarpay';
  static const _callbackHost = 'payment';

  final ApiService _apiService;
  final AppLinks _appLinks = AppLinks();

  Future<String> startCheckout({
    required int amount,
    String? name,
    String? phone,
  }) async {
    final response = await _apiService.post(BaseUrl.waveCheckoutLinks(), {
      'amount': amount,
      'callbackUrl': '$_callbackScheme://$_callbackHost/callback',
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'paymentMethod': 'momo',
    });

    if (response is! Map || response['paymentUrl'] is! String) {
      throw const ApiException('Lien de paiement Kkiapay indisponible.');
    }

    final paymentUrl = Uri.tryParse(response['paymentUrl'] as String);
    if (paymentUrl == null || !paymentUrl.hasScheme) {
      throw const ApiException('Lien de paiement Kkiapay invalide.');
    }

    final completion = Completer<String>();
    final subscription = _appLinks.uriLinkStream.listen((uri) {
      final transactionId = _transactionIdFrom(uri);
      if (transactionId != null && !completion.isCompleted) {
        completion.complete(transactionId);
      }
    });

    try {
      final launched = await launchUrl(
        paymentUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const ApiException('Impossible d’ouvrir le paiement Kkiapay.');
      }

      return await completion.future.timeout(
        const Duration(minutes: 30),
        onTimeout: () => throw const ApiException(
          'Le paiement Kkiapay n’a pas été confirmé.',
        ),
      );
    } finally {
      await subscription.cancel();
    }
  }

  String? _transactionIdFrom(Uri uri) {
    if (uri.scheme != _callbackScheme || uri.host != _callbackHost) {
      return null;
    }
    if (uri.queryParameters['status']?.toLowerCase() != 'success') {
      return null;
    }
    final transactionId = uri.queryParameters['transactionId'];
    return transactionId == null || transactionId.trim().isEmpty
        ? null
        : transactionId.trim();
  }
}
