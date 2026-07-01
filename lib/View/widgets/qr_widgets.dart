import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
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
        final scannerTop =
            ((cardHeight - scannerSize) / 2) + (scannerSize * 0.5);

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
                      ? AppLocalizations.of(context).scanQrCode
                      : AppLocalizations.of(
                          context,
                        ).qrDetected(lastScannedValue!),
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
    final qrPayload =
        scanResult?.token ??
        'JAMBAR|EMPLOYEE|${userProfile.id}|${userProfile.phone}';
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
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(child: QrBlock(data: qrPayload, borderRadius: 18)),
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
                scanResult?.token ?? AppLocalizations.of(context).employeeQr,
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
            scanResult?.merchantName ??
                AppLocalizations.of(context).activeEmployeeQr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            paymentResult == null
                ? AppLocalizations.of(context).readyForScan
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
  const QrBlock({
    super.key,
    this.data = 'JAMBAR|QR|DEMO',
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.borderRadius = 12,
    this.showFrame = true,
  });

  final String data;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final bool showFrame;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: showFrame
              ? Border.all(
                  color: foregroundColor.withValues(alpha: 0.92),
                  width: 2.2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: CustomPaint(
          painter: _QrPainter(
            data: data,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter({
    required this.data,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String data;
  final Color backgroundColor;
  final Color foregroundColor;

  static const int _moduleCount = 29;
  static const int _quietZone = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    final fgPaint = Paint()..color = foregroundColor;
    final softPaint = Paint()..color = foregroundColor.withValues(alpha: 0.12);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      bgPaint,
    );

    final moduleSize = size.shortestSide / (_moduleCount + (_quietZone * 2));
    final matrix = _generateMatrix(data, _moduleCount);

    for (var row = 0; row < _moduleCount; row++) {
      for (var col = 0; col < _moduleCount; col++) {
        final left = (col + _quietZone) * moduleSize;
        final top = (row + _quietZone) * moduleSize;
        final rect = Rect.fromLTWH(left, top, moduleSize, moduleSize);

        if (_isFinderCell(row, col)) {
          _paintFinderCell(canvas, rect, row, col, fgPaint, bgPaint);
          continue;
        }

        if (_isAlignmentCell(row, col)) {
          _paintAlignmentCell(canvas, rect, row, col, fgPaint, bgPaint);
          continue;
        }

        if (_isTimingCell(row, col)) {
          if ((row + col).isEven) {
            canvas.drawRect(rect.deflate(moduleSize * 0.06), fgPaint);
          }
          continue;
        }

        if (matrix[row][col]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect.deflate(moduleSize * 0.09),
              Radius.circular(moduleSize * 0.16),
            ),
            fgPaint,
          );
        } else if ((row * col) % 11 == 0 && !_isReservedCell(row, col)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect.deflate(moduleSize * 0.28),
              Radius.circular(moduleSize * 0.14),
            ),
            softPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor;
  }

  List<List<bool>> _generateMatrix(String value, int size) {
    final matrix = List.generate(size, (_) => List<bool>.filled(size, false));
    final hashSeed = value.codeUnits.fold<int>(
      0x811C9DC5,
      (seed, code) => ((seed ^ code) * 16777619) & 0x7fffffff,
    );

    var rolling = hashSeed;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (_isReservedCell(row, col)) {
          continue;
        }

        rolling =
            ((rolling * 1103515245) + 12345 + (row * 31) + col) & 0x7fffffff;
        final bit = ((rolling >> 7) ^ (rolling >> 15) ^ row ^ (col * 3)) & 1;
        final diagonalBias = ((row + col + hashSeed) % 5) == 0;
        matrix[row][col] = bit == 1 || diagonalBias;
      }
    }

    return matrix;
  }

  bool _isReservedCell(int row, int col) {
    return _isWithinFinder(row, col, 0, 0) ||
        _isWithinFinder(row, col, 0, _moduleCount - 7) ||
        _isWithinFinder(row, col, _moduleCount - 7, 0) ||
        _isWithinAlignment(row, col) ||
        _isTimingCell(row, col);
  }

  bool _isFinderCell(int row, int col) {
    return _isWithinFinder(row, col, 0, 0) ||
        _isWithinFinder(row, col, 0, _moduleCount - 7) ||
        _isWithinFinder(row, col, _moduleCount - 7, 0);
  }

  bool _isWithinFinder(int row, int col, int top, int left) {
    return row >= top && row < top + 7 && col >= left && col < left + 7;
  }

  bool _isAlignmentCell(int row, int col) => _isWithinAlignment(row, col);

  bool _isWithinAlignment(int row, int col) {
    const start = _moduleCount - 9;
    return row >= start && row < start + 5 && col >= start && col < start + 5;
  }

  bool _isTimingCell(int row, int col) {
    final rowTiming = row == 6 && col > 7 && col < _moduleCount - 8;
    final colTiming = col == 6 && row > 7 && row < _moduleCount - 8;
    return rowTiming || colTiming;
  }

  void _paintFinderCell(
    Canvas canvas,
    Rect rect,
    int row,
    int col,
    Paint fgPaint,
    Paint bgPaint,
  ) {
    final localRow = row >= _moduleCount - 7 ? row - (_moduleCount - 7) : row;
    final localCol = col >= _moduleCount - 7 ? col - (_moduleCount - 7) : col;
    final isOuter =
        localRow == 0 || localRow == 6 || localCol == 0 || localCol == 6;
    final isInner =
        localRow >= 2 && localRow <= 4 && localCol >= 2 && localCol <= 4;

    canvas.drawRect(rect, isOuter || isInner ? fgPaint : bgPaint);
  }

  void _paintAlignmentCell(
    Canvas canvas,
    Rect rect,
    int row,
    int col,
    Paint fgPaint,
    Paint bgPaint,
  ) {
    const start = _moduleCount - 9;
    final localRow = row - start;
    final localCol = col - start;
    final isOuter =
        localRow == 0 || localRow == 4 || localCol == 0 || localCol == 4;
    final isCenter = localRow == 2 && localCol == 2;

    canvas.drawRect(rect, isOuter || isCenter ? fgPaint : bgPaint);
  }
}
