import 'package:flutter/foundation.dart';
import 'package:waiter/model/menuformenucart.dart';
import '../Controllers/api_service.dart';

class MenuProvider with ChangeNotifier {
  MenuResponse? _menu;
  bool _isLoading = false;
  String? _error;

  MenuResponse? get menu => _menu;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTodaysMenu() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menu = await ApiService.fetchTodaysMenu();
      _error = null;
    } catch (e) {
      _error = ApiService.handleException(e);
      _menu = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
