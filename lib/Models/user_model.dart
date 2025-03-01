enum UserRole { buyer, seller, both }

// @JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String address;
  final UserRole role;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.address,
    this.role = UserRole.both,
    this.profileImage,
  });
}

//   factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
//   Map<String, dynamic> toJson() => _$UserModelToJson(this);
// }
