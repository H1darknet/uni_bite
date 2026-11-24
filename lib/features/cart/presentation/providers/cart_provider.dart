import 'package:flutter/material.dart';

import '../../domain/entities/cart_item.dart';
import '../../../menu/domain/entities/food_entity.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Savatdagi barcha mahsulotlar
  List<CartItem> get items => List.unmodifiable(_items);

  // Savatdagi mahsulotlar soni
  int get totalQuantity {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  // Savatning umumiy narxi
  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  // Savatga taom qo‘shish
  void addToCart(FoodEntity food) {
    if (!food.isAvailable) return;

    final index = _items.indexWhere(
      (item) => item.food.id == food.id,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItem(food: food),
      );
    }

    notifyListeners();
  }

  // Taom miqdorini oshirish
  void increaseQuantity(String foodId) {
    final index = _items.indexWhere(
      (item) => item.food.id == foodId,
    );

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Taom miqdorini kamaytirish
  void decreaseQuantity(String foodId) {
    final index = _items.indexWhere(
      (item) => item.food.id == foodId,
    );

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  // Taomni savatdan butunlay o‘chirish
  void removeFromCart(String foodId) {
    _items.removeWhere(
      (item) => item.food.id == foodId,
    );

    notifyListeners();
  }

  // Savatni tozalash
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}