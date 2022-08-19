import 'package:azzoa_grocery/constants.dart';

class ResetPasswordResponse {
  final int status;
  final String message;

  ResetPasswordResponse({
    this.status,
    this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    String message = kDefaultString;

    if (json.containsKey(kKeyData)) {
      Map<String, dynamic> dataMap = json[kKeyData];

      if (dataMap.containsKey(kKeyStringData)) {
        message = dataMap[kKeyStringData];
      }
    }

    return ResetPasswordResponse(
      status: json[kKeyStatus],
      message: message,
    );
  }
}
