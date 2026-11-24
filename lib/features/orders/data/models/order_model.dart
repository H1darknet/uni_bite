
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.pickupAt,
    required super.paymentMethod,
    super.paymentStatus,
    super.status,
    required super.createdAt,
  });

  // Entity ma'lumotlarini Firestore formatiga o'tkazish
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) {
        return {
          'foodId': item.foodId,
          'foodName': item.foodName,
          'imageUrl': item.imageUrl,
          'price': item.price,
          'quantity': item.quantity,
          'totalPrice': item.totalPrice,
        };
      }).toList(),
      'totalAmount': totalAmount,
      'pickupAt': Timestamp.fromDate(pickupAt),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Firestore ma'lumotlarini Entity formatiga o'tkazish
  factory OrderModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    final rawItems = map['items'] as List<dynamic>? ?? [];

    final items = rawItems.map((item) {
      final data = Map<String, dynamic>.from(item as Map);

      return OrderItemEntity(
        foodId: data['foodId'] as String? ?? '',
        foodName: data['foodName'] as String? ?? '',
        imageUrl: data['imageUrl'] as String? ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0,
        quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    final pickupTimestamp = map['pickupAt'];
    final createdTimestamp = map['createdAt'];

    return OrderModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      items: items,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      pickupAt: pickupTimestamp is Timestamp
          ? pickupTimestamp.toDate()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] as String? ?? 'cash',
      paymentStatus: map['paymentStatus'] as String? ?? 'unpaid',
      status: map['status'] as String? ?? 'pending',
      createdAt: createdTimestamp is Timestamp
          ? createdTimestamp.toDate()
          : DateTime.now(),
    );
  }
}
