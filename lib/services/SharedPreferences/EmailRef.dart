import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/elivery_person_service.dart';

class UserServicee {
  Future<void> saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      print('Email saved: $email');
    } catch (e, stackTrace) {
      print('Error saving email: $e\n$stackTrace');
    }
  }

  Future<String?> getEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      print('Retrieved email: $email');
      return email;
    } catch (e, stackTrace) {
      print('Error retrieving email: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> clearEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      print('Email cleared');
    } catch (e, stackTrace) {
      print('Error clearing email: $e\n$stackTrace');
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      print('Retrieved userId: $userId');
      return userId;
    } catch (e, stackTrace) {
      print('Error retrieving userId: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      print('UserId saved: $userId');
    } catch (e, stackTrace) {
      print('Error saving userId: $e\n$stackTrace');
    }
  }

  Future<void> clearUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      print('UserId cleared');
    } catch (e, stackTrace) {
      print('Error clearing userId: $e\n$stackTrace');
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (email.isEmpty || password.isEmpty) {
        print('Login failed: Email or password is empty');
        return false;
      }
      print('Login successful for email: $email');
      return true;
    } catch (e, stackTrace) {
      print('Error during login: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> saveDeliveryPersonProfile(
      DeliveryPersonRequestModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('delivery_phone', profile.phone);
      await prefs.setString('delivery_address', profile.address);
      await prefs.setString('delivery_cardNumber', profile.cardNumber);
      await prefs.setString(
          'delivery_requestStatus', profile.requestStatus ?? '');
      await prefs.setBool('delivery_isAvailable', profile.isAvailable ?? false);
      await prefs.setString(
          'delivery_userId', profile.userId?.toString() ?? '');
      await prefs.setString('delivery_name', profile.name ?? '');
      await prefs.setString('delivery_email', profile.email ?? '');
      print('Delivery person profile saved for userId: ${profile.userId}');
    } catch (e, stackTrace) {
      print('Error saving delivery person profile: $e\n$stackTrace');
    }
  }

  Future<DeliveryPersonRequestModel?> getDeliveryPersonProfile() async {
    try {
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
        print('Retrieved delivery person profile for userId: $userId');
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
      print('No delivery person profile found');
      return null;
    } catch (e, stackTrace) {
      print('Error retrieving delivery person profile: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> clearDeliveryPersonProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('delivery_phone');
      await prefs.remove('delivery_address');
      await prefs.remove('delivery_cardNumber');
      await prefs.remove('delivery_requestStatus');
      await prefs.remove('delivery_isAvailable');
      await prefs.remove('delivery_userId');
      await prefs.remove('delivery_name');
      await prefs.remove('delivery_email');
      print('Delivery person profile cleared');
    } catch (e, stackTrace) {
      print('Error clearing delivery person profile: $e\n$stackTrace');
    }
  }

  Future<void> saveJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      print('JWT token saved');
    } catch (e, stackTrace) {
      print('Error saving JWT token: $e\n$stackTrace');
    }
  }

  Future<String?> getJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      print('Retrieved JWT token: $token');
      return token;
    } catch (e, stackTrace) {
      print('Error retrieving JWT token: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> clearJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      print('JWT token cleared');
    } catch (e, stackTrace) {
      print('Error clearing JWT token: $e\n$stackTrace');
    }
  }
}
