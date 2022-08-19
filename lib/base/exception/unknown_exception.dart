import 'package:azzoa_grocery/base/exception/app_exception.dart';

class UnknownException extends AppException {
  UnknownException([String message]) : super(message, "Error: ");
}
