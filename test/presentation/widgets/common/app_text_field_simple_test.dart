import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/presentation/widgets/common/app_text_field.dart';
import 'package:workshop_booking_system/presentation/theme/app_theme.dart';

void main() {
  group('AppTextField Widget Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Basic Functionality', () {
      testWidgets('should display label correctly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Label',
            ),
          ),
        );

        // Assert
        expect(find.text('Test Label'), findsOneWidget);
      });

      testWidgets('should accept text input', (WidgetTester tester) async {
        // Arrange
        final controller = TextEditingController();
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Input',
              controller: controller,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Hello World');
        await tester.pump();

        // Assert
        expect(controller.text, 'Hello World');
        expect(find.text('Hello World'), findsOneWidget);
      });

      testWidgets('should call onChanged when text changes', (WidgetTester tester) async {
        // Arrange
        String? changedText;
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Input',
              onChanged: (text) {
                changedText = text;
              },
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Changed Text');
        await tester.pump();

        // Assert
        expect(changedText, 'Changed Text');
      });
    });

    group('Password Field', () {
      testWidgets('should show visibility toggle icon for password field', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should toggle password visibility when icon is tapped', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        );

        // Initially should show visibility icon (password is hidden)
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Tap the visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Should now show visibility_off icon (password is visible)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      });
    });

    group('Validation', () {
      testWidgets('should display error text when validation fails', (WidgetTester tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            Form(
              key: formKey,
              child: AppTextField(
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Trigger validation
        formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should not display error when validation passes', (WidgetTester tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            Form(
              key: formKey,
              child: AppTextField(
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(find.text('Email is required'), findsNothing);
      });
    });

    group('Icons', () {
      testWidgets('should display prefix icon when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Field',
              prefixIcon: Icon(Icons.email),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('should display suffix icon when provided (non-password field)', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Field',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    group('Callbacks', () {
      testWidgets('should call onSubmitted when submitted', (WidgetTester tester) async {
        // Arrange
        String? submittedText;
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Submit Field',
              onSubmitted: (text) {
                submittedText = text;
              },
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Submitted Text');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert
        expect(submittedText, 'Submitted Text');
      });

      testWidgets('should call onEditingComplete when editing is complete', (WidgetTester tester) async {
        // Arrange
        bool editingCompleted = false;
        
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Complete Field',
              onEditingComplete: () {
                editingCompleted = true;
              },
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Complete Text');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert
        expect(editingCompleted, isTrue);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible to screen readers', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Accessible Field',
            ),
          ),
        );

        // Assert
        expect(find.text('Accessible Field'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle null controller gracefully', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'No Controller Field',
              controller: null,
            ),
          ),
        );

        // Assert
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should handle empty label', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: '',
            ),
          ),
        );

        // Assert
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should handle multiline input', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Multiline Field',
              maxLines: 3,
            ),
          ),
        );

        // Assert
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should handle disabled state', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Disabled Field',
              enabled: false,
            ),
          ),
        );

        // Assert
        expect(find.byType(TextFormField), findsOneWidget);
        
        // Try to enter text - should not work when disabled
        await tester.enterText(find.byType(TextFormField), 'Should not work');
        await tester.pump();
        
        // The text should not appear since the field is disabled
        expect(find.text('Should not work'), findsNothing);
      });
    });
  });
}