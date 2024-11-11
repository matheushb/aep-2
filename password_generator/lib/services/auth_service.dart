import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _url = "http://localhost:3000";
  final http.Client httpClient;

  AuthService(this.httpClient);

  Future<bool> authenticate(String username, String password) async {
    final response =
        await httpClient.get(Uri.parse("$_url/users?username=$username"));

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      for (var user in users) {
        if (user['username'] == username && user['password'] == password) {
          return true;
        }
      }
    }

    return false;
  }
}
