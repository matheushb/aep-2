import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_generator/domain/entities/password.dart';

class PasswordService {
  final String _url = "http://localhost:3000";
  final http.Client httpClient;

  PasswordService(this.httpClient);

  Future<List<Password>> getPasswords() async {
    final response = await httpClient.get(Uri.parse("$_url/passwords"));

    if (response.statusCode == 200) {
      final List<dynamic> passwordsJson = json.decode(response.body);
      return passwordsJson.map((json) => Password.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar senhas');
    }
  }

  Future<Password> createPassword(Password password) async {
    final response = await httpClient.post(
      Uri.parse("$_url/passwords"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(password.toJson()),
    );

    if (response.statusCode == 201) {
      return Password.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao criar senha');
    }
  }

  Future<Password> updatePasswordSecurityLevel(
      String id, String newSecurityLevel) async {
    final response = await httpClient.patch(
      Uri.parse("$_url/passwords/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"securityLevel": newSecurityLevel}),
    );

    if (response.statusCode == 200) {
      return Password.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao atualizar nível de segurança');
    }
  }

  Future<Password> updatePassword(
      String id, String newPassword, String newSecurityLevel) async {
    final response = await httpClient.patch(
      Uri.parse("$_url/passwords/$id"),
      headers: {"Content-Type": "application/json"},
      body: json
          .encode({"password": newPassword, "securityLevel": newSecurityLevel}),
    );

    if (response.statusCode == 200) {
      return Password.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao atualizar senha');
    }
  }

  Future<List<Password>> findByUserId(String userId) async {
    final response =
        await httpClient.get(Uri.parse("$_url/passwords?userId=$userId"));

    if (response.statusCode == 200) {
      final List<dynamic> passwordsJson = json.decode(response.body);
      return passwordsJson.map((json) => Password.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar senhas para o userId: $userId');
    }
  }

  Future<void> deletePassword(String id) async {
    final response = await httpClient.delete(
      Uri.parse("$_url/passwords/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir senha');
    }
  }
}
