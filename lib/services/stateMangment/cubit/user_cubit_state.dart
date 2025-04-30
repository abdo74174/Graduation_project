class UserState {
  final String? email;
  final String? kindOfWork;
  final String? medicalSpecialist;
  final bool isAdmin;

  UserState({
    this.email,
    this.kindOfWork,
    this.medicalSpecialist,
    required this.isAdmin,
  });

  UserState copyWith({
    String? email,
    String? kindOfWork,
    String? medicalSpecialist,
    bool? isAdmin,
  }) {
    return UserState(
      email: email ?? this.email,
      kindOfWork: kindOfWork ?? this.kindOfWork,
      medicalSpecialist: medicalSpecialist ?? this.medicalSpecialist,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
