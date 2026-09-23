import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/empty_state.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/orders/data/order_repository.dart';
import 'package:food/features/orders/domain/order_model.dart';
import 'package:food/features/orders/presentation/pages/order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state as AuthSuccess;
    final OrderRepository orderRepository = OrderRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("طلباتي"),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderRepository.getUserOrders(authState.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyState(
              title: "ليس لديك طلبات حالياً",
              description: "ابدأ بطلب وجبتك الأولى الآن واستمتع بطعامنا الشهي!",
              icon: Icons.shopping_bag_outlined,
              buttonText: "تصفح القائمة",
              onButtonPressed: () {
                // Return to home
              },
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    bool isDelivered = order.orderStatus == 'delivered';
    
    // Status translation map
    Map<String, String> statusTexts = {
      'pending': 'قيد المراجعة',
      'processing': 'جاري التجهيز',
      'shipped': 'في الطريق',
      'delivered': 'تم التوصيل',
      'cancelled': 'تم الإلغاء',
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "طلب #${order.id.substring(0, 5)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                Text(
                  "${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}",
                  style: TextStyle(color: AppColors.gray, fontSize: 12.sp),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  isDelivered ? Icons.check_circle : Icons.timer,
                  color: isDelivered ? AppColors.secondary : Colors.amber,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  statusTexts[order.orderStatus] ?? order.orderStatus,
                  style: TextStyle(
                    color: isDelivered ? AppColors.secondary : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${order.total.toStringAsFixed(2)} ج.م",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  "${order.items.length} وجبات",
                  style: TextStyle(color: AppColors.grayDark, fontSize: 14.sp),
                ),
                const Spacer(),
                Text(
                  "عرض التفاصيل",
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 14.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
