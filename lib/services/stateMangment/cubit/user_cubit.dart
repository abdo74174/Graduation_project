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

  void setUser(String userId, String email, String kindOfWork,
      String? medicalSpecialist, bool isAdmin) async {
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
    emit(UserState(
      userId: userId,
      email: email,
      kindOfWork: kindOfWork,
      medicalSpecialist: medicalSpecialist,
      isAdmin: isAdmin,
    ));
  }

  void clearUser() async {
    await UserServicee().clearEmail();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('kindOfWork');
    await prefs.remove('medicalSpecialist');
    await prefs.remove('isAdmin');
    emit(UserState(
      userId: null,
      email: null,
      kindOfWork: null,
      medicalSpecialist: null,
      isAdmin: false,
    ));
  }
}
