import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspace,
    this.foregroundColor = AppColors.lightPrimaryText,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspace;
  final Color foregroundColor;

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
                          foregroundColor: foregroundColor,
                          onTap: () => onDigitTap(digit),
                        ),
                      ),
                    )
                    .toList(),
              ),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(
                  child: KeypadButton(
                    label: '0',
                    height: buttonHeight,
                    foregroundColor: foregroundColor,
                    onTap: () => onDigitTap('0'),
                  ),
                ),
                Expanded(
                  child: KeypadButton(
                    icon: Icons.backspace_outlined,
                    semanticLabel: AppLocalizations.of(context).deleteLastDigit,
                    height: buttonHeight,
                    foregroundColor: foregroundColor,
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
    this.foregroundColor = AppColors.lightPrimaryText,
  });

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final double height;
  final VoidCallback onTap;
  final Color foregroundColor;

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
          child: Center(
            child: icon != null
                ? Icon(icon, size: 22, color: foregroundColor)
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
