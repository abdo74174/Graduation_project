// // auth_cubit.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/components/state/States.dart';

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitial());

//   Future<void> register({
//     required String email,
//     required String password,
//     required String username,
//   }) async {
//     emit(AuthLoading());
//     try {
//       final credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       if (credential.user != null) {
//         emit(AuthSuccess(email: email));
//       } else {
//         emit(AuthFailure(message: "User creation failed"));
//       }
//     } on FirebaseAuthException catch (e) {
//       emit(AuthFailure(message: e.message ?? "Auth error"));
//     } catch (e) {
//       emit(AuthFailure(message: e.toString()));
//     }
//   }
// }
