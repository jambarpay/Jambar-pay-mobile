import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';

import '../widgets/keypad_widgets.dart';

enum SecretCodeFlowMode { change, reset }

class SecretCodeScreen extends StatelessWidget {
  const SecretCodeScreen({
    super.key,
    required this.mode,
    required this.phoneNumber,
  });

  final SecretCodeFlowMode mode;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    // The change flow always confirms the phone number again. The forgot-PIN
    // flow already has it from the login screen and starts with the OTP.
    if (mode == SecretCodeFlowMode.reset && phoneNumber.isNotEmpty) {
      return _OtpStep(
        mode: mode,
        phoneNumber: PhoneNumber(phoneNumber).digits,
        sendOnOpen: true,
      );
    }

    return _PhoneStep(mode: mode);
  }
}

class _PhoneStep extends StatefulWidget {
  const _PhoneStep({required this.mode});

  final SecretCodeFlowMode mode;

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  String _phone = '';
  String? _errorMessage;
  bool _isSending = false;

  bool get _canContinue => PhoneNumber(_phone).isValid && !_isSending;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return _FlowFrame(
      title: loc.yourNumber,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.phoneOtpDescription, style: _bodyTextStyle(context)),
          const SizedBox(height: 28),
          _PhoneInput(value: _phone),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            _ErrorText(_errorMessage!),
          ],
          const SizedBox(height: 22),
          _PrimaryButton(
            label: loc.receiveCode,
            onPressed: _canContinue ? () => unawaited(_sendOtp()) : null,
            isLoading: _isSending,
          ),
          const SizedBox(height: 12),
          _WhatsAppNote(text: loc.whatsappCodeNote),
          const SizedBox(height: 42),
          SizedBox(
            height: 286,
            child: NumericKeypad(
              onDigitTap: _onDigitTap,
              onBackspace: _onBackspace,
              foregroundColor: AppColors.lightPrimaryText,
              buttonBackgroundColor: AppColors.lightSurface,
              buttonBorderColor: AppColors.lightBorder,
            ),
          ),
        ],
      ),
    );
  }

  void _onDigitTap(String digit) {
    if (_phone.length >= 9 || _isSending) return;
    setState(() {
      _errorMessage = null;
      _phone += digit;
    });
  }

  void _onBackspace() {
    if (_phone.isEmpty || _isSending) return;
    setState(() {
      _errorMessage = null;
      _phone = _phone.substring(0, _phone.length - 1);
    });
  }

  Future<void> _sendOtp() async {
    if (!_canContinue) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthBloc>().requestOtpForPinReset(_phone);
      if (!mounted) return;
      final completed = await Navigator.of(context).push<bool>(
        _flowRoute<bool>(
          context,
          _OtpStep(mode: widget.mode, phoneNumber: _phone),
        ),
      );
      if (completed == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep({
    required this.mode,
    required this.phoneNumber,
    this.sendOnOpen = false,
  });

  final SecretCodeFlowMode mode;
  final String phoneNumber;
  final bool sendOnOpen;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  String _otp = '';
  String? _errorMessage;
  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.sendOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_sendOtp());
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final formattedPhone = PhoneNumber(widget.phoneNumber).formatted;
    final keypadForeground = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return _FlowFrame(
      title: loc.whatsappCode,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.otpSentTo(formattedPhone), style: _bodyTextStyle(context)),
          const SizedBox(height: 34),
          Semantics(
            label: loc.whatsappCode,
            button: true,
            child: _CodeBoxes(value: _otp, total: 6),
          ),
          const SizedBox(height: 58),
          SizedBox(
            height: 286,
            child: NumericKeypad(
              key: const ValueKey('secret-otp-keypad'),
              onDigitTap: _onOtpDigit,
              onBackspace: _onOtpBackspace,
              foregroundColor: keypadForeground,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorText(_errorMessage!),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: loc.verifyCode,
            onPressed: _otp.length == 6 && !_isVerifying
                ? () => unawaited(_verifyOtp())
                : null,
            isLoading: _isVerifying,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _isSending ? null : () => unawaited(_sendOtp()),
              icon: const Icon(Icons.chat_rounded, size: 16),
              label: Text(loc.resendWhatsapp),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _onOtpDigit(String digit) {
    if (_isVerifying || _otp.length >= 6) return;
    setState(() {
      _errorMessage = null;
      _otp += digit;
    });
  }

  void _onOtpBackspace() {
    if (_isVerifying || _otp.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _otp = _otp.substring(0, _otp.length - 1);
    });
  }

  Future<void> _sendOtp() async {
    setState(() => _isSending = true);
    try {
      await context.read<AuthBloc>().requestOtpForPinReset(widget.phoneNumber);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isVerifying = true);
    final completed = await Navigator.of(context).push<bool>(
      _flowRoute<bool>(
        context,
        _PinStep(
          phoneNumber: widget.phoneNumber,
          verificationCode: _otp,
          kind: _PinStepKind.newPin,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (completed == true) Navigator.of(context).pop(true);
  }
}

enum _PinStepKind { newPin, confirmation }

class _PinStep extends StatefulWidget {
  const _PinStep({
    required this.phoneNumber,
    required this.verificationCode,
    required this.kind,
    this.newPin,
  });

  final String phoneNumber;
  final String verificationCode;
  final _PinStepKind kind;
  final String? newPin;

  @override
  State<_PinStep> createState() => _PinStepState();
}

class _PinStepState extends State<_PinStep> {
  String _pin = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  bool get _isConfirmation => widget.kind == _PinStepKind.confirmation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = _isConfirmation ? loc.confirmation : loc.newSecretCode;
    final keypadForeground = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return _FlowFrame(
      title: title,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isConfirmation
                ? loc.enterNewSecretCodeAgain
                : loc.chooseNewSecretCode,
            style: _bodyTextStyle(context),
          ),
          const SizedBox(height: 34),
          Semantics(
            label: title,
            button: true,
            child: _CodeBoxes(value: _pin, total: 4),
          ),
          const SizedBox(height: 58),
          SizedBox(
            height: 286,
            child: NumericKeypad(
              key: ValueKey(
                _isConfirmation
                    ? 'secret-pin-confirmation-keypad'
                    : 'secret-pin-keypad',
              ),
              onDigitTap: _onPinDigit,
              onBackspace: _onPinBackspace,
              foregroundColor: keypadForeground,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorText(_errorMessage!),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: _isConfirmation ? 'Valider' : loc.continueLabel,
            onPressed: _pin.length == 4 && !_isSubmitting
                ? () => unawaited(_continue())
                : null,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _onPinDigit(String digit) {
    if (_isSubmitting || _pin.length >= 4) return;
    setState(() {
      _errorMessage = null;
      _pin += digit;
    });
  }

  void _onPinBackspace() {
    if (_isSubmitting || _pin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _continue() async {
    if (!_isConfirmation) {
      final completed = await Navigator.of(context).push<bool>(
        _flowRoute<bool>(
          context,
          _PinStep(
            phoneNumber: widget.phoneNumber,
            verificationCode: widget.verificationCode,
            kind: _PinStepKind.confirmation,
            newPin: _pin,
          ),
        ),
      );
      if (completed == true && mounted) Navigator.of(context).pop(true);
      return;
    }

    if (widget.newPin != _pin) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).codeMismatch;
        _pin = '';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    String? error;
    try {
      final bloc = context.read<AuthBloc>();
      final resultFuture = bloc.stream.firstWhere(
        (state) => state is AuthPinResetSuccess || state is AuthFailure,
      );
      bloc.add(
        PinResetRequested(
          phoneNumber: widget.phoneNumber,
          verificationCode: widget.verificationCode,
          newPin: widget.newPin!,
        ),
      );
      final result = await resultFuture;
      if (result is AuthFailure) error = result.errorMessage;
    } catch (exception) {
      error = _cleanError(exception);
    }

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = error;
        _pin = '';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }
}

class _FlowFrame extends StatelessWidget {
  const _FlowFrame({
    required this.title,
    required this.child,
    required this.onBack,
  });

  final String title;
  final Widget child;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode
        ? AppColors.darkBackground
        : const Color(0xFFFCFCFD);
    final foreground = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back, color: foreground, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 46,
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final display = value.isEmpty ? '77 000 00 00' : _formatPartialPhone(value);

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkControl : AppColors.lightSurface,
        border: Border.all(color: AppColors.lightBorder),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Text('🇸🇳', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '+221',
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: AppColors.lightBorder),
          const SizedBox(width: 12),
          Text(
            display,
            style: TextStyle(
              color: value.isEmpty
                  ? foreground.withValues(alpha: 0.35)
                  : foreground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.value, required this.total});

  final String value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final border = isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = total > 4 ? 8.0 : 10.0;
        final boxSize = ((constraints.maxWidth - gap * (total - 1)) / total)
            .clamp(total > 4 ? 36.0 : 46.0, 68.0)
            .toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (index) {
            final filled = index < value.length;
            final active = index == value.length && value.length < total;
            return Padding(
              padding: EdgeInsets.only(right: index == total - 1 ? 0 : gap),
              child: SizedBox.square(
                dimension: boxSize,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: filled || active
                        ? (isDarkMode
                              ? AppColors.darkControl
                              : AppColors.brandSurfaceSoft)
                        : (isDarkMode
                              ? AppColors.darkTile
                              : AppColors.lightSurface),
                    border: Border.all(
                      color: active ? AppColors.brand : border,
                      width: active ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    filled ? value[index] : '',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _WhatsAppNote extends StatelessWidget {
  const _WhatsAppNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_rounded, color: AppColors.success, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: AppColors.error,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

TextStyle _bodyTextStyle(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return TextStyle(
    color: isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText,
    fontSize: 13,
    height: 1.45,
  );
}

String _formatPartialPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final parts = <String>[];
  if (digits.isNotEmpty) {
    parts.add(digits.substring(0, digits.length < 2 ? digits.length : 2));
  }
  if (digits.length > 2) {
    parts.add(digits.substring(2, digits.length < 5 ? digits.length : 5));
  }
  if (digits.length > 5) {
    parts.add(digits.substring(5, digits.length < 7 ? digits.length : 7));
  }
  if (digits.length > 7) {
    parts.add(digits.substring(7, digits.length < 9 ? digits.length : 9));
  }
  return parts.join(' ');
}

String _cleanError(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}

PageRoute<T> _flowRoute<T>(BuildContext context, Widget child) {
  return PageRouteBuilder<T>(
    pageBuilder: (routeContext, animation, secondaryAnimation) =>
        BlocProvider.value(value: context.read<AuthBloc>(), child: child),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
