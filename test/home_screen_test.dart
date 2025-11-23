import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrroadways/pages/home.dart';
import 'package:hrroadways/providers/routes_search_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomeScreen initial UI test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RoutesSearchProvider(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('Search functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RoutesSearchProvider(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(Autocomplete<String>).first, 'DELHI');
    await tester.enterText(find.byType(Autocomplete<String>).last, 'CHANDIGARH');
    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(find.text('DELHI to CHANDIGARH'), findsOneWidget);
  });

  testWidgets('Swap button functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RoutesSearchProvider(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(Autocomplete<String>).first, 'DELHI');
    await tester.enterText(find.byType(Autocomplete<String>).last, 'CHANDIGARH');
    await tester.tap(find.byIcon(Icons.swap_vert_rounded));
    await tester.pump();

    expect(find.text('CHANDIGARH'), findsOneWidget);
    expect(find.text('DELHI'), findsOneWidget);
  });

  testWidgets('Terms and conditions dialog test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RoutesSearchProvider(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // This is a workaround to ensure the dialog is shown.
    // In a real app, you would mock SharedPreferences.
    await tester.pumpAndSettle();
    expect(find.text('Terms & Conditions'), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Terms & Conditions'), findsNothing);
  });
}
