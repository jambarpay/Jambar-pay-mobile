import 'package:flutter/material.dart';
import 'secret_code_screen.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/keypad_widgets.dart';

class PinScreen extends StatelessWidget {
  const PinScreen({
    super.key,
    required this.pin,
    required this.phoneNumber,
    required this.onBack,
    required this.onBackspace,
    required this.onDigitTap,
    required this.onResetPin,
    this.errorText,
  });

  final String pin;
  final String phoneNumber;
  final VoidCallback onBack;
  final VoidCallback onBackspace;
  final ValueChanged<String> onDigitTap;
  final ValueChanged<String> onResetPin;
  final String? errorText;

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
                                      onPressed: onBack,
                                      icon: const Icon(Icons.arrow_back, size: 22),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Retour',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 34),
                                const Center(
                                  child: Text(
                                    'Code PIN',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'Entrez votre code PIN',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Center(child: PinDots(length: pin.length)),
                                if (errorText != null) ...[
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      errorText!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 28),
                                SizedBox(
                                  height: keypadHeight.toDouble(),
                                  child: NumericKeypad(
                                    onDigitTap: onDigitTap,
                                    onBackspace: onBackspace,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      final didReset = await Navigator.of(context)
                                          .push<bool>(
                                            MaterialPageRoute(
                                              builder: (context) => SecretCodeScreen(
                                                mode: SecretCodeFlowMode.reset,
                                                phoneNumber: phoneNumber,
                                                isDarkMode: false,
                                                onResetPin: onResetPin,
                                              ),
                                            ),
                                          );

                                      if (didReset == true && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Code secret reinitialise avec succes.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Code PIN oublie ?',
                                      style: TextStyle(
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
