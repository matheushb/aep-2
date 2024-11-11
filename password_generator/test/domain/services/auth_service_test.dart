import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:password_generator/services/auth_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late AuthService authService;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost:3000'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    authService = AuthService(mockHttpClient);
  });

  group('AuthService', () {
    test('deve retornar true quando as credenciais estiverem corretas',
        () async {
      final mockResponse = [
        {'username': 'testuser', 'password': 'testpass'},
      ];
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      final result = await authService.authenticate('testuser', 'testpass');

      expect(result, true);

      verify(() => mockHttpClient
              .get(Uri.parse("http://localhost:3000/users?username=testuser")))
          .called(1);
    });

    test('deve retornar false quando o nome de usuário estiver incorreto',
        () async {
      final mockResponse = [
        {'username': 'testuser', 'password': 'testpass'},
      ];
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      final result = await authService.authenticate('wronguser', 'testpass');

      expect(result, false);
      verify(() => mockHttpClient
              .get(Uri.parse("http://localhost:3000/users?username=wronguser")))
          .called(1);
    });

    test('deve retornar false quando a senha estiver incorreta', () async {
      final mockResponse = [
        {'username': 'testuser', 'password': 'testpass'},
      ];
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      final result = await authService.authenticate('testuser', 'wrongpass');

      expect(result, false);
      verify(() => mockHttpClient
              .get(Uri.parse("http://localhost:3000/users?username=testuser")))
          .called(1);
    });

    test('deve retornar false quando a resposta for inválida', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('[]', 200),
      );

      final result = await authService.authenticate('testuser', 'testpass');

      expect(result, false);
      verify(() => mockHttpClient
              .get(Uri.parse("http://localhost:3000/users?username=testuser")))
          .called(1);
    });

    test('deve retornar false quando o status da resposta não for 200',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      final result = await authService.authenticate('testuser', 'testpass');

      expect(result, false);
      verify(() => mockHttpClient
              .get(Uri.parse("http://localhost:3000/users?username=testuser")))
          .called(1);
    });
  });
}
