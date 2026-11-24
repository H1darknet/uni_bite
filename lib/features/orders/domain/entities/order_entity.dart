
import 'order_item_entity.dart';

class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final DateTime pickupAt;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.pickupAt,
    required this.paymentMethod,
    this.paymentStatus = 'unpaid',
    this.status = 'pending',
    required this.createdAt,
  });
}
