
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource dataSource;

  OrderRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<void> createOrder(OrderEntity order) async {
    final model = OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      totalAmount: order.totalAmount,
      pickupAt: order.pickupAt,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      status: order.status,
      createdAt: order.createdAt,
    );

    await dataSource.createOrder(model);
  }

  @override
  Stream<List<OrderEntity>> getUserOrders(String userId) {
    return dataSource.getUserOrders(userId);
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) {
    return dataSource.getOrderById(orderId);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    return dataSource.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }

  @override
  Future<void> cancelOrder(String orderId) {
    return dataSource.cancelOrder(orderId);
  }
}
