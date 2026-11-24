
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/order_entity.dart';

class TrackingScreen extends StatelessWidget {
  final OrderEntity order;

  const TrackingScreen({
    super.key,
    required this.order,
  });

  static const List<String> _statuses = [
    'pending',
    'accepted',
    'preparing',
    'ready',
    'completed',
  ];

  String _statusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Buyurtma yuborildi';
      case 'accepted':
        return 'Buyurtma qabul qilindi';
      case 'preparing':
        return 'Taom tayyorlanmoqda';
      case 'ready':
        return 'Buyurtma tayyor';
      case 'completed':
        return 'Buyurtma yakunlandi';
      case 'rejected':
        return 'Buyurtma rad etildi';
      case 'cancelled':
        return 'Buyurtma bekor qilindi';
      default:
        return 'Noma’lum holat';
    }
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Buyurtmangiz oshxona tomonidan ko‘rib chiqilmoqda.';
      case 'accepted':
        return 'Oshxona buyurtmangizni qabul qildi.';
      case 'preparing':
        return 'Taomingiz hozir tayyorlanmoqda.';
      case 'ready':
        return 'Taomingiz tayyor. Uni olib ketishingiz mumkin.';
      case 'completed':
        return 'Buyurtmangiz muvaffaqiyatli topshirildi.';
      case 'rejected':
        return 'Oshxona buyurtmangizni qabul qilmadi.';
      case 'cancelled':
        return 'Ushbu buyurtma bekor qilingan.';
      default:
        return 'Buyurtma holati aniqlanmadi.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buyurtmani kuzatish'),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(order.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Buyurtma ma’lumotlarini yuklashda xatolik.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Buyurtma topilmadi.'),
            );
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return const Center(
              child: Text('Buyurtma ma’lumotlari mavjud emas.'),
            );
          }

          final currentOrder = OrderModel.fromMap(
            snapshot.data!.id,
            data,
          );

          return _buildContent(currentOrder);
        },
      ),
    );
  }

  Widget _buildContent(OrderEntity currentOrder) {
    final status = currentOrder.status;
    final isCancelled = status == 'cancelled' || status == 'rejected';
    final currentIndex = _statuses.indexOf(status);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Icon(
                isCancelled ? Icons.cancel_outlined : Icons.receipt_long,
                size: 48,
                color: isCancelled ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                _statusTitle(status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusDescription(status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Buyurtma jarayoni',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        if (isCancelled)
          _buildCancelledStatus(status)
        else
          ...List.generate(_statuses.length, (index) {
            final stepStatus = _statuses[index];
            final isCompleted = currentIndex >= index;
            final isCurrent = currentIndex == index;

            return _buildTimelineStep(
              title: _statusTitle(stepStatus),
              description: _statusDescription(stepStatus),
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: index == _statuses.length - 1,
            );
          }),

        const SizedBox(height: 24),

        const Text(
          'Buyurtma tafsilotlari',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _detailRow(
                'Buyurtma raqami',
                currentOrder.id.substring(
                  0,
                  currentOrder.id.length > 8
                      ? 8
                      : currentOrder.id.length,
                ).toUpperCase(),
              ),
              const Divider(height: 24),
              _detailRow(
                'Buyurtma sanasi',
                DateFormat('dd.MM.yyyy HH:mm')
                    .format(currentOrder.createdAt),
              ),
              const Divider(height: 24),
              _detailRow(
                'Olib ketish vaqti',
                DateFormat('dd.MM.yyyy HH:mm')
                    .format(currentOrder.pickupAt),
              ),
              const Divider(height: 24),
              _detailRow(
                'Jami summa',
                '${NumberFormat('#,##0', 'en_US').format(currentOrder.totalAmount)} so‘m',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String description,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isCompleted
        ? AppColors.primary
        : AppColors.divider;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 15,
                      color: isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledStatus(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusTitle(status),
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
