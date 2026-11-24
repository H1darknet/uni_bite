
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderSuccessScreen({
    super.key,
    required this.order,
  });

  String formatPrice(double price) {
    return '${NumberFormat('#,##0', 'en_US').format(price).replaceAll(',', ' ')} so‘m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 65,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Buyurtma qabul qilindi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Buyurtmangiz muvaffaqiyatli saqlandi. '
                  'Tayyor bo‘lganda uni olib ketishingiz mumkin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.divider,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buyurtma ma’lumotlari',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _infoRow(
                        'Buyurtma raqami',
                        order.id.length > 8
                            ? order.id.substring(0, 8).toUpperCase()
                            : order.id.toUpperCase(),
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        'Buyurtma holati',
                        'Kutilmoqda',
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        'Olib ketish sanasi',
                        DateFormat('dd.MM.yyyy').format(order.pickupAt),
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        'Olib ketish vaqti',
                        DateFormat('HH:mm').format(order.pickupAt),
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        'To‘lov turi',
                        order.paymentMethod == 'cash'
                            ? 'Naqd pul'
                            : 'Onlayn to‘lov',
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        'Jami summa',
                        formatPrice(order.totalAmount),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bosh sahifaga qaytish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
