import '../../../menu/domain/entities/food_entity.dart';

class CartItem {
  final FoodEntity food;
  int quantity;

  CartItem({
    required this.food,
    this.quantity = 1,
  });

  // Bitta taomning umumiy narxi
  double get totalPrice => food.price * quantity;
}