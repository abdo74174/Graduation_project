class RefreshToken {
  final int id;
  final String? token;
  final int userId;
  final DateTime expiryDate;
  final String? role;

  RefreshToken({
    required this.id,
    this.token,
    required this.userId,
    required this.expiryDate,
    this.role,
  });

  // factory RefreshToken.fromJson(Map<String, dynamic> json) {
  //   return RefreshToken(
  //     id: json['id'],
  //     token: json['token'],
  //     userId: json['userId'],
  //     expiryDate: DateTime.parse(json['expiryDate']),
  //     role: json['role'],
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'token': token,
  //     'userId': userId,
  //     'expiryDate': expiryDate.toIso8601String(),
  //     'role': role,
  //   };
  // }
}
