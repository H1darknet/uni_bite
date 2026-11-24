
import '../entities/order_entity.dart';

abstract class OrderRepository {
  // Yangi buyurtmani saqlash
  Future<void> createOrder(OrderEntity order);

  // Foydalanuvchining barcha buyurtmalarini olish
  Stream<List<OrderEntity>> getUserOrders(String userId);

  // Bitta buyurtmani ID orqali olish
  Future<OrderEntity?> getOrderById(String orderId);

  // Buyurtma holatini yangilash
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  });

  // Buyurtmani bekor qilish
  Future<void> cancelOrder(String orderId);
}
