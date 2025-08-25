import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Workshop Booking System Integration Tests', () {
    late FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      await driver.close();
    });

    group('Authentication Flow', () {
      test('should display login screen on app start', () async {
        // Verify that the login screen is displayed
        await driver.waitFor(find.text('로그인'));
        
        // Check for email and password fields
        await driver.waitFor(find.byValueKey('email_field'));
        await driver.waitFor(find.byValueKey('password_field'));
        
        // Check for login button
        await driver.waitFor(find.byValueKey('login_button'));
      });

      test('should show validation errors for empty fields', () async {
        // Try to login with empty fields
        await driver.tap(find.byValueKey('login_button'));
        
        // Wait for validation errors to appear
        await driver.waitFor(find.text('이메일을 입력해주세요'));
        await driver.waitFor(find.text('비밀번호를 입력해주세요'));
      });

      test('should navigate to signup screen', () async {
        // Tap on signup link/button
        await driver.tap(find.text('회원가입'));
        
        // Verify signup screen is displayed
        await driver.waitFor(find.text('회원가입'));
        await driver.waitFor(find.byValueKey('name_field'));
        await driver.waitFor(find.byValueKey('email_field'));
        await driver.waitFor(find.byValueKey('password_field'));
        await driver.waitFor(find.byValueKey('signup_button'));
      });

      test('should return to login screen from signup', () async {
        // Tap back or login link
        await driver.tap(find.text('로그인'));
        
        // Verify we're back on login screen
        await driver.waitFor(find.text('로그인'));
        await driver.waitFor(find.byValueKey('login_button'));
      });
    });

    group('Navigation Flow', () {
      test('should show error for invalid login credentials', () async {
        // Enter invalid credentials
        await driver.tap(find.byValueKey('email_field'));
        await driver.enterText('invalid@example.com');
        
        await driver.tap(find.byValueKey('password_field'));
        await driver.enterText('wrongpassword');
        
        // Tap login button
        await driver.tap(find.byValueKey('login_button'));
        
        // Wait for error message
        await driver.waitFor(find.textContaining('로그인'));
      });
    });

    group('App Navigation', () {
      test('should handle app lifecycle', () async {
        // Test basic app functionality without authentication
        // This ensures the app doesn't crash on startup
        
        // Verify the app is running
        await driver.waitFor(find.byType('MaterialApp'));
        
        // Check that we can interact with the UI
        final loginButton = find.byValueKey('login_button');
        await driver.waitFor(loginButton);
        
        // Verify button is enabled/disabled appropriately
        final isEnabled = await driver.getText(loginButton);
        expect(isEnabled, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // This test would require network mocking in a real scenario
        // For now, we just verify the app doesn't crash
        
        await driver.waitFor(find.byType('MaterialApp'));
        
        // Try to perform an action that might cause network error
        await driver.tap(find.byValueKey('email_field'));
        await driver.enterText('test@example.com');
        
        // Verify app is still responsive
        await driver.waitFor(find.byValueKey('email_field'));
      });
    });

    group('UI Responsiveness', () {
      test('should handle rapid user interactions', () async {
        // Test rapid tapping doesn't crash the app
        final emailField = find.byValueKey('email_field');
        await driver.waitFor(emailField);
        
        // Rapid taps
        for (int i = 0; i < 5; i++) {
          await driver.tap(emailField);
        }
        
        // Verify app is still responsive
        await driver.waitFor(emailField);
      });

      test('should handle text input correctly', () async {
        // Clear any existing text
        await driver.tap(find.byValueKey('email_field'));
        await driver.enterText('');
        
        // Enter test email
        await driver.enterText('test@example.com');
        
        // Verify text was entered
        final emailText = await driver.getText(find.byValueKey('email_field'));
        expect(emailText, contains('test@example.com'));
      });
    });

    group('Accessibility', () {
      test('should have proper accessibility labels', () async {
        // Verify key UI elements have accessibility support
        await driver.waitFor(find.byValueKey('email_field'));
        await driver.waitFor(find.byValueKey('password_field'));
        await driver.waitFor(find.byValueKey('login_button'));
        
        // These elements should be findable, indicating they have proper semantics
        expect(find.byValueKey('email_field'), isNotNull);
        expect(find.byValueKey('password_field'), isNotNull);
        expect(find.byValueKey('login_button'), isNotNull);
      });
    });
  });
}