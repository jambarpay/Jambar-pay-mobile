import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_durations.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_state.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/qr_remote_datasource.dart';
import 'package:jambar_pay_mobile/injection.dart' as di;
import '../models/mobile_employee_space.dart';
import 'payment_screen.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/qr_widgets.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool _showScanner = false;
  late final MobileScannerController _scannerController;
  String? _lastScannedValue;
  bool _isOpeningPayment = false;
  late QRScanResultModel? _scanResult;
  late PaymentResultModel? _paymentResult;
  String? _qrErrorMessage;
  String? _employeeQrContent;
  final QrRemoteDataSource _qrDataSource = di.sl<QrRemoteDataSource>();

  void _clearQrError() {
    _qrErrorMessage = null;
  }

  @override
  void initState() {
    super.initState();
    _scanResult = null;
    _paymentResult = null;
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      torchEnabled: false,
      autoStart: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEmployeeQr());
  }

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  Future<void> _setScannerMode(bool value) async {
    setState(() {
      _showScanner = value;
      _lastScannedValue = value ? _lastScannedValue : null;
      if (value) {
        _clearQrError();
      }
    });

    if (value) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _scannerController.start();
        } catch (error) {
          _showScannerError(error);
        }
      });
      return;
    }

    await _stopScanner();
  }

  Future<void> _selectBottomTab(int index) async {
    await _stopScanner();
    if (!mounted) return;
    context.pop(index);
  }

  Future<void> _stopScanner() async {
    try {
      await _scannerController.stop();
    } catch (error) {
      _showScannerError(error);
    }
  }

  void _showScannerError(Object error) {
    if (!mounted) return;
    setState(() {
      _qrErrorMessage = AppLocalizations.of(context).cameraUnavailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette(isDarkMode);
    final authState = context.watch<AuthBloc>().state;
    final userProfile = authState is AuthAuthenticated
        ? UserProfileModel(
            id: authState.user.id,
            name: authState.user.name,
            phone: authState.user.phone.value,
            avatarUrl: authState.user.avatarUrl,
          )
        : const UserProfileModel(id: '', name: 'Jambar Pay', phone: '');

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: context.pop,
                    icon: Icon(Icons.arrow_back, color: palette.primaryText),
                  ),
                  Text(
                    AppLocalizations.of(context).back,
                    style: TextStyle(
                      color: palette.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: AppDurations.standard,
                          child: _showScanner
                              ? ScannerPreview(
                                  key: const ValueKey('scanner-view'),
                                  isDarkMode: isDarkMode,
                                  controller: _scannerController,
                                  lastScannedValue: _lastScannedValue,
                                  onDetect: (value) {
                                    if (value == null || value.isEmpty) {
                                      return;
                                    }

                                    if (_lastScannedValue == value) {
                                      return;
                                    }

                                    setState(() {
                                      _lastScannedValue = value;
                                    });
                                    unawaited(_openPaymentFlow(value));
                                  },
                                )
                              : LargeQrCard(
                                  key: ValueKey('my-qr-view'),
                                  isDarkMode: false,
                                  userProfile: userProfile,
                                  scanResult: _scanResult,
                                  employeeQrContent: _employeeQrContent,
                                ),
                        ),
                      ),
                    ),
                    if (_showScanner) ...[
                      const SizedBox(height: 16),
                      if (_qrErrorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _qrErrorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 18),
                    if (!_showScanner)
                      QrDetailsCard(
                        userProfile: userProfile,
                        scanResult: _scanResult,
                        paymentResult: _paymentResult,
                      ),
                    if (!_showScanner) const SizedBox(height: 18),
                    if (!_showScanner)
                      TogglePill(
                        leftLabel: AppLocalizations.of(context).scan,
                        rightLabel: AppLocalizations.of(context).myQr,
                        isLeftSelected: _showScanner,
                        onLeftTap: () => _setScannerMode(true),
                        onRightTap: () => _setScannerMode(false),
                        isDarkMode: isDarkMode,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 0,
        onTap: _selectBottomTab,
        isDarkMode: isDarkMode,
      ),
    );
  }

  Future<void> _loadEmployeeQr() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.id.isEmpty) return;

    try {
      final response = await _qrDataSource.generateEmployeeQr(
        authState.user.id,
      );
      if (!mounted) return;
      setState(() {
        _employeeQrContent = response['qrContent']?.toString();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _qrErrorMessage = AppLocalizations.of(context).invalidQrCode;
      });
    }
  }

  Future<void> _openPaymentFlow(String rawValue) async {
    if (_isOpeningPayment) {
      return;
    }

    final code = rawValue.trim();
    if (code.isEmpty) {
      return;
    }

    _qrErrorMessage = null;
    _isOpeningPayment = true;
    final merchantName = _merchantNameFromScan(code, context);
    try {
      await _scannerController.stop();
    } catch (_) {
      // ignore stop errors
    }
    if (!mounted) return;

    final result = await context.push<PaymentFlowResult>(
      AppRoutes.payment,
      extra: PaymentRouteArgs(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        qrToken: code,
        merchantName: merchantName,
        availableBalance: _availableBalance(context),
      ),
    );

    if (!mounted) {
      return;
    }

    _isOpeningPayment = false;

    if (result != null) {
      context.read<TransactionBloc>().add(
        LocalTransactionRegistered(result.transaction),
      );
      context.read<WalletBloc>().add(
        WalletDebitApplied(result.transaction.amount),
      );
      setState(() {
        _showScanner = false;
        _scanResult = result.scanResult;
        _paymentResult = result.paymentResult;
        _lastScannedValue = result.scanResult.token;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).paymentSuccessMessage(result.scanResult.merchantName),
          ),
        ),
      );
      return;
    }

    if (_showScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _scannerController.start();
        } catch (_) {
          // ignore start errors
        }
      });
    }
  }

  MoneyModel? _availableBalance(BuildContext context) {
    final state = context.read<WalletBloc>().state;
    if (state is! WalletLoaded) return null;
    return MoneyModel(
      amount: state.wallet.balance.amount.toDouble(),
      currency: state.wallet.balance.currency,
      formatted: state.wallet.balance.formatted,
      symbol: 'F',
    );
  }

  String _merchantNameFromScan(String rawValue, BuildContext context) {
    final normalized = rawValue.toLowerCase();

    if (normalized.contains('food')) {
      return 'Le FOOD';
    }
    if (normalized.contains('delice')) {
      return 'Keur Delice';
    }
    if (normalized.contains('binta')) {
      return 'Chez Binta';
    }
    if (normalized.contains('cafe')) {
      return 'Express Cafe';
    }

    return AppLocalizations.of(context).partnerRestaurant;
  }
}
