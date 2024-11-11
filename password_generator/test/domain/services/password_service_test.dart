import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:password_generator/domain/entities/password.dart';
import 'package:password_generator/services/password_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late PasswordService passwordService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    passwordService = PasswordService(mockClient);
  });

  group('PasswordService', () {
    test('deve retornar lista de senhas ao chamar getPasswords', () async {
      final mockResponse = [
        {
          "id": "1",
          "password": "senha123",
          "securityLevel": "low",
          "userId": "user1"
        },
        {
          "id": "2",
          "password": "senha456",
          "securityLevel": "medium",
          "userId": "user2"
        }
      ];

      when(() => mockClient.get(Uri.parse('http://localhost:3000/passwords')))
          .thenAnswer(
              (_) async => http.Response(json.encode(mockResponse), 200));

      final result = await passwordService.getPasswords();

      expect(result, isA<List<Password>>());
      expect(result.length, 2);
      expect(result[0].password, 'senha123');
    });

    test('deve lançar exceção ao falhar ao carregar senhas', () async {
      when(() => mockClient.get(Uri.parse('http://localhost:3000/passwords')))
          .thenAnswer((_) async => http.Response('Erro', 500));

      expect(() => passwordService.getPasswords(), throwsException);
    });

    test('deve criar senha com sucesso', () async {
      final passwordToCreate = Password(
        id: '3',
        password: 'novaSenha123',
        securityLevel: 'high',
        userId: 'user1',
      );

      final mockResponse = {
        "id": "3",
        "password": "novaSenha123",
        "securityLevel": "high",
        "userId": "user1"
      };

      when(() => mockClient.post(
                Uri.parse('http://localhost:3000/passwords'),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              ))
          .thenAnswer(
              (_) async => http.Response(json.encode(mockResponse), 201));

      final result = await passwordService.createPassword(passwordToCreate);

      expect(result, isA<Password>());
      expect(result.password, 'novaSenha123');
    });

    test('deve lançar exceção ao falhar ao criar senha', () async {
      final passwordToCreate = Password(
        id: '3',
        password: 'novaSenha123',
        securityLevel: 'high',
        userId: 'user1',
      );

      when(() => mockClient.post(
            Uri.parse('http://localhost:3000/passwords'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Erro', 500));

      expect(() => passwordService.createPassword(passwordToCreate),
          throwsException);
    });

    test('deve atualizar o nível de segurança da senha com sucesso', () async {
      final mockResponse = {
        "id": "1",
        "password": "senha123",
        "securityLevel": "high",
        "userId": "user1"
      };

      when(() => mockClient.patch(
                Uri.parse('http://localhost:3000/passwords/1'),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              ))
          .thenAnswer(
              (_) async => http.Response(json.encode(mockResponse), 200));

      final result =
          await passwordService.updatePasswordSecurityLevel('1', 'high');

      expect(result, isA<Password>());
      expect(result.securityLevel, 'high');
    });

    test('deve lançar exceção ao falhar ao atualizar o nível de segurança',
        () async {
      when(() => mockClient.patch(
            Uri.parse('http://localhost:3000/passwords/1'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Erro', 500));

      expect(() => passwordService.updatePasswordSecurityLevel('1', 'high'),
          throwsException);
    });

    test('deve excluir senha com sucesso', () async {
      when(() =>
              mockClient.delete(Uri.parse('http://localhost:3000/passwords/1')))
          .thenAnswer((_) async => http.Response('OK', 200));

      await passwordService.deletePassword('1');

      verify(() =>
              mockClient.delete(Uri.parse('http://localhost:3000/passwords/1')))
          .called(1);
    });

    test('deve lançar exceção ao falhar ao excluir senha', () async {
      when(() =>
              mockClient.delete(Uri.parse('http://localhost:3000/passwords/1')))
          .thenAnswer((_) async => http.Response('Erro', 500));

      expect(() => passwordService.deletePassword('1'), throwsException);
    });
  });
}
