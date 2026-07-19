import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/jambar_pay_app.dart' show JambarPayFlow;
import '../../presentation/models/mobile_employee_space.dart';
import '../../presentation/screens/payment_screen.dart';
import '../../presentation/screens/qr_screen.dart';
import '../../presentation/screens/secret_code_screen.dart';

abstract final class AppRoutes {
  static const root = '/';
  static const qr = '/qr';
  static const payment = '/payment';
  static const secretCode = '/secret-code';

  static String secretCodeLocation({
    required SecretCodeFlowMode mode,
    required String phoneNumber,
  }) => Uri(
    path: secretCode,
    queryParameters: {
      'mode': mode.name,
      if (phoneNumber.isNotEmpty) 'phone': phoneNumber,
    },
  ).toString();
}

class PaymentRouteArgs {
  const PaymentRouteArgs({
    required this.isDarkMode,
    required this.qrToken,
    required this.merchantName,
    this.availableBalance,
  });

  final bool isDarkMode;
  final String qrToken;
  final String merchantName;
  final MoneyModel? availableBalance;
}

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.root,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const JambarPayFlow(),
      ),
      GoRoute(
        path: AppRoutes.qr,
        builder: (context, state) => const QrScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final args = state.extra;
          if (args is! PaymentRouteArgs) {
            return const _InvalidRouteScreen();
          }
          return PaymentScreen(
            isDarkMode: args.isDarkMode,
            qrToken: args.qrToken,
            merchantName: args.merchantName,
            availableBalance: args.availableBalance,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.secretCode,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] == 'reset'
              ? SecretCodeFlowMode.reset
              : SecretCodeFlowMode.change;
          return SecretCodeScreen(
            mode: mode,
            phoneNumber: state.uri.queryParameters['phone'] ?? '',
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Navigation impossible.')),
    );
  }
}
