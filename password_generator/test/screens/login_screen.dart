import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/domain/entities/user.dart';
import 'package:password_generator/screens/login_screen.dart';
import 'package:password_generator/screens/password_management_screen.dart';
import 'package:password_generator/services/user_service.dart';
import 'package:mocktail/mocktail.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  group('LoginScreen', () {
    late MockUserService mockUserService;

    setUp(() {
      mockUserService = MockUserService();
    });

    testWidgets('deve exibir um erro se os campos estiverem vazios',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      final usernameField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);
      final loginButton = find.byType(ElevatedButton);

      await tester.enterText(usernameField, '');
      await tester.enterText(passwordField, '');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Preencha todos os campos.'), findsOneWidget);
    });

    testWidgets('deve exibir carregando durante o login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      final usernameField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);
      final loginButton = find.byType(ElevatedButton);

      await tester.enterText(usernameField, 'user');
      await tester.enterText(passwordField, 'password');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir mensagem de erro se o login falhar',
        (WidgetTester tester) async {
      when(() => mockUserService.getUsers()).thenAnswer(
        (_) async => [
          User(id: '1', username: 'user', password: 'password123'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      final usernameField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);
      final loginButton = find.byType(ElevatedButton);

      await tester.enterText(usernameField, 'user');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Nome de usuário ou senha inválidos.'), findsOneWidget);
    });

    testWidgets(
        'deve navegar para a tela de gerenciamento de senhas se o login for bem-sucedido',
        (WidgetTester tester) async {
      when(() => mockUserService.getUsers()).thenAnswer(
        (_) async => [
          User(id: '1', username: 'user', password: 'password'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      final usernameField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);
      final loginButton = find.byType(ElevatedButton);

      await tester.enterText(usernameField, 'user');
      await tester.enterText(passwordField, 'password');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(
        find.byType(PasswordManagementScreen),
        findsOneWidget,
      );
    });
  });
}
