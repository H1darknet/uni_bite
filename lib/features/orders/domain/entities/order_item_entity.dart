
class OrderItemEntity {
  final String foodId;
  final String foodName;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderItemEntity({
    required this.foodId,
    required this.foodName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}
