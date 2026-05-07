import 'package:flutter/material.dart';

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({this.backgroundAsset, this.topSectionHeight = 320});

  final String? backgroundAsset;
  final double topSectionHeight;

  @override
  Widget build(BuildContext context) {
    if (backgroundAsset != null) {
      return Column(
        children: [
          SizedBox(
            height: topSectionHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundAsset!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  right: -20,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: -80,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Container(color: Colors.black.withValues(alpha: 0.24)),
              ],
            ),
          ),
          const Expanded(child: ColoredBox(color: Colors.white)),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: backgroundAsset == null
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF28233F), Color(0xFF11101E)],
                  )
                : null,
            image: backgroundAsset != null
                ? DecorationImage(
                    image: AssetImage(backgroundAsset!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        Positioned(
          top: -40,
          right: -20,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 170,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        Container(
          color: Colors.black.withValues(
            alpha: backgroundAsset != null ? 0.28 : 0.22,
          ),
        ),
      ],
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 38, 26, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF57C21),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Jambar Pay',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.topMargin = 36,
    this.backgroundColor = Colors.white,
  });

  final Widget child;
  final double topMargin;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: topMargin),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBC9D3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFD1CFD8))),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0x22000000)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: ColoredBox(color: Color(0xFF078930))),
                      Expanded(child: ColoredBox(color: Color(0xFFFCD116))),
                      Expanded(child: ColoredBox(color: Color(0xFFCE1126))),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '+221',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _formatPhoneNumber(phoneNumber),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPhoneNumber(String raw) {
    if (raw.isEmpty) {
      return '77-123-45-67';
    }

    final buffer = StringBuffer();
    for (var index = 0; index < raw.length; index++) {
      if (index == 2 || index == 5 || index == 7) {
        buffer.write('-');
      }
      buffer.write(raw[index]);
    }
    return buffer.toString();
  }
}

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isFilled = index < length;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF1C1A33) : Colors.transparent,
            border: Border.all(color: const Color(0xFFB5B3BE)),
          ),
        );
      }),
    );
  }
}
