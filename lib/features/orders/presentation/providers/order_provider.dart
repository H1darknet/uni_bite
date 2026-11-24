
import 'package:flutter/material.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order.dart';

class OrderProvider extends ChangeNotifier {
  final CreateOrder createOrderUseCase;

  OrderProvider({
    required this.createOrderUseCase,
  });

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  Future<bool> create(OrderEntity order) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await createOrderUseCase(order);

      _isSuccess = true;
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetState() {
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
