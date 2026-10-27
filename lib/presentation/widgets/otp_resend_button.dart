import 'dart:async';

import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// The deadline belongs to the auth flow, so rebuilding this button never resets it.
class OtpResendButton extends StatefulWidget {
  const OtpResendButton({
    super.key,
    required this.remainingDelay,
    required this.onResend,
    this.enabled = true,
  });

  final Duration Function() remainingDelay;
  final Future<void> Function() onResend;
  final bool enabled;

  @override
  State<OtpResendButton> createState() => _OtpResendButtonState();
}

class _OtpResendButtonState extends State<OtpResendButton>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncCountdown();
  }

  @override
  void didUpdateWidget(covariant OtpResendButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCountdown();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(_syncCountdown);
    }
  }

  void _syncCountdown() {
    _timer?.cancel();
    // Round up: the button must stay disabled for the entire last second.
    final remaining = widget.remainingDelay();
    _remainingSeconds = (remaining.inMicroseconds / 1000000).ceil().clamp(
      0,
      120,
    );
    if (_remainingSeconds > 0) {
      final tick = remaining < const Duration(seconds: 1)
          ? remaining
          : const Duration(seconds: 1);
      _timer = Timer(tick, () {
        if (mounted) setState(_syncCountdown);
      });
    }
  }

  Future<void> _resend() async {
    if (_isSending ||
        !widget.enabled ||
        widget.remainingDelay() > Duration.zero) {
      return;
    }
    setState(() => _isSending = true);
    try {
      await widget.onResend();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _syncCountdown();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return TextButton.icon(
      onPressed: widget.enabled && !_isSending && _remainingSeconds == 0
          ? () => unawaited(_resend())
          : null,
      icon: const Icon(Icons.chat_rounded, size: 16),
      label: Text(
        _remainingSeconds > 0
            ? loc.resendCodeIn('$minutes:$seconds')
            : loc.resendWhatsapp,
        textAlign: TextAlign.center,
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.success,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
