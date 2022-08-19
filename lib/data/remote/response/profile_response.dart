import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/my_profile.dart';

class ProfileResponse {
  final int status;
  final MyProfile data;

  ProfileResponse({
    this.status,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json[kKeyStatus],
      data: MyProfile.fromJson(json[kKeyData]),
    );
  }
}
