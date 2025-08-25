import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/presentation/widgets/common/app_button.dart';
import 'package:workshop_booking_system/presentation/theme/app_theme.dart';

void main() {
  group('AppButton Widget Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Basic Functionality', () {
      testWidgets('should display text correctly', (WidgetTester tester) async {
        // Arrange
        const buttonText = 'Test Button';
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.text(buttonText), findsOneWidget);
      });

      testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
        // Arrange
        bool wasPressed = false;
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(AppButton));
        await tester.pump();

        // Assert
        expect(wasPressed, isTrue);
      });

      testWidgets('should be disabled when onPressed is null', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        );

        // Assert
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });
    });

    group('Button Types', () {
      testWidgets('should render primary button by default', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Primary Button',
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('should render secondary button when type is secondary', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Secondary Button',
              type: AppButtonType.secondary,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byType(FilledButton), findsOneWidget);
        // Note: FilledButton.tonal creates a FilledButton widget
      });

      testWidgets('should render outlined button when type is outlined', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Outlined Button',
              type: AppButtonType.outlined,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('should render text button when type is text', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Text Button',
              type: AppButtonType.text,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading Button'), findsNothing);
      });

      testWidgets('should be disabled when loading', (WidgetTester tester) async {
        // Arrange
        bool wasPressed = false;
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(AppButton));
        await tester.pump();

        // Assert
        expect(wasPressed, isFalse);
      });
    });

    group('Icon Support', () {
      testWidgets('should display icon when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Icon Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('Icon Button'), findsOneWidget);
      });

      testWidgets('should not display icon when not provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'No Icon Button',
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.byType(Icon), findsNothing);
        expect(find.text('No Icon Button'), findsOneWidget);
      });
    });

    group('Size and Layout', () {
      testWidgets('should expand to full width when isExpanded is true', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            Container(
              width: 300,
              child: AppButton(
                text: 'Expanded Button',
                isExpanded: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Assert
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(FilledButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, double.infinity);
      });

      testWidgets('should respect custom width and height', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Custom Size Button',
              width: 200,
              height: 50,
              onPressed: () {},
            ),
          ),
        );

        // Assert
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(FilledButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, 200);
        expect(sizedBox.height, 50);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible to screen readers', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Accessible Button',
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.text('Accessible Button'), findsOneWidget);
        
        // Check that the button exists and is tappable
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should be marked as disabled for screen readers when disabled', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        );

        // Assert
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty text', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: '',
              onPressed: () {},
            ),
          ),
        );

        // Assert
        expect(find.text(''), findsOneWidget);
      });

      testWidgets('should handle very long text', (WidgetTester tester) async {
        // Arrange
        const longText = 'This is a very long button text that might overflow';
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            Container(
              width: 200,
              child: AppButton(
                text: longText,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(longText), findsOneWidget);
        // The text should be rendered without throwing overflow errors
      });

      testWidgets('should handle rapid taps correctly', (WidgetTester tester) async {
        // Arrange
        int tapCount = 0;
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppButton(
              text: 'Rapid Tap Button',
              onPressed: () {
                tapCount++;
              },
            ),
          ),
        );

        // Tap multiple times rapidly
        await tester.tap(find.byType(AppButton));
        await tester.tap(find.byType(AppButton));
        await tester.tap(find.byType(AppButton));
        await tester.pump();

        // Assert
        expect(tapCount, 3);
      });
    });
  });
}