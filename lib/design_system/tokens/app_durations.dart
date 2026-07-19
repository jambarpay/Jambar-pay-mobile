import 'package:flutter/animation.dart';

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 500);
}

abstract final class AppCurves {
  static const standard = Curves.easeInOutCubic;
  static const emphasized = Curves.easeOutCubic;
}
