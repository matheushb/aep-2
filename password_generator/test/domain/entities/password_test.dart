import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/domain/entities/password.dart';

void main() {
  group('Password Entity', () {
    test('deve criar Password a partir de um JSON', () {
      final json = {
        'id': '1',
        'userId': 'user1',
        'password': 'senha123',
        'securityLevel': 'low',
      };

      final password = Password.fromJson(json);

      expect(password.id, '1');
      expect(password.userId, 'user1');
      expect(password.password, 'senha123');
      expect(password.securityLevel, 'low');
    });

    test('deve converter Password para JSON', () {
      final password = Password(
        id: '1',
        userId: 'user1',
        password: 'senha123',
        securityLevel: 'low',
      );

      final json = password.toJson();

      expect(json['id'], '1');
      expect(json['userId'], 'user1');
      expect(json['password'], 'senha123');
      expect(json['securityLevel'], 'low');
    });
  });
}
