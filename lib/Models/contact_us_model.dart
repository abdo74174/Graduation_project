class ContactUsModel {
  final String problemType;
  final String message;
  final String? email;

  ContactUsModel({
    required this.problemType,
    required this.message,
    this.email,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      problemType: json['problemType'] ?? '',
      message: json['message'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemType': problemType,
      'message': message,
      'email': email,
    };
  }
}
