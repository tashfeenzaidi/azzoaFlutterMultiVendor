import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/user.dart';

class RegistrationResponse {
  final int status;
  final String token;
  final User user;

  RegistrationResponse({
    this.status,
    this.token,
    this.user,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    String token = kDefaultString;
    User user;

    if (json.containsKey(kKeyData)) {
      Map<String, dynamic> dataMap = json[kKeyData];

      if (dataMap.containsKey(kKeyJsonObject)) {
        Map<String, dynamic> bodyMap = dataMap[kKeyJsonObject];

        if (bodyMap.containsKey(kKeyToken)) {
          token = bodyMap[kKeyToken];
        }

        user = User.fromJson(bodyMap[kKeyUser]);
      }
    }

    return RegistrationResponse(
      status: json[kKeyStatus],
      user: user,
      token: token,
    );
  }
}
