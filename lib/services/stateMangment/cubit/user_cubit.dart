import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/components/home_page/drawer.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';

class UserCubit extends Cubit<String?> {
  UserCubit() : super(null);

  void setEmail(String email) async {
    await UserService().saveEmail(email); // Save email to SharedPreferences
    emit(email);
  }

  void clearEmail() async {
    await UserService().clearEmail(); // Remove email from SharedPreferences
    emit(null);
  }
}
