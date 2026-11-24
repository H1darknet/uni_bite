
import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderHistoryProvider extends ChangeNotifier {
  final OrderRepository repository;

  OrderHistoryProvider({
    required this.repository,
  });

  List<OrderEntity> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<OrderEntity>>? _subscription;

  List<OrderEntity> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadOrders(String userId) {
    _subscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = repository.getUserOrders(userId).listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await repository.cancelOrder(orderId);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
