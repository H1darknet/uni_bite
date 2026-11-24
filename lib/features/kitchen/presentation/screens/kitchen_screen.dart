
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': status});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buyurtma holati yangilandi'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e')),
        );
      }
    }
  }

  String _statusName(String status) {
    switch (status) {
      case 'pending':
        return 'Yangi buyurtma';
      case 'accepted':
        return 'Qabul qilindi';
      case 'preparing':
        return 'Tayyorlanmoqda';
      case 'ready':
        return 'Tayyor';
      case 'completed':
        return 'Topshirildi';
      case 'rejected':
        return 'Rad etildi';
      case 'cancelled':
        return 'Bekor qilindi';
      default:
        return status;
    }
  }

  Widget _actionButton(
    BuildContext context,
    String orderId,
    String status,
    String title,
  ) {
    return ElevatedButton(
      onPressed: () => _updateStatus(context, orderId, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Oshxona paneli',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Xatolik: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs.toList() ?? [];

          documents.sort((a, b) {
            final aDate = a.data()['createdAt'] as Timestamp?;
            final bDate = b.data()['createdAt'] as Timestamp?;

            return (bDate?.millisecondsSinceEpoch ?? 0)
                .compareTo(aDate?.millisecondsSinceEpoch ?? 0);
          });

          if (documents.isEmpty) {
            return const Center(
              child: Text('Hozircha buyurtmalar mavjud emas'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();

              final status = data['status'] ?? 'pending';
              final items = data['items'] as List<dynamic>? ?? [];
              final total = (data['totalAmount'] as num?)?.toDouble() ?? 0;
              final pickupAt = data['pickupAt'] as Timestamp?;

              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(
                    color: AppColors.divider,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buyurtma: ${document.id.substring(0, document.id.length > 8 ? 8 : document.id.length)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Holati: ${_statusName(status)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Divider(height: 20),

                      ...items.map((item) {
                        final food = Map<String, dynamic>.from(item as Map);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${food['foodName']}  × ${food['quantity']}',
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      Text(
                        'Jami: ${total.toStringAsFixed(0)} so‘m',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (pickupAt != null)
                        Text(
                          'Olib ketish: ${pickupAt.toDate().toLocal().toString().substring(0, 16)}',
                        ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (status == 'pending') ...[
                            _actionButton(
                              context,
                              document.id,
                              'accepted',
                              'Qabul qilish',
                            ),
                            _actionButton(
                              context,
                              document.id,
                              'rejected',
                              'Rad etish',
                            ),
                          ],
                          if (status == 'accepted')
                            _actionButton(
                              context,
                              document.id,
                              'preparing',
                              'Tayyorlash',
                            ),
                          if (status == 'preparing')
                            _actionButton(
                              context,
                              document.id,
                              'ready',
                              'Tayyor',
                            ),
                          if (status == 'ready')
                            _actionButton(
                              context,
                              document.id,
                              'completed',
                              'Topshirildi',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
