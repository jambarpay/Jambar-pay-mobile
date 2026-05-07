import 'package:flutter/material.dart';

import '../widgets/app_palette.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/keypad_widgets.dart';

enum SecretCodeFlowMode { change, reset }

class SecretCodeScreen extends StatefulWidget {
  const SecretCodeScreen({
    super.key,
    required this.mode,
    required this.phoneNumber,
    this.isDarkMode = false,
    this.onChangePin,
    this.onResetPin,
  });

  final SecretCodeFlowMode mode;
  final String phoneNumber;
  final bool isDarkMode;
  final String? Function(String currentPin, String newPin)? onChangePin;
  final ValueChanged<String>? onResetPin;

  @override
  State<SecretCodeScreen> createState() => _SecretCodeScreenState();
}

class _SecretCodeScreenState extends State<SecretCodeScreen> {
  static const int _pinLength = 4;

  int _stepIndex = 0;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  String? _errorMessage;

  bool get _isChangeMode => widget.mode == SecretCodeFlowMode.change;

  int get _totalSteps => _isChangeMode ? 3 : 2;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);
    final bodyTextColor = widget.isDarkMode
        ? palette.primaryText
        : const Color(0xFF1C1A33);
    final hintTextColor = widget.isDarkMode
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
                            backgroundColor: widget.isDarkMode
                                ? palette.sectionContainer
                                : Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.of(context).pop(),
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
                                      'Retour',
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
                                        ? 'Modifier le code secret'
                                        : 'Reinitialiser le code secret',
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
                                        ? 'Definissez votre nouveau code secret.'
                                        : 'Compte $widget.phoneNumber',
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
                                  isChangeMode: _isChangeMode,
                                  isDarkMode: widget.isDarkMode,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: PinDots(length: _activePinValue.length),
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
                                SizedBox(
                                  height: keypadHeight.toDouble(),
                                  child: NumericKeypad(
                                    onDigitTap: _onDigitTap,
                                    onBackspace: _onBackspace,
                                    foregroundColor: bodyTextColor,
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

  String get _activePinValue => switch (_stepIndex) {
    0 => _isChangeMode ? _currentPin : _newPin,
    1 => _isChangeMode ? _newPin : _confirmPin,
    _ => _confirmPin,
  };

  void _setActivePinValue(String value) {
    switch (_stepIndex) {
      case 0:
        if (_isChangeMode) {
          _currentPin = value;
        } else {
          _newPin = value;
        }
        break;
      case 1:
        if (_isChangeMode) {
          _newPin = value;
        } else {
          _confirmPin = value;
        }
        break;
      case 2:
        _confirmPin = value;
        break;
    }
  }

  void _onDigitTap(String digit) {
    if (_activePinValue.length >= _pinLength) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _setActivePinValue('$_activePinValue$digit');
    });

    if (_activePinValue.length != _pinLength) {
      return;
    }

    if (_stepIndex < _totalSteps - 1) {
      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    _submit();
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

  void _submit() {
    final newPin = _newPin;
    final confirmPin = _confirmPin;

    if (newPin != confirmPin) {
      setState(() {
        _errorMessage = 'Les deux codes ne correspondent pas.';
        _confirmPin = '';
        _stepIndex = _totalSteps - 1;
      });
      return;
    }

    if (_isChangeMode) {
      final error = widget.onChangePin?.call(_currentPin, newPin);
      if (error != null) {
        setState(() {
          _errorMessage = error;
          _currentPin = '';
          _newPin = '';
          _confirmPin = '';
          _stepIndex = 0;
        });
        return;
      }
    } else {
      widget.onResetPin?.call(newPin);
    }

    Navigator.of(context).pop(true);
  }

  String _stepTitle() {
    if (_isChangeMode) {
      return switch (_stepIndex) {
        0 => 'Code secret actuel',
        1 => 'Nouveau code secret',
        _ => 'Confirmation',
      };
    }

    return _stepIndex == 0 ? 'Nouveau code secret' : 'Confirmez le code';
  }

  String _stepDescription() {
    if (_isChangeMode) {
      return switch (_stepIndex) {
        0 => 'Entrez votre code actuel pour continuer.',
        1 => 'Choisissez un code secret a 4 chiffres.',
        _ => 'Saisissez a nouveau le nouveau code secret.',
      };
    }

    return _stepIndex == 0
        ? 'Choisissez votre nouveau code secret a 4 chiffres.'
        : 'Saisissez a nouveau le code secret pour valider.';
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.isChangeMode,
    this.isDarkMode = false,
  });

  final int currentStep;
  final int totalSteps;
  final bool isChangeMode;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final labels = isChangeMode
        ? const ['Actuel', 'Nouveau', 'Confirmation']
        : const ['Nouveau', 'Confirmation'];

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
                  duration: const Duration(milliseconds: 180),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isComplete || isActive
                        ? palette.accent
                        : (isDarkMode
                              ? const Color(0xFF353152)
                              : const Color(0xFFE2DFEA)),
                    borderRadius: BorderRadius.circular(999),
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
                              : const Color(0xFF1C1A33))
                        : (isDarkMode
                              ? palette.secondaryText
                              : const Color(0xFF8A8898)),
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
