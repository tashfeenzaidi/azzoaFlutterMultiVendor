import 'package:azzoa_grocery/data/remote/model/app_info.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AppConfigNotifier extends ChangeNotifier {
  AppConfig _appConfig;

  AppConfig get appConfig => _appConfig;

  void setAppConfig(AppConfig config) {
    _appConfig = config;
    notifyListeners();
  }

  Position _currentLocation;

  Position get currentLocation => _currentLocation;

  void setCurrentLocation(Position location) {
    _currentLocation = location;
    notifyListeners();
  }
}
