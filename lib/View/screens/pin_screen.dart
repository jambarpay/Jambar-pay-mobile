import 'dart:async';

import 'package:flutter/material.dart';
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
    required this.onResetPin,
    this.errorText,
    this.pinLockedUntil,
  });

  final String pin;
  final String phoneNumber;
  final VoidCallback onBack;
  final VoidCallback onBackspace;
  final ValueChanged<String> onDigitTap;
  final ValueChanged<String> onResetPin;
  final String? errorText;
  final DateTime? pinLockedUntil;

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
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackdrop(
            backgroundAsset: 'assets/images/Bglogin.png',
            topSectionHeight: 290,
          ),
          SafeArea(
            child: Column(
              children: [
                const BrandHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final keypadHeight = (constraints.maxHeight * 0.38).clamp(
                        220.0,
                        300.0,
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: AuthCard(
                            topMargin: 54,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: widget.onBack,
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        size: 22,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppLocalizations.of(context).back,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 34),
                                Center(
                                  child: Text(
                                    AppLocalizations.of(context).pinCode,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  AppLocalizations.of(context).enterYourPinCode,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Center(
                                  child: PinDots(length: widget.pin.length),
                                ),
                                if (widget.errorText != null) ...[
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      widget.errorText!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isLocked) ...[
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1E6),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${AppLocalizations.of(context).retryIn('$countdownLabel')}',
                                        style: const TextStyle(
                                          color: Color(0xFFF57C21),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 28),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: isLocked ? 0.45 : 1,
                                  child: IgnorePointer(
                                    ignoring: isLocked,
                                    child: SizedBox(
                                      height: keypadHeight.toDouble(),
                                      child: NumericKeypad(
                                        onDigitTap: widget.onDigitTap,
                                        onBackspace: widget.onBackspace,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      final didReset =
                                          await Navigator.of(
                                            context,
                                          ).push<bool>(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SecretCodeScreen(
                                                    mode: SecretCodeFlowMode
                                                        .reset,
                                                    phoneNumber:
                                                        widget.phoneNumber,
                                                    isDarkMode: false,
                                                    onResetPin:
                                                        widget.onResetPin,
                                                  ),
                                            ),
                                          );

                                      if (didReset == true && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context).secretCodeResetSuccess,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).forgotPin,
                                      style: const TextStyle(
                                        color: Color(0xFFF57C21),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
