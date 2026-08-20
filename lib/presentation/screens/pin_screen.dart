import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'secret_code_screen.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/keypad_widgets.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({
    super.key,
    required this.pin,
    required this.phoneNumber,
    required this.onBack,
    required this.onBackspace,
    required this.onDigitTap,
    this.errorText,
    this.pinLockedUntil,
    // A PinScreen represents a PIN by default. OTP screens explicitly pass
    // six digits from the authentication flow.
    this.totalDigits = 4,
    this.title,
    this.subtitle,
    this.isSubmitting = false,
  });

  final String pin;
  final String phoneNumber;
  final VoidCallback onBack;
  final VoidCallback onBackspace;
  final ValueChanged<String> onDigitTap;
  final String? errorText;
  final DateTime? pinLockedUntil;
  final int totalDigits;
  final String? title;
  final String? subtitle;
  final bool isSubmitting;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  Timer? _countdownTimer;
  Duration _remainingLockDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _syncLockCountdown();
  }

  @override
  void didUpdateWidget(covariant PinScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pinLockedUntil != widget.pinLockedUntil) {
      _syncLockCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _syncLockCountdown() {
    _countdownTimer?.cancel();
    _updateRemainingLockDuration();

    if (!isLocked) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingLockDuration();
      if (!isLocked) {
        _countdownTimer?.cancel();
      }
    });
  }

  void _updateRemainingLockDuration() {
    final lockUntil = widget.pinLockedUntil;
    final remaining = lockUntil == null
        ? Duration.zero
        : lockUntil.difference(DateTime.now());

    if (!mounted) {
      return;
    }

    setState(() {
      _remainingLockDuration = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  bool get isLocked => _remainingLockDuration > Duration.zero;

  String get countdownLabel {
    final totalSeconds = _remainingLockDuration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final paddedSeconds = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isUnlockFlow = widget.title == null || widget.title == loc.pinCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? AppColors.darkBackground : Colors.white;
    final foreground = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isHighDensityPhone =
                MediaQuery.of(context).devicePixelRatio > 1.5;
            final keypadTopSpacing = isHighDensityPhone
                ? (widget.errorText != null || isLocked
                      ? 60.0
                      : (constraints.maxHeight * 0.15).clamp(120.0, 150.0))
                : constraints.maxHeight < 1000
                ? 24.0
                : (constraints.maxHeight * 0.1).clamp(80.0, 110.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 34,
                ),
                child: Column(
                  children: [
                    if (!isUnlockFlow)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: widget.onBack,
                          icon: Icon(Icons.arrow_back, color: foreground),
                          tooltip: loc.back,
                        ),
                      ),
                    if (!isUnlockFlow) const SizedBox(height: 4),
                    Image.asset(
                      'assets/images/IconeAppli.png',
                      width: 150,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 34),
                    if (isUnlockFlow)
                      Text(
                        loc.pinCode,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .7,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      isUnlockFlow
                          ? 'Votre code secret est requis pour déverrouiller'
                          : (widget.title ?? loc.pinCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foreground,
                        fontSize: isUnlockFlow ? 25 : 23,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isUnlockFlow
                          ? 'Saisissez votre code secret à 4 chiffres'
                          : (widget.subtitle ?? loc.enterYourPinCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 26),
                    PinDots(
                      length: widget.pin.length,
                      total: widget.totalDigits,
                      emptyColor: isDarkMode
                          ? AppColors.darkBorder
                          : const Color(0xFFFFB493),
                      filledColor: isDarkMode
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                      showEmptyBorder: false,
                    ),
                    if (widget.errorText != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        widget.errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (isLocked) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandSurfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          loc.retryIn(countdownLabel),
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: keypadTopSpacing),
                    if (widget.isSubmitting)
                      SizedBox(
                        height: 286,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: isDarkMode
                                    ? AppColors.darkPrimaryText
                                    : AppColors.brand,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connexion en cours…',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 286,
                        child: NumericKeypad(
                          key: ValueKey(
                            'pin-keypad-container-${widget.totalDigits}',
                          ),
                          onDigitTap: _onKeypadDigit,
                          onBackspace: _onKeypadBackspace,
                          keyPrefix: 'pin-keypad',
                          leadingLabel: isUnlockFlow ? 'OUBLIÉ ?' : null,
                          onLeadingTap: isUnlockFlow
                              ? () => unawaited(_openReset(context))
                              : null,
                          foregroundColor: foreground,
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onKeypadDigit(String digit) {
    if (isLocked || widget.isSubmitting || widget.pin.length >= widget.totalDigits) {
      return;
    }
    widget.onDigitTap(digit);
  }

  void _onKeypadBackspace() {
    if (isLocked || widget.isSubmitting) return;
    widget.onBackspace();
  }

  Future<void> _openReset(BuildContext context) async {
    final didReset = await context.push<bool>(
      AppRoutes.secretCodeLocation(
        mode: SecretCodeFlowMode.reset,
        // A forgotten PIN must verify the phone again before sending the
        // WhatsApp OTP. Do not silently reuse the remembered phone here.
        phoneNumber: '',
      ),
    );

    if (didReset == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).secretCodeResetSuccess),
        ),
      );
    }
  }
}
