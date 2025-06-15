// class DeliveryPersonRequestModel {
//   String phone;
//   String address;
//   String cardNumber;
//   String? requestStatus;
//   bool? isAvailable;
//   int? userId;

//   DeliveryPersonRequestModel({
//     this.phone = '',
//     this.address = '',
//     this.cardNumber = '',
//     this.requestStatus,
//     this.isAvailable,
//     this.userId,
//   });

//   factory DeliveryPersonRequestModel.fromJson(Map<String, dynamic> json) {
//     return DeliveryPersonRequestModel(
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       cardNumber: json['cardNumber'] ?? '',
//       requestStatus: json['requestStatus'],
//       isAvailable: json['isAvailable'] as bool?,
//       userId: (json['userId'] is int)
//           ? json['userId']
//           : int.tryParse(json['userId']?.toString() ?? '0'),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'phone': phone,
//       'address': address,
//       'cardNumber': cardNumber,
//       'requestStatus': requestStatus,
//       'isAvailable': isAvailable,
//       'userId': userId,
//     };
//   }

//   @override
//   String toString() {
//     return 'DeliveryPersonRequestModel(phone: $phone, address: $address, cardNumber: $cardNumber, requestStatus: $requestStatus, isAvailable: $isAvailable, userId: $userId)';
//   }
// }
