import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_durations.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';

import '../widgets/app_palette.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/keypad_widgets.dart';

enum SecretCodeFlowMode { change, reset }

class SecretCodeScreen extends StatefulWidget {
  const SecretCodeScreen({
    super.key,
    required this.mode,
    required this.phoneNumber,
  });

  final SecretCodeFlowMode mode;
  final String phoneNumber;

  @override
  State<SecretCodeScreen> createState() => _SecretCodeScreenState();
}

class _SecretCodeScreenState extends State<SecretCodeScreen> {
  static const int _pinLength = 4;

  int _stepIndex = 0;
  String _verificationCode = '';
  String _newPin = '';
  String _confirmPin = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  bool get _isChangeMode => widget.mode == SecretCodeFlowMode.change;

  int get _totalSteps => 3;

  int get _activePinLength => _stepIndex == 0 ? 6 : _pinLength;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_sendVerificationCode());
      });
    }
  }

  Future<void> _sendVerificationCode() async {
    try {
      await context.read<AuthBloc>().requestOtpForPinReset(widget.phoneNumber);
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette(isDarkMode);
    final bodyTextColor = isDarkMode
        ? palette.primaryText
        : AppColors.lightPrimaryText;
    final hintTextColor = isDarkMode
        ? palette.secondaryText
        : Colors.black.withValues(alpha: 0.55);
    final stepTitle = _stepTitle();
    final stepDescription = _stepDescription();

    return Scaffold(
      backgroundColor: palette.pageBackground,
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
                      final keypadHeight = (constraints.maxHeight * 0.34).clamp(
                        210.0,
                        280.0,
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: AuthCard(
                            topMargin: 54,
                            backgroundColor: isDarkMode
                                ? palette.sectionContainer
                                : Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: Icon(
                                        Icons.arrow_back,
                                        size: 22,
                                        color: bodyTextColor,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppLocalizations.of(context).back,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: hintTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Center(
                                  child: Text(
                                    _isChangeMode
                                        ? AppLocalizations.of(
                                            context,
                                          ).changeSecretCode
                                        : AppLocalizations.of(
                                            context,
                                          ).resetSecretCode,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: bodyTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    widget.phoneNumber.isEmpty
                                        ? AppLocalizations.of(
                                            context,
                                          ).setYourNewSecretCode
                                        : AppLocalizations.of(
                                            context,
                                          ).accountForPhone(widget.phoneNumber),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: hintTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Text(
                                  stepTitle,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: bodyTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stepDescription,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: hintTextColor,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                _StepProgress(
                                  currentStep: _stepIndex,
                                  totalSteps: _totalSteps,
                                  isDarkMode: isDarkMode,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: PinDots(
                                    length: _activePinValue.length,
                                    total: _activePinLength,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                IgnorePointer(
                                  ignoring: _isSubmitting,
                                  child: AnimatedOpacity(
                                    duration: AppDurations.fast,
                                    opacity: _isSubmitting ? 0.45 : 1,
                                    child: SizedBox(
                                      height: keypadHeight.toDouble(),
                                      child: NumericKeypad(
                                        onDigitTap: _onDigitTap,
                                        onBackspace: _onBackspace,
                                        foregroundColor: bodyTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isSubmitting)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
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

  String get _activePinValue {
    return switch (_stepIndex) {
      0 => _verificationCode,
      1 => _newPin,
      _ => _confirmPin,
    };
  }

  void _setActivePinValue(String value) {
    switch (_stepIndex) {
      case 0:
        _verificationCode = value;
      case 1:
        _newPin = value;
      case 2:
        _confirmPin = value;
    }
  }

  void _onDigitTap(String digit) {
    if (_activePinValue.length >= _activePinLength) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _setActivePinValue('$_activePinValue$digit');
    });

    if (_activePinValue.length != _activePinLength) {
      return;
    }

    if (_stepIndex < _totalSteps - 1) {
      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    unawaited(_submit());
  }

  void _onBackspace() {
    if (_activePinValue.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _setActivePinValue(
          _activePinValue.substring(0, _activePinValue.length - 1),
        );
      });
      return;
    }

    if (_stepIndex == 0) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _stepIndex -= 1;
      _setActivePinValue(
        _activePinValue.substring(0, _activePinValue.length - 1),
      );
    });
  }

  Future<void> _submit() async {
    final newPin = _newPin;
    final confirmPin = _confirmPin;

    if (newPin != confirmPin) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).codeMismatch;
        _confirmPin = '';
        _stepIndex = _totalSteps - 1;
      });
      return;
    }

    setState(() => _isSubmitting = true);

    String? error;
    try {
      final bloc = context.read<AuthBloc>();
      bloc.add(
        PinResetRequested(
          phoneNumber: widget.phoneNumber,
          verificationCode: _verificationCode,
          newPin: newPin,
        ),
      );
      final result = await bloc.stream.firstWhere(
        (state) => state is AuthPinResetSuccess || state is AuthFailure,
      );
      if (result is AuthFailure) {
        error = result.errorMessage;
      }
    } catch (exception) {
      error = exception.toString();
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = error;
        _verificationCode = '';
        _newPin = '';
        _confirmPin = '';
        _stepIndex = 0;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  String _stepTitle() {
    final loc = AppLocalizations.of(context);
    if (_isChangeMode) {
      return switch (_stepIndex) {
        0 => loc.verificationCode,
        1 => loc.newSecretCode,
        _ => loc.confirmation,
      };
    }

    return switch (_stepIndex) {
      0 => loc.verificationCode,
      1 => loc.newSecretCode,
      _ => loc.confirmCode,
    };
  }

  String _stepDescription() {
    final loc = AppLocalizations.of(context);
    if (_isChangeMode) {
      return switch (_stepIndex) {
        0 => loc.enterVerificationCode,
        1 => loc.chooseNewSecretCode,
        _ => loc.enterNewSecretCodeAgain,
      };
    }

    return switch (_stepIndex) {
      0 => loc.enterVerificationCode,
      1 => loc.setYourNewSecretCode,
      _ => loc.enterCodeAgain,
    };
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
    this.isDarkMode = false,
  });

  final int currentStep;
  final int totalSteps;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);
    final labels = [
      loc.verificationCodeShort,
      loc.newLabel,
      loc.confirmationShort,
    ];

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isComplete = index < currentStep;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isComplete || isActive
                        ? palette.accent
                        : (isDarkMode
                              ? AppColors.darkProgress
                              : AppColors.lightProgress),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? (isDarkMode
                              ? palette.primaryText
                              : AppColors.lightPrimaryText)
                        : (isDarkMode
                              ? palette.secondaryText
                              : AppColors.lightMutedText),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
