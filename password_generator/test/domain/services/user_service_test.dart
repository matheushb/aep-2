import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:password_generator/domain/entities/user.dart';
import 'package:password_generator/services/user_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late UserService userService;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost:3000'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    userService = UserService(mockHttpClient);
  });

  group('UserService', () {
    test(
        'deve retornar uma lista de usuários quando a requisição for bem-sucedida',
        () async {
      final mockResponse = [
        {'id': '1', 'username': 'user1', 'password': 'password1'},
        {'id': '2', 'username': 'user2', 'password': 'password2'},
      ];

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      final result = await userService.getUsers();

      expect(result, isA<List<User>>());
      expect(result.length, 2);
      expect(result[0].username, 'user1');
      expect(result[1].username, 'user2');

      verify(() => mockHttpClient.get(Uri.parse("http://localhost:3000/users")))
          .called(1);
    });

    test('deve lançar uma exceção quando a requisição falhar', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      expect(() => userService.getUsers(), throwsException);
      verify(() => mockHttpClient.get(Uri.parse("http://localhost:3000/users")))
          .called(1);
    });

    test('deve criar um usuário quando a requisição for bem-sucedida',
        () async {
      final user = User(id: '1', username: 'newuser', password: 'newpass');
      final mockResponse = {
        'id': '1',
        'username': 'newuser',
        'password': 'newpass'
      };

      when(() => mockHttpClient.post(any(),
          headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 201),
      );

      final result = await userService.createUser(user);

      expect(result, isA<User>());
      expect(result.username, 'newuser');
      verify(() => mockHttpClient.post(
            Uri.parse("http://localhost:3000/users"),
            headers: {"Content-Type": "application/json"},
            body: json.encode(user.toJson()),
          )).called(1);
    });

    test('deve lançar uma exceção quando falhar ao criar um usuário', () async {
      final user = User(id: '1', username: 'newuser', password: 'newpass');

      when(() => mockHttpClient.post(any(),
          headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      expect(() => userService.createUser(user), throwsException);
      verify(() => mockHttpClient.post(
            Uri.parse("http://localhost:3000/users"),
            headers: {"Content-Type": "application/json"},
            body: json.encode(user.toJson()),
          )).called(1);
    });

    test('deve retornar um usuário quando encontrado pelo ID', () async {
      final mockResponse = {
        'id': '1',
        'username': 'user1',
        'password': 'password1'
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      final result = await userService.findById('1');

      expect(result, isA<User>());
      expect(result.username, 'user1');
      verify(() =>
              mockHttpClient.get(Uri.parse("http://localhost:3000/users/1")))
          .called(1);
    });

    test('deve lançar uma exceção quando o usuário não for encontrado',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 404),
      );

      expect(() => userService.findById('1'), throwsException);
      verify(() =>
              mockHttpClient.get(Uri.parse("http://localhost:3000/users/1")))
          .called(1);
    });
  });
}
