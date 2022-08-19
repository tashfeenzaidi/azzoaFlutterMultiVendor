import 'package:azzoa_grocery/base/exception/app_exception.dart';

class NoConnectionException extends AppException {
  NoConnectionException() : super("Please check your internet connection");
}
