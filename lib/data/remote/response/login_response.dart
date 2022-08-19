import 'package:azzoa_grocery/constants.dart';

class LoginResponse {
  final String token;
  final String tokenType;
  final String emailVerifiedAt;
  final String phoneVerifiedAt;

  LoginResponse({
    this.token,
    this.tokenType,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> bodyObject = json[kKeyData][kKeyJsonObject];

    String token = kDefaultString;
    String tokenType = kDefaultString;
    String emailVerifiedAt;
    String phoneVerifiedAt;

    if (bodyObject.containsKey(kKeyToken)) {
      token = bodyObject[kKeyToken];
    }

    if (bodyObject.containsKey(kKeyTokenType)) {
      tokenType = bodyObject[kKeyTokenType];
    }

    if (bodyObject.containsKey(kKeyEmailVerifiedAt)) {
      emailVerifiedAt = bodyObject[kKeyEmailVerifiedAt];
    }

    if (bodyObject.containsKey(kKeyPhoneVerifiedAt)) {
      phoneVerifiedAt = bodyObject[kKeyPhoneVerifiedAt];
    }

    return LoginResponse(
      token: token,
      tokenType: tokenType,
      emailVerifiedAt: emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt,
    );
  }
}
