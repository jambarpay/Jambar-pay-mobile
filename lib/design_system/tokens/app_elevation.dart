import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppElevation {
  static const level1 = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowSubtle,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const authCard = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 22,
      offset: Offset(0, -2),
    ),
  ];
}
