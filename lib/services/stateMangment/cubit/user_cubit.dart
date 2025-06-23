import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit()
      : super(UserState(
          userId: null,
          email: null,
          kindOfWork: null,
          medicalSpecialist: null,
          isAdmin: false,
        ));

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final email = await UserServicee().getEmail();
      final kindOfWork = prefs.getString('kindOfWork');
      final medicalSpecialist = prefs.getString('medicalSpecialist');
      final isAdmin = prefs.getBool('isAdmin') ?? false;

      print('Loaded user data: userId=$userId, email=$email, isAdmin=$isAdmin');
      emit(UserState(
        userId: userId,
        email: email,
        kindOfWork: kindOfWork,
        medicalSpecialist: medicalSpecialist,
        isAdmin: isAdmin,
      ));
    } catch (e, stackTrace) {
      print('Error loading user data: $e\n$stackTrace');
    }
  }

  void setUser(String userId, String email, String kindOfWork,
      String? medicalSpecialist, bool isAdmin) async {
    try {
      await UserServicee().saveEmail(email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('kindOfWork', kindOfWork);
      if (medicalSpecialist != null) {
        await prefs.setString('medicalSpecialist', medicalSpecialist);
      } else {
        await prefs.remove('medicalSpecialist');
      }
      await prefs.setBool('isAdmin', isAdmin);
      print('User set: userId=$userId, email=$email, isAdmin=$isAdmin');
      emit(UserState(
        userId: userId,
        email: email,
        kindOfWork: kindOfWork,
        medicalSpecialist: medicalSpecialist,
        isAdmin: isAdmin,
      ));
    } catch (e, stackTrace) {
      print('Error setting user: $e\n$stackTrace');
    }
  }

  void clearUser() async {
    try {
      await UserServicee().clearEmail();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('kindOfWork');
      await prefs.remove('medicalSpecialist');
      await prefs.remove('isAdmin');
      print('User cleared');
      emit(UserState(
        userId: null,
        email: null,
        kindOfWork: null,
        medicalSpecialist: null,
        isAdmin: false,
      ));
    } catch (e, stackTrace) {
      print('Error clearing user: $e\n$stackTrace');
    }
  }
}
