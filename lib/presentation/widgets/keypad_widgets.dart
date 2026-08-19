import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

class NativeNumericInput extends StatefulWidget {
  const NativeNumericInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.maxLength,
    required this.onChanged,
    this.textFieldKey,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final Key? textFieldKey;
  final bool enabled;

  @override
  State<NativeNumericInput> createState() => _NativeNumericInputState();
}

class _NativeNumericInputState extends State<NativeNumericInput> {
  @override
  void initState() {
    super.initState();
    _scheduleKeyboard();
  }

  @override
  void didUpdateWidget(covariant NativeNumericInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((!oldWidget.enabled && widget.enabled) ||
        oldWidget.focusNode != widget.focusNode) {
      _scheduleKeyboard();
    }
  }

  void _scheduleKeyboard() {
    if (!widget.enabled) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled || !widget.focusNode.canRequestFocus) {
        return;
      }

      widget.focusNode.requestFocus();
      // requestFocus is sufficient on most platforms. Explicitly asking the
      // text input channel also handles fields mounted after a route/BLoC
      // transition, where autofocus can run before the view is attached.
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.01,
      child: SizedBox(
        height: 48,
        child: TextField(
          key: widget.textFieldKey,
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          autofocus: false,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(widget.maxLength),
          ],
          showCursor: false,
          enableInteractiveSelection: false,
          style: const TextStyle(color: Colors.transparent, fontSize: 1),
          cursorColor: Colors.transparent,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspace,
    this.leadingLabel,
    this.onLeadingTap,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w600,
    this.foregroundColor = AppColors.lightPrimaryText,
    this.buttonBackgroundColor,
    this.buttonBorderColor,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspace;
  final String? leadingLabel;
  final VoidCallback? onLeadingTap;
  final double fontSize;
  final FontWeight fontWeight;
  final Color foregroundColor;
  final Color? buttonBackgroundColor;
  final Color? buttonBorderColor;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonHeight = (constraints.maxHeight / 4).clamp(44.0, 60.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final row in rows)
              Row(
                children: row
                    .map(
                      (digit) => Expanded(
                        child: KeypadButton(
                          label: digit,
                          height: buttonHeight,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          foregroundColor: foregroundColor,
                          backgroundColor: buttonBackgroundColor,
                          borderColor: buttonBorderColor,
                          onTap: () => onDigitTap(digit),
                        ),
                      ),
                    )
                    .toList(),
              ),
            Row(
              children: [
                Expanded(
                  child: leadingLabel == null
                      ? const SizedBox()
                      : KeypadButton(
                          label: leadingLabel,
                          semanticLabel: AppLocalizations.of(context).forgotPin,
                          height: buttonHeight,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          foregroundColor: foregroundColor,
                          backgroundColor: buttonBackgroundColor,
                          borderColor: buttonBorderColor,
                          onTap: onLeadingTap ?? () {},
                        ),
                ),
                Expanded(
                  child: KeypadButton(
                    label: '0',
                    height: buttonHeight,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    foregroundColor: foregroundColor,
                    backgroundColor: buttonBackgroundColor,
                    borderColor: buttonBorderColor,
                    onTap: () => onDigitTap('0'),
                  ),
                ),
                Expanded(
                  child: KeypadButton(
                    icon: Icons.backspace_outlined,
                    semanticLabel: AppLocalizations.of(context).deleteLastDigit,
                    height: buttonHeight,
                    foregroundColor: foregroundColor,
                    backgroundColor: buttonBackgroundColor,
                    borderColor: buttonBorderColor,
                    onTap: onBackspace,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class KeypadButton extends StatelessWidget {
  const KeypadButton({
    super.key,
    this.label,
    this.icon,
    this.semanticLabel,
    required this.height,
    required this.onTap,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w600,
    this.foregroundColor = AppColors.lightPrimaryText,
    this.backgroundColor,
    this.borderColor,
  });

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final double height;
  final VoidCallback onTap;
  final double fontSize;
  final FontWeight fontWeight;
  final Color foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final buttonKey = label != null
        ? ValueKey('keypad-$label')
        : const ValueKey('keypad-backspace');

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: InkWell(
        key: buttonKey,
        excludeFromSemantics: true,
        borderRadius: BorderRadius.circular(AppRadius.round),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor!),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 18, color: foregroundColor)
                  : Text(
                      label ?? '',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: foregroundColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
