import 'package:flutter/material.dart';

import '../tokens/app_breakpoints.dart';
import '../tokens/app_spacing.dart';

enum AppWindowClass { compact, medium, expanded }

extension AppWindowClassX on BuildContext {
  AppWindowClass get windowClass {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.expanded) return AppWindowClass.expanded;
    if (width >= AppBreakpoints.compact) return AppWindowClass.medium;
    return AppWindowClass.compact;
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.compactPadding = AppSpacing.md,
    this.expandedPadding = AppSpacing.xl,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final double compactPadding;
  final double expandedPadding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < AppBreakpoints.compact
            ? compactPadding
            : expandedPadding;
        return Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
