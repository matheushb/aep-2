import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('deve criar User a partir de um JSON', () {
      final json = {
        'id': '1',
        'username': 'user1',
        'password': 'senha123',
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.username, 'user1');
      expect(user.password, 'senha123');
    });

    test('deve converter User para JSON', () {
      final user = User(
        id: '1',
        username: 'user1',
        password: 'senha123',
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['username'], 'user1');
      expect(json['password'], 'senha123');
    });
  });
}
