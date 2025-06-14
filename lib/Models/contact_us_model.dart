class ContactUsModel {
  final int id;
  final String problemType;
  final String message;
  final String? email;
  final DateTime createdAt;
  final int UserId;
  ContactUsModel({
    required this.id,
    required this.problemType,
    required this.message,
    this.email,
    required this.UserId,
    required this.createdAt,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      UserId: json['UserId'],
      id: json['id'],
      problemType: json['problemType'],
      message: json['message'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'problemType': problemType,
      'message': message,
      'UserId': UserId,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
