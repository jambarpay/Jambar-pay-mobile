import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';

class ScannerPreview extends StatelessWidget {
  const ScannerPreview({
    super.key,
    required this.isDarkMode,
    required this.controller,
    required this.onDetect,
    this.lastScannedValue,
  });

  final bool isDarkMode;
  final MobileScannerController controller;
  final ValueChanged<String?> onDetect;
  final String? lastScannedValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardWidth = availableWidth.clamp(260.0, 360.0).toDouble();
        final scannerSize = (cardWidth - 48).clamp(212.0, 312.0).toDouble();
        final cardHeight = (scannerSize + 118).clamp(330.0, 450.0).toDouble();
        final scannerTop = ((cardHeight - scannerSize) / 2) + (scannerSize * 0.5);

        return Container(
          key: key,
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: const Color(0xFF121212),
            border: Border.all(color: Colors.black.withValues(alpha: 0.45)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: scannerSize,
                    height: scannerSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: controller,
                          fit: BoxFit.cover,
                          onDetect: (capture) {
                            final barcode = capture.barcodes.isNotEmpty
                                ? capture.barcodes.first
                                : null;
                            onDetect(barcode?.rawValue);
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: scannerTop.clamp(150.0, cardHeight - 90.0),
                child: Container(height: 4, color: const Color(0xFF3B69F4)),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Text(
                  lastScannedValue == null
                      ? 'Scannez un code QR'
                      : 'QR détecté: $lastScannedValue',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LargeQrCard extends StatelessWidget {
  const LargeQrCard({
    super.key,
    required this.isDarkMode,
    required this.userProfile,
    this.scanResult,
  });

  final bool isDarkMode;
  final UserProfileModel userProfile;
  final QRScanResultModel? scanResult;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardSize = availableWidth.clamp(250.0, 330.0).toDouble();

        return Container(
          key: key,
          width: cardSize,
          height: cardSize,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Expanded(child: QrBlock()),
              const SizedBox(height: 12),
              Text(
                userProfile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scanResult?.token ?? 'QR employe',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: palette.secondaryText),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QrDetailsCard extends StatelessWidget {
  const QrDetailsCard({
    super.key,
    required this.userProfile,
    this.scanResult,
    this.paymentResult,
  });

  final UserProfileModel userProfile;
  final QRScanResultModel? scanResult;
  final PaymentResultModel? paymentResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userProfile.phone,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF6E6B87),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scanResult?.merchantName ?? 'QR employe actif',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            paymentResult == null
                ? 'Pret pour le scan et la confirmation du paiement.'
                : '${paymentResult!.amount.formatted} • ${paymentResult!.date}',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6E6B87),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class QrBlock extends StatelessWidget {
  const QrBlock();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final highlighted = _qrIndexes.contains(index);
            return Container(
              decoration: BoxDecoration(
                color: highlighted ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          },
        ),
      ),
    );
  }
}

const Set<int> _qrIndexes = {
  0,
  1,
  2,
  9,
  11,
  18,
  19,
  20,
  6,
  7,
  8,
  15,
  17,
  24,
  25,
  26,
  54,
  55,
  56,
  63,
  65,
  72,
  73,
  74,
  4,
  12,
  13,
  21,
  22,
  29,
  31,
  33,
  35,
  38,
  39,
  41,
  43,
  44,
  47,
  49,
  50,
  52,
  58,
  60,
  61,
  67,
  68,
  70,
  76,
  78,
  79,
};
