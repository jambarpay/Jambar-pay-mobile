import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/keypad_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.phoneNumber,
    required this.onContinue,
    required this.onBackspace,
    required this.onDigitTap,
    required this.canContinue,
  });

  final String phoneNumber;
  final VoidCallback onContinue;
  final VoidCallback onBackspace;
  final ValueChanged<String> onDigitTap;
  final bool canContinue;

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
                                const SizedBox(height: 12),
                                const Center(
                                  child: Text(
                                    'Connexion',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    'Entrez votre numero de telephone',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Numero de telephone',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.55),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                PhoneField(phoneNumber: phoneNumber),
                                const SizedBox(height: 18),
                                SizedBox(
                                  height: keypadHeight.toDouble(),
                                  child: NumericKeypad(
                                    onDigitTap: onDigitTap,
                                    onBackspace: onBackspace,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: canContinue ? onContinue : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF1C1A33),
                                      disabledBackgroundColor: const Color(
                                        0xFF1C1A33,
                                      ).withValues(alpha: 0.35),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Continuer',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
}
