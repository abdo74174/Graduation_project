import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/elivery_person_service.dart';

class UserServicee {
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && password.isNotEmpty;
  }

  // New method to save delivery person profile
  Future<void> saveDeliveryPersonProfile(
      DeliveryPersonRequestModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_phone', profile.phone);
    await prefs.setString('delivery_address', profile.address);
    await prefs.setString('delivery_cardNumber', profile.cardNumber);
    await prefs.setString(
        'delivery_requestStatus', profile.requestStatus ?? '');
    await prefs.setBool('delivery_isAvailable', profile.isAvailable ?? false);
    await prefs.setString('delivery_userId', profile.userId?.toString() ?? '');
    await prefs.setString('delivery_name', profile.name ?? '');
    await prefs.setString('delivery_email', profile.email ?? '');
  }

  // New method to retrieve delivery person profile
  Future<DeliveryPersonRequestModel?> getDeliveryPersonProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('delivery_phone');
    final address = prefs.getString('delivery_address');
    final cardNumber = prefs.getString('delivery_cardNumber');
    final requestStatus = prefs.getString('delivery_requestStatus');
    final isAvailable = prefs.getBool('delivery_isAvailable');
    final userId = prefs.getString('delivery_userId');
    final name = prefs.getString('delivery_name');
    final email = prefs.getString('delivery_email');

    if (phone != null &&
        address != null &&
        cardNumber != null &&
        userId != null &&
        name != null &&
        email != null) {
      return DeliveryPersonRequestModel(
        phone: phone,
        address: address,
        cardNumber: cardNumber,
        requestStatus: requestStatus,
        isAvailable: isAvailable,
        userId: int.tryParse(userId),
        name: name,
        email: email,
      );
    }
    return null;
  }

  // New method to clear delivery person profile
  Future<void> clearDeliveryPersonProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('delivery_phone');
    await prefs.remove('delivery_address');
    await prefs.remove('delivery_cardNumber');
    await prefs.remove('delivery_requestStatus');
    await prefs.remove('delivery_isAvailable');
    await prefs.remove('delivery_userId');
    await prefs.remove('delivery_name');
    await prefs.remove('delivery_email');
  }

  // New method to save JWT token
  Future<void> saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // New method to retrieve JWT token
  Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // New method to clear JWT token
  Future<void> clearJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
