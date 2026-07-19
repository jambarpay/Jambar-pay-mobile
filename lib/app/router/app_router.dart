import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../View/main.dart' show JambarPayFlow;
import '../../View/models/mobile_employee_space.dart';
import '../../View/screens/payment_simulation_screen.dart';
import '../../View/screens/qr_screen.dart';
import '../../View/screens/secret_code_screen.dart';

abstract final class AppRoutes {
  static const root = '/';
  static const qr = '/qr';
  static const payment = '/payment';
  static const secretCode = '/secret-code';
}

class QrRouteArgs {
  const QrRouteArgs({
    required this.onTabSelected,
    required this.isDarkMode,
    required this.userProfile,
    required this.paymentState,
    required this.wallet,
    required this.onPaymentCompleted,
  });

  final ValueChanged<int> onTabSelected;
  final bool isDarkMode;
  final UserProfileModel userProfile;
  final PaymentUIState paymentState;
  final WalletSummaryModel? wallet;
  final void Function(QRScanResultModel, PaymentResultModel) onPaymentCompleted;
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

class SecretCodeRouteArgs {
  const SecretCodeRouteArgs({
    required this.mode,
    required this.phoneNumber,
    this.isDarkMode = false,
    this.onChangePin,
    this.onResetPin,
  });

  final SecretCodeFlowMode mode;
  final String phoneNumber;
  final bool isDarkMode;
  final Future<String?> Function(String currentPin, String newPin)? onChangePin;
  final Future<String?> Function(String newPin)? onResetPin;
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
        builder: (context, state) {
          final args = state.extra! as QrRouteArgs;
          return QrScreen(
            onTabSelected: args.onTabSelected,
            isDarkMode: args.isDarkMode,
            userProfile: args.userProfile,
            paymentState: args.paymentState,
            wallet: args.wallet,
            onPaymentCompleted: args.onPaymentCompleted,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final args = state.extra! as PaymentRouteArgs;
          return PaymentSimulationScreen(
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
          final args = state.extra! as SecretCodeRouteArgs;
          return SecretCodeScreen(
            mode: args.mode,
            phoneNumber: args.phoneNumber,
            isDarkMode: args.isDarkMode,
            onChangePin: args.onChangePin,
            onResetPin: args.onResetPin,
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
}
