import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(loc.privacyPolicyIntro),
          const SizedBox(height: 24),
          _PolicySection(
            title: loc.privacyDataTitle,
            body: loc.privacyDataBody,
          ),
          _PolicySection(
            title: loc.privacyUsageTitle,
            body: loc.privacyUsageBody,
          ),
          _PolicySection(
            title: loc.privacyStorageTitle,
            body: loc.privacyStorageBody,
          ),
          _PolicySection(
            title: loc.privacySharingTitle,
            body: loc.privacySharingBody,
          ),
          _PolicySection(
            title: loc.privacyRightsTitle,
            body: loc.privacyRightsBody,
          ),
          _PolicySection(
            title: loc.privacyContactTitle,
            body: loc.privacyContactBody,
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
