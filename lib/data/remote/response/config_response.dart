import 'package:azzoa_grocery/data/remote/model/app_info.dart';

class ConfigResponse {
  final AppConfig appConfig;

  ConfigResponse({
    this.appConfig,
  });

  factory ConfigResponse.fromJson(Map<String, dynamic> json) {
    return ConfigResponse(
      appConfig: AppConfig.fromJson(json),
    );
  }
}
