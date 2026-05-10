import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:studentapp/l10n/app_translations.dart';
import 'package:studentapp/widgets/bottom_navigation.dart';

void main() {
  testWidgets('uses menu icon for the last bottom nav item', (tester) async {
    Widget appWithIndex(int index) {
      return GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: index,
            onTap: (_) {},
          ),
        ),
      );
    }

    await tester.pumpWidget(appWithIndex(0));

    expect(find.byIcon(Icons.menu_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);

    await tester.pumpWidget(appWithIndex(4));

    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsNothing);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
  });
}
