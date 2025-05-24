import 'package:flutter/foundation.dart';
import 'package:waiter/model/menuformenucart.dart';

import '../Controllers/api_service.dart';

class CategoryProvider with ChangeNotifier {
  CategoryResponse? _categories;
  bool _isLoading = false;
  String? _error;

  CategoryResponse? get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await ApiService.fetchCategories();
      _error = null;
    } catch (e) {
      _error = ApiService.handleException(e);
      _categories = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
