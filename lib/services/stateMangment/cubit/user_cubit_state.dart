import 'package:flutter_bloc/flutter_bloc.dart';

class UserState {
  final String? userId;
  final String? email;
  final String? kindOfWork;
  final String? medicalSpecialist;
  final bool isAdmin;

  UserState({
    this.userId,
    this.email,
    this.kindOfWork,
    this.medicalSpecialist,
    required this.isAdmin,
  });

  UserState copyWith({
    String? userId,
    String? email,
    String? kindOfWork,
    String? medicalSpecialist,
    bool? isAdmin,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      kindOfWork: kindOfWork ?? this.kindOfWork,
      medicalSpecialist: medicalSpecialist ?? this.medicalSpecialist,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
