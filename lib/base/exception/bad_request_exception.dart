import 'package:azzoa_grocery/base/exception/app_exception.dart';

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}
