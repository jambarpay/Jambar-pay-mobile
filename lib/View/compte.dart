import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

class ComptePage extends StatelessWidget {
  const ComptePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(AppLocalizations.of(context).accountPage)));
  }
}
