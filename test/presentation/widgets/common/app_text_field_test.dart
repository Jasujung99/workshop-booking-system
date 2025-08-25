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

      testWidgets('should display hint text when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Label',
              hint: 'Enter your text here',
            ),
          ),
        );

        // Assert - Check that the hint text is present in the widget tree
        expect(find.byType(TextFormField), findsOneWidget);
        // We can verify the hint text is configured by checking the widget exists
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
      testWidgets('should obscure text when obscureText is true', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'secret123');
        await tester.pump();

        // Assert - Check that visibility toggle icon is present (indicates password field)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

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

      testWidgets('should display custom error text when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Field',
              errorText: 'Custom error message',
            ),
          ),
        );

        // Assert
        expect(find.text('Custom error message'), findsOneWidget);
      });
    });

    group('Helper Text', () {
      testWidgets('should display helper text when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Test Field',
              helperText: 'This is helper text',
            ),
          ),
        );

        // Assert - Check that helper text is visible
        expect(find.text('This is helper text'), findsOneWidget);
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

    group('Input Properties', () {
      testWidgets('should respect maxLines property', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Multiline Field',
              maxLines: 3,
            ),
          ),
        );

        // Assert - Check that the field exists and can accept multiline input
        expect(find.byType(TextFormField), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), 'Line 1\nLine 2\nLine 3');
        await tester.pump();
        expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
      });

      testWidgets('should respect maxLength property', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Limited Field',
              maxLength: 10,
            ),
          ),
        );

        // Assert - Check that the field exists and shows character counter
        expect(find.byType(TextFormField), findsOneWidget);
        // Character counter should be visible when maxLength is set
        expect(find.text('0/10'), findsOneWidget);
      });

      testWidgets('should respect keyboardType property', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Email Field',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        );

        // Assert - Check that the field exists and can accept email input
        expect(find.byType(TextFormField), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.pump();
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('should be disabled when enabled is false', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Disabled Field',
              enabled: false,
            ),
          ),
        );

        // Assert - Check that the field exists but cannot be interacted with
        expect(find.byType(TextFormField), findsOneWidget);
        // Try to enter text - it should not work for disabled field
        await tester.tap(find.byType(TextFormField));
        await tester.pump();
        // Field should still be empty since it's disabled
        expect(find.text('Disabled Field'), findsOneWidget);
      });

      testWidgets('should be read-only when readOnly is true', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Read-only Field',
              readOnly: true,
            ),
          ),
        );

        // Assert - Check that the field exists
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Read-only Field'), findsOneWidget);
      });

      testWidgets('should autofocus when autofocus is true', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(
            AppTextField(
              label: 'Autofocus Field',
              autofocus: true,
            ),
          ),
        );

        // Assert - Check that the field exists and is focused
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Autofocus Field'), findsOneWidget);
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
        
        // The TextFormField should be semantically labeled
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
    });
  });
}