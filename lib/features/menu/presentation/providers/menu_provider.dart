
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/food_entity.dart';
import '../../domain/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository repository;

  MenuProvider({required this.repository});

  List<FoodEntity> _foods = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Barchasi';

  StreamSubscription<List<FoodEntity>>? _subscription;

  List<FoodEntity> get foods => _foods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final result = _foods
        .map((food) => food.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();

    result.sort();
    return ['Barchasi', ...result];
  }

  List<FoodEntity> get filteredFoods {
    if (_selectedCategory == 'Barchasi') {
      return _foods;
    }

    return _foods
        .where((food) => food.category == _selectedCategory)
        .toList();
  }

  void loadFoods() {
    _subscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = repository.getFoods().listen(
      (foods) {
        _foods = foods;
        _isLoading = false;
        _errorMessage = null;

        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = 'Barchasi';
        }

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
