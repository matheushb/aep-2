import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_generator/domain/entities/user.dart';

class UserService {
  final String _url = "http://localhost:3000";
  final http.Client httpClient;

  UserService(this.httpClient);

  Future<List<User>> getUsers() async {
    final response = await httpClient.get(Uri.parse("$_url/users"));

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }

  Future<User> createUser(User user) async {
    final response = await httpClient.post(
      Uri.parse("$_url/users"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao criar usuário');
    }
  }

  Future<User> findById(String id) async {
    final response = await httpClient.get(Uri.parse("$_url/users/$id"));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Usuário não encontrado');
    }
  }
}
