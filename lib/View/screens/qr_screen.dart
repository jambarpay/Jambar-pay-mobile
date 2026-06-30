import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import '../models/mobile_employee_space.dart';
import 'payment_simulation_screen.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/qr_widgets.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({
    super.key,
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
  int _qrAttemptCount = 0;
  DateTime? _qrLockoutEnd;
  String? _qrErrorMessage;

  bool get _isQrLockedOut {
    return _qrLockoutEnd != null && DateTime.now().isBefore(_qrLockoutEnd!);
  }

  String get _qrLockoutRemaining {
    if (_qrLockoutEnd == null) return '00:00';
    final remaining = _qrLockoutEnd!.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  void _clearQrError() {
    _qrErrorMessage = null;
  }

  @override
  void initState() {
    super.initState();
    _scanResult = widget.paymentState.scanResult;
    _paymentResult = widget.paymentState.currentPayment;
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      torchEnabled: false,
      autoStart: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _setScannerMode(bool value) async {
    if (value && _isQrLockedOut) {
      setState(() {
        _qrErrorMessage = AppLocalizations.of(context).retryIn(_qrLockoutRemaining);
      });
      return;
    }

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
        } catch (_) {
          // Ignore start errors (already starting/started)
        }
      });
      return;
    }

    try {
      await _scannerController.stop();
    } catch (_) {
      // Ignore stop errors
    }
  }

  void _selectBottomTab(int index) {
    try {
      _scannerController.stop();
    } catch (_) {}
    widget.onTabSelected(index);
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);

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
                    onPressed: () => Navigator.of(context).pop(),
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
                          duration: const Duration(milliseconds: 220),
                          child: _showScanner
                              ? ScannerPreview(
                                  key: const ValueKey('scanner-view'),
                                  isDarkMode: widget.isDarkMode,
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
                                    _openPaymentFlow(value);
                                  },
                                )
                              : LargeQrCard(
                                  key: ValueKey('my-qr-view'),
                                  isDarkMode: false,
                                  userProfile: widget.userProfile,
                                  scanResult: _scanResult,
                                ),
                        ),
                      ),
                    ),
                    if (_showScanner) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _openPaymentFlow('1234'),
                        icon: Icon(
                          Icons.flash_on_outlined,
                          size: 16,
                          color: widget.isDarkMode ? palette.primaryText : palette.mutedText,
                        ),
                        label: Text(
                          AppLocalizations.of(context).testQr,
                          style: TextStyle(
                            color: widget.isDarkMode ? palette.primaryText : palette.mutedText,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: palette.accent.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                        userProfile: widget.userProfile,
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
                        isDarkMode: widget.isDarkMode,
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
        isDarkMode: widget.isDarkMode,
      ),
    );
  }

  Future<void> _openPaymentFlow(String rawValue) async {
    if (_isOpeningPayment) {
      return;
    }

    if (_isQrLockedOut) {
      setState(() {
        _qrErrorMessage = AppLocalizations.of(context).retryIn(_qrLockoutRemaining);
      });
      return;
    }

    final code = rawValue.trim();
    if (code != '1234') {
      if (_lastScannedValue != code) {
        _qrAttemptCount += 1;
      }

      if (_qrAttemptCount >= 5) {
        _qrLockoutEnd = DateTime.now().add(const Duration(minutes: 5));
        setState(() {
          _qrErrorMessage = AppLocalizations.of(context).retryIn('05:00');
          _lastScannedValue = code;
        });
      } else {
        final remaining = 5 - _qrAttemptCount;
        setState(() {
          _qrErrorMessage = AppLocalizations.of(context).invalidQrCode + ' ${AppLocalizations.of(context).retryIn('$remaining')}';
          _lastScannedValue = code;
        });
      }
      return;
    }

    _qrErrorMessage = null;
    _qrAttemptCount = 0;
    _qrLockoutEnd = null;
    _isOpeningPayment = true;
    final navigator = Navigator.of(context);
    try {
      await _scannerController.stop();
    } catch (_) {
      // ignore stop errors
    }

    final result = await navigator.push<PaymentSimulationResult>(
      MaterialPageRoute(
        builder: (context) => PaymentSimulationScreen(
          isDarkMode: widget.isDarkMode,
          qrToken: rawValue,
          merchantName: _merchantNameFromScan(rawValue, context),
          availableBalance: widget.wallet?.balance,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    _isOpeningPayment = false;

    if (result != null) {
      widget.onPaymentCompleted(result.scanResult, result.paymentResult);
      setState(() {
        _showScanner = false;
        _scanResult = result.scanResult;
        _paymentResult = result.paymentResult;
        _lastScannedValue = result.scanResult.token;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).paymentSuccessMessage(result.scanResult.merchantName),
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
