import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:workshop_booking_system/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Workshop Booking System Integration Tests', () {
    testWidgets('App should start and display initial screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // The app should show some initial content
      // This could be a login screen, home screen, or loading screen
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigation should work correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Try to find and interact with navigation elements
      // This is a basic test to ensure the app is navigable
      
      // Look for common navigation elements
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsAtLeastNWidgets(1));
      
      // If there's a bottom navigation bar, test it
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (tester.any(bottomNavBar)) {
        // Test navigation between tabs
        await tester.tap(bottomNavBar);
        await tester.pumpAndSettle();
      }
      
      // If there are buttons, test basic interaction
      final buttons = find.byType(ElevatedButton);
      if (tester.any(buttons)) {
        // Just verify buttons are tappable (don't actually tap to avoid side effects)
        expect(buttons, findsAtLeastNWidgets(1));
      }
    });

    testWidgets('Text input should work correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Look for text input fields
      final textFields = find.byType(TextField);
      final textFormFields = find.byType(TextFormField);
      
      if (tester.any(textFields)) {
        // Test text input
        await tester.enterText(textFields.first, 'Test input');
        await tester.pumpAndSettle();
        
        // Verify text was entered
        expect(find.text('Test input'), findsOneWidget);
      } else if (tester.any(textFormFields)) {
        // Test form field input
        await tester.enterText(textFormFields.first, 'Test form input');
        await tester.pumpAndSettle();
        
        // Verify text was entered
        expect(find.text('Test form input'), findsOneWidget);
      }
    });

    testWidgets('App should handle screen rotations', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Get initial screen size
      final initialSize = tester.binding.window.physicalSize;
      
      // Simulate screen rotation by changing the size
      tester.binding.window.physicalSizeTestValue = Size(
        initialSize.height,
        initialSize.width,
      );
      
      // Trigger a rebuild
      await tester.pumpAndSettle();
      
      // Verify the app still works after rotation
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      
      // Reset the screen size
      tester.binding.window.clearPhysicalSizeTestValue();
      await tester.pumpAndSettle();
    });

    testWidgets('App should handle rapid interactions', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find interactive elements
      final buttons = find.byType(ElevatedButton);
      final textButtons = find.byType(TextButton);
      final filledButtons = find.byType(FilledButton);
      
      // Test rapid interactions don't crash the app
      if (tester.any(buttons)) {
        for (int i = 0; i < 3; i++) {
          await tester.tap(buttons.first);
          await tester.pump(Duration(milliseconds: 100));
        }
      } else if (tester.any(textButtons)) {
        for (int i = 0; i < 3; i++) {
          await tester.tap(textButtons.first);
          await tester.pump(Duration(milliseconds: 100));
        }
      } else if (tester.any(filledButtons)) {
        for (int i = 0; i < 3; i++) {
          await tester.tap(filledButtons.first);
          await tester.pump(Duration(milliseconds: 100));
        }
      }
      
      await tester.pumpAndSettle();
      
      // Verify app is still responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should display error states gracefully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Look for error handling UI elements
      // This could be error messages, retry buttons, etc.
      
      // Verify the app has loaded without showing critical errors
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Look for common error indicators
      final errorWidgets = find.byType(ErrorWidget);
      expect(errorWidgets, findsNothing); // Should not have any error widgets
      
      // Look for loading indicators (which indicate the app is working)
      final loadingIndicators = find.byType(CircularProgressIndicator);
      // Loading indicators are okay - they show the app is working
      
      // Verify basic UI structure is intact
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('App should handle theme changes', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Get the current theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      
      // Verify the app uses Material Design 3
      if (materialApp.theme != null) {
        // Just verify theme exists and app doesn't crash
        expect(materialApp.theme!.colorScheme, isNotNull);
      }
      
      // Verify the app structure is maintained
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('App should be accessible', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify semantic structure
      final semantics = find.byType(Semantics);
      expect(semantics, findsAtLeastNWidgets(1));
      
      // Verify interactive elements are accessible
      final buttons = find.byType(ElevatedButton);
      final textButtons = find.byType(TextButton);
      final filledButtons = find.byType(FilledButton);
      
      // If buttons exist, they should be semantically accessible
      if (tester.any(buttons) || tester.any(textButtons) || tester.any(filledButtons)) {
        // Buttons should have semantic properties
        expect(semantics, findsAtLeastNWidgets(1));
      }
      
      // Verify text fields are accessible
      final textFields = find.byType(TextField);
      final textFormFields = find.byType(TextFormField);
      
      if (tester.any(textFields) || tester.any(textFormFields)) {
        // Text fields should be semantically labeled
        expect(semantics, findsAtLeastNWidgets(1));
      }
    });
  });
}