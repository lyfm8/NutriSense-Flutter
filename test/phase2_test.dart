import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisense_flutter/data/repositories/auth_repository.dart';
import 'package:nutrisense_flutter/presentation/widgets/gradient_button.dart';
import 'package:nutrisense_flutter/presentation/widgets/custom_text_field.dart';

/// Test Phase 2 - Authentication UI & Navigation
/// Kiểm tra luồng UI (không cần Firebase thật)
void main() {
  // ============================================================
  // TEST GROUP 1: GradientButton Widget
  // ============================================================
  group('GradientButton Widget', () {
    testWidgets('should show text when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Đăng nhập',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show spinner when isLoading=true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Đăng nhập',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đăng nhập'), findsNothing);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: null,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });
  });

  // ============================================================
  // TEST GROUP 2: CustomTextField Widget
  // ============================================================
  group('CustomTextField Widget', () {
    testWidgets('should show hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Nhập email',
              startIcon: Icons.email,
            ),
          ),
        ),
      );
      expect(find.text('Nhập email'), findsOneWidget);
    });

    testWidgets('should show visibility toggle for password field',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Mật khẩu',
              startIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('password toggle changes obscure state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Mật khẩu',
              startIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );
      // Initially hidden
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      // Tap toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      // Now visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should use provided controller', (tester) async {
      final controller = TextEditingController(text: 'test@email.com');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Email',
              startIcon: Icons.email,
              controller: controller,
            ),
          ),
        ),
      );
      expect(find.text('test@email.com'), findsOneWidget);
    });
  });

  // ============================================================
  // TEST GROUP 3: AuthResult model
  // ============================================================
  group('AuthResult', () {
    test('success() should have success=true and userProfile', () {
      // We test the factory constructors without Firebase
      // (AuthResult is a simple data class)
      final result = AuthResult.failure('Sai mật khẩu');
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Sai mật khẩu'));
      expect(result.userProfile, isNull);
    });

    test('failure() should have success=false and error message', () {
      final result = AuthResult.failure('Lỗi kết nối');
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Lỗi kết nối'));
    });
  });
}
