// SmartRestaurant Mobile App Widget Tests
//
// Basic widget tests for the SmartRestaurant mobile application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_mobile/main.dart';

void main() {
  group('SmartRestaurant App Tests', () {
    testWidgets('App builds without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: SmartRestaurantApp()));

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the app builds without errors
      // This is a basic smoke test to ensure the app structure is correct
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: SmartRestaurantApp()));

      // Wait for initial render
      await tester.pump();

      // Check if splash screen content is present
      expect(find.text('SmartRestaurant'), findsOneWidget);
      expect(find.text('Đang tải...'), findsOneWidget);
    });
  });
}
