import 'package:flutter/widgets.dart';

class LanguageController {
  LanguageController._();

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(
    const Locale('fr'),
  );
}
