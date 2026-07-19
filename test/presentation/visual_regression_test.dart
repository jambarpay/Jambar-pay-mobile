import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/design_system/theme/theme_controller.dart';
import 'package:jambar_pay_mobile/injection.dart' as di;
import 'package:jambar_pay_mobile/language_controller.dart';
import 'package:jambar_pay_mobile/main.dart';

void main() {
  setUpAll(() async {
    await di.init(useMockApi: true, useLocalAuth: true);
  });

  setUp(() {
    ThemeController.setDarkMode(false);
    LanguageController.localeNotifier.value = const Locale('fr');
  });

  testWidgets('login visual regression - mobile', (tester) async {
    await _pumpAtSize(tester, const Size(390, 844));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../goldens/login_mobile.png'),
    );
  });

  testWidgets('login visual regression - desktop', (tester) async {
    await _pumpAtSize(tester, const Size(1440, 900));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../goldens/login_desktop.png'),
    );
  });
}

Future<void> _pumpAtSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const JambarPayApp());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}
