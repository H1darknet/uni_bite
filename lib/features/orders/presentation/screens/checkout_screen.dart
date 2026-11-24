
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String paymentMethod = 'cash';

  String formatPrice(double price) {
    return '${NumberFormat('#,##0', 'en_US').format(price).replaceAll(',', ' ')} so‘m';
  }

  // Sana tanlash
  Future<void> selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Olib ketish sanasini tanlang',
      cancelText: 'Bekor qilish',
      confirmText: 'Tanlash',
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // Vaqt tanlash
  Future<void> selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      helpText: 'Olib ketish vaqtini tanlang',
      cancelText: 'Bekor qilish',
      confirmText: 'Tanlash',
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  // Buyurtmani tasdiqlash va Firebase'ga saqlash
  Future<void> confirmOrder() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Olib ketish sanasi va vaqtini tanlang'),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Savat bo‘sh'),
        ),
      );
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avval tizimga kiring'),
        ),
      );
      return;
    }

    final pickupDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (!pickupDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelajakdagi vaqtni tanlang'),
        ),
      );
      return;
    }

    // Savatdagi mahsulotlarni buyurtma tarkibiga o'tkazish
    final orderItems = cart.items.map((item) {
      return OrderItemEntity(
        foodId: item.food.id,
        foodName: item.food.name,
        imageUrl: item.food.imageUrl,
        price: item.food.price,
        quantity: item.quantity,
      );
    }).toList();

    // Yangi buyurtma yaratish
    final order = OrderEntity(
      id: const Uuid().v4(),
      userId: firebaseUser.uid,
      items: orderItems,
      totalAmount: cart.totalPrice,
      pickupAt: pickupDateTime,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cash'
          ? 'unpaid'
          : 'pending',
      status: 'pending',
      createdAt: DateTime.now(),
    );

    // Buyurtmani Firebase'ga yuborish
    final orderProvider = context.read<OrderProvider>();

    final success = await orderProvider.create(order);

    if (!mounted) return;

    if (success) {
      // Savatni tozalash
      cart.clearCart();

      // Muvaffaqiyat sahifasini ochish
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderSuccessScreen(
              order: order,
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProvider.errorMessage ??
                'Buyurtmani saqlashda xatolik yuz berdi',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buyurtmani rasmiylashtirish',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Buyurtma ma’lumotlari',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Sana tanlash
              _buildSelectionTile(
                icon: Icons.calendar_month,
                title: 'Olib ketish sanasi',
                subtitle: selectedDate == null
                    ? 'Sanani tanlang'
                    : DateFormat('dd.MM.yyyy')
                        .format(selectedDate!),
                onTap: selectDate,
              ),

              const SizedBox(height: 12),

              // Vaqt tanlash
              _buildSelectionTile(
                icon: Icons.access_time,
                title: 'Olib ketish vaqti',
                subtitle: selectedTime == null
                    ? 'Vaqtni tanlang'
                    : selectedTime!.format(context),
                onTap: selectTime,
              ),

              const SizedBox(height: 28),

              const Text(
                'To‘lov turi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              RadioGroup<String>(
                groupValue: paymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      paymentMethod = value;
                    });
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'cash',
                      activeColor: AppColors.primary,
                      title: const Text('Naqd pul'),
                      subtitle: const Text('Oshxonada to‘lash'),
                      secondary: const Icon(
                        Icons.payments_outlined,
                      ),
                    ),

                    RadioListTile<String>(
                      value: 'online',
                      activeColor: AppColors.primary,
                      title: const Text('Onlayn to‘lov'),
                      subtitle: const Text('Click / Payme'),
                      secondary: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),

              const SizedBox(height: 12),

              // Mahsulotlar soni
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mahsulotlar soni:',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '${cart.totalQuantity} ta',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Umumiy summa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jami summa:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatPrice(cart.totalPrice),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buyurtmani tasdiqlash tugmasi
              Consumer<OrderProvider>(
                builder: (context, order, child) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: cart.items.isEmpty || order.isLoading
                          ? null
                          : confirmOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: order.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Buyurtmani tasdiqlash',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Sana va vaqt tanlash uchun umumiy widget
  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
