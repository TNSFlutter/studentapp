import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/theme_adaptive.dart';
import 'profile_theme.dart';

class ProfileHelpSupportScreen extends StatefulWidget {
  const ProfileHelpSupportScreen({super.key});

  @override
  State<ProfileHelpSupportScreen> createState() =>
      _ProfileHelpSupportScreenState();
}

class _ProfileHelpSupportScreenState extends State<ProfileHelpSupportScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final faqs = [
      (
        'How do I pay fees online?',
        '1. Open Fees from the bottom bar.\n2. Select your child and fee head.\n3. Choose payment method and complete checkout.\n4. Download receipt from history.',
      ),
      (
        'How to apply for leave?',
        'Open Homework or More (if available) and use the leave module, or contact the class teacher.',
      ),
      (
        'How to download fee receipt?',
        'Fees → History → tap a paid entry → Download PDF.',
      ),
      (
        'Why is attendance not updating?',
        'Attendance syncs after the teacher marks the register. Allow up to a few hours.',
      ),
      (
        'How to switch between children?',
        'Use the student switcher on the home dashboard or profile children list.',
      ),
    ];

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('profile_help_support'.tr),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              style: TextStyle(color: scheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? scheme.surfaceContainerHighest
                    : Colors.white.withValues(alpha: 0.95),
                hintText: 'help_search'.tr,
                hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: ProfileTheme.headerOrange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _quickCard(
                  context,
                  Icons.phone_in_talk,
                  'help_call_school'.tr,
                  'help_call_hours'.tr,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickCard(
                  context,
                  Icons.chat,
                  'help_whatsapp'.tr,
                  'help_quick_response'.tr,
                  const Color(0xFF25D366),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'help_faq'.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(faqs.length, (i) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                iconColor: scheme.onSurfaceVariant,
                collapsedIconColor: scheme.onSurfaceVariant,
                title: Text(
                  faqs[i].$1,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeAdaptive.softTint(
                        context,
                        const Color(0xFFFFF4ED),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      faqs[i].$2,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: ProfileTheme.headerOrange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'help_email_support'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        'support@myschool.example.com',
                        style: TextStyle(
                          color: ProfileTheme.headerOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color accent,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
