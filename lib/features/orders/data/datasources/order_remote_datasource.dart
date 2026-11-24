
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore firestore;

  OrderRemoteDataSource({
    required this.firestore,
  });

  // Yangi buyurtmani Firestore bazasiga saqlash
  Future<void> createOrder(OrderModel order) async {
    await firestore
        .collection('orders')
        .doc(order.id)
        .set(order.toMap());
  }

  // Foydalanuvchining buyurtmalarini real vaqtda kuzatish
  // Foydalanuvchining buyurtmalarini real vaqtda kuzatish
Stream<List<OrderModel>> getUserOrders(String userId) {
  return firestore
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    final orders = snapshot.docs.map((doc) {
      return OrderModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    // Buyurtmalarni yangisidan eskisiga saralash
    orders.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return orders;
  });
}

  // ID orqali bitta buyurtmani olish
  Future<OrderModel?> getOrderById(String orderId) async {
    final document = await firestore
        .collection('orders')
        .doc(orderId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return OrderModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  // Buyurtma holatini yangilash
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await firestore
        .collection('orders')
        .doc(orderId)
        .update({
      'status': status,
    });
  }

  // Faqat pending holatidagi buyurtmani bekor qilish
  Future<void> cancelOrder(String orderId) async {
    final orderReference = firestore
        .collection('orders')
        .doc(orderId);

    await firestore.runTransaction((transaction) async {
      final document = await transaction.get(orderReference);

      if (!document.exists) {
        throw Exception('Buyurtma topilmadi');
      }

      final currentStatus = document.data()?['status'];

      if (currentStatus != 'pending') {
        throw Exception(
          'Faqat kutilayotgan buyurtmani bekor qilish mumkin',
        );
      }

      transaction.update(orderReference, {
        'status': 'cancelled',
      });
    });
  }
}
