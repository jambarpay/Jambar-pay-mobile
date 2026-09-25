import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/keypad_widgets.dart';

class EmployeeOtpScreen extends StatelessWidget {
  const EmployeeOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
    required this.onDigitTap,
    required this.onBackspace,
    required this.onSubmit,
    this.errorText,
  });

  final String phoneNumber;
  final String otp;
  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AuthCard(
                      topMargin: 54,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              loc.whatsappCode,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              loc.otpSentTo(phoneNumber),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _CodeBoxes(value: otp),
                          if (errorText != null) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          NumericKeypad(
                            onDigitTap: onDigitTap,
                            onBackspace: onBackspace,
                            foregroundColor: AppColors.lightPrimaryText,
                            buttonBackgroundColor: AppColors.lightSurface,
                            buttonBorderColor: AppColors.lightBorder,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: otp.length == 6 ? onSubmit : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.lightPrimaryText,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.navigation,
                                  ),
                                ),
                              ),
                              child: Text(loc.verifyCode),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final filled = index < value.length;
        return Padding(
          padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
          child: SizedBox.square(
            dimension: 40,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filled
                    ? AppColors.brandSurfaceSoft
                    : AppColors.lightSurface,
                border: Border.all(
                  color: filled ? AppColors.brand : AppColors.lightBorder,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                filled ? value[index] : '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
