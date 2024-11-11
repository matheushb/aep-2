import 'package:flutter/material.dart';
import 'package:password_generator/domain/entities/user.dart';
import 'package:password_generator/services/password_service.dart';
import 'package:password_generator/domain/entities/password.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class PasswordManagementScreen extends StatefulWidget {
  final User user;

  PasswordManagementScreen({required this.user});

  @override
  _PasswordManagementScreenState createState() =>
      _PasswordManagementScreenState();
}

class _PasswordManagementScreenState extends State<PasswordManagementScreen> {
  final PasswordService passwordService = PasswordService(http.Client());
  List<Password> passwords = [];
  Map<String, bool> passwordVisibility = {};
  bool isLoading = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  void _loadPasswords() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<Password> loadedPasswords =
          await passwordService.findByUserId(widget.user.id);
      setState(() {
        passwords = loadedPasswords;
        passwordVisibility = {for (var p in loadedPasswords) p.id: false};
      });
    } catch (e) {
      _showError('Erro ao carregar senhas');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _togglePasswordVisibility(String id) {
    setState(() {
      passwordVisibility[id] = !passwordVisibility[id]!;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updatePasswordSecurityLevel(String id, String newSecurityLevel) async {
    try {
      final updatedPassword = await passwordService.updatePasswordSecurityLevel(
          id, newSecurityLevel);
      setState(() {
        final index = passwords.indexWhere((p) => p.id == id);
        if (index != -1) {
          passwords[index] = updatedPassword;
        }
      });
    } catch (e) {
      _showError('Erro ao atualizar nível de segurança');
    }
  }

  String _generateStrongPassword() {
    const allChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*(),.?":{}|<>';
    final random = Random();
    const passwordLength = 12;
    String password = '';

    bool hasUpper = false;
    bool hasLower = false;
    bool hasDigit = false;
    bool hasSpecial = false;

    while (!(hasUpper && hasLower && hasDigit && hasSpecial)) {
      password = '';
      hasUpper = false;
      hasLower = false;
      hasDigit = false;
      hasSpecial = false;

      for (int i = 0; i < passwordLength; i++) {
        final char = allChars[random.nextInt(allChars.length)];
        password += char;

        if (RegExp(r'[A-Z]').hasMatch(char)) hasUpper = true;
        if (RegExp(r'[a-z]').hasMatch(char)) hasLower = true;
        if (RegExp(r'[0-9]').hasMatch(char)) hasDigit = true;
        if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(char)) hasSpecial = true;
      }
    }

    return password;
  }

  void _addNewPassword() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String password = '';
        String securityLevel = 'Baixa';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Nova Senha'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _passwordController,
                    onChanged: (value) {
                      password = value.trim();
                      securityLevel = _calculateSecurityLevel(password);
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: 'Digite a senha',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nível de Segurança: $securityLevel',
                    style: TextStyle(
                      color: _getSecurityColor(securityLevel),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      String generatedPassword = _generateStrongPassword();
                      password = generatedPassword;
                      _passwordController.text = generatedPassword;
                      securityLevel = _calculateSecurityLevel(password);
                      setState(() {});
                    },
                    child: const Text('Gerar Senha Forte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        if (password.isNotEmpty) {
                          final newPassword = Password(
                            password: password,
                            userId: widget.user.id,
                            securityLevel: securityLevel,
                          );

                          try {
                            await passwordService.createPassword(newPassword);
                            _showError('Senha adicionada com sucesso');
                            _loadPasswords();
                          } catch (e) {
                            _showError('Erro ao adicionar senha');
                          }
                          Navigator.of(context).pop();
                        } else {
                          _showError('Senha não pode ser vazia');
                        }
                      },
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getSecurityColor(String securityLevel) {
    switch (securityLevel) {
      case 'Alta':
        return Colors.green;
      case 'Media':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  void _deletePassword(String passwordId) async {
    try {
      await passwordService.deletePassword(passwordId);
      _showError('Senha deletada com sucesso');
      _loadPasswords();
    } catch (e) {
      _showError('Erro ao deletar senha');
    }
  }

  String _calculateSecurityLevel(String password) {
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChars =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    final lengthCriteria = password.length >= 8;

    if (hasUpperCase &&
        hasLowerCase &&
        hasDigits &&
        hasSpecialChars &&
        lengthCriteria) {
      return 'Alta';
    } else if ((hasUpperCase || hasLowerCase) &&
        (hasDigits || hasSpecialChars) &&
        lengthCriteria) {
      return 'Media';
    } else {
      return 'Baixa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciamento de Senhas')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final password = passwords[index];
                      final isVisible =
                          passwordVisibility[password.id] ?? false;
                      final securityColor =
                          _getSecurityColor(password.securityLevel);

                      return ListTile(
                        title: Text(
                          isVisible ? password.password : '••••••••',
                          style: TextStyle(color: securityColor),
                        ),
                        subtitle: Text(
                          'Nível de Segurança: ${password.securityLevel}',
                          style: TextStyle(color: securityColor),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                _togglePasswordVisibility(password.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deletePassword(password.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _addNewPassword,
                    child: const Text('Adicionar Nova Senha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
