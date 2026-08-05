import 'package:flutter/foundation.dart';

class AuthLoadingService extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  void startLoading() {
    _loading = true;
    notifyListeners();
  }

  void stopLoading() {
    _loading = false;
    notifyListeners();
  }
}
