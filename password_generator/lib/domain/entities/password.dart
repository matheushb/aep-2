class Password {
  String id;
  final String userId;
  final String password;
  final String securityLevel;

  Password({
    String? id,
    required this.userId,
    required this.password,
    required this.securityLevel,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  @override
  String toString() {
    return 'Password{id: $id, userId: $userId, securityLevel: $securityLevel}';
  }

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      id: json['id'],
      userId: json['userId'],
      password: json['password'],
      securityLevel: json['securityLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'password': password,
      'securityLevel': securityLevel,
    };
  }
}
