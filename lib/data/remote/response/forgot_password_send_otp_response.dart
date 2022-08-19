import 'package:azzoa_grocery/constants.dart';

class ForgotPasswordSendOtpResponse {
  final int status;
  final String message;

  ForgotPasswordSendOtpResponse({
    this.status,
    this.message,
  });

  factory ForgotPasswordSendOtpResponse.fromJson(Map<String, dynamic> json) {
    String message = kDefaultString;

    if (json.containsKey(kKeyData)) {
      Map<String, dynamic> dataMap = json[kKeyData];

      if (dataMap.containsKey(kKeyStringData)) {
        message = dataMap[kKeyStringData];
      }
    }

    return ForgotPasswordSendOtpResponse(
      status: json[kKeyStatus],
      message: message,
    );
  }
}
