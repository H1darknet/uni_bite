
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<void> call(OrderEntity order) async {
    if (order.items.isEmpty) {
      throw Exception('Savat bo‘sh. Buyurtma berib bo‘lmaydi.');
    }

    if (order.userId.isEmpty) {
      throw Exception('Foydalanuvchi aniqlanmadi.');
    }

    if (order.totalAmount <= 0) {
      throw Exception('Buyurtma summasi noto‘g‘ri.');
    }

    if (order.pickupAt.isBefore(DateTime.now())) {
      throw Exception('Olib ketish vaqti noto‘g‘ri.');
    }

    await repository.createOrder(order);
  }
}
