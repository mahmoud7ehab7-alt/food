import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/admin/data/admin_repository.dart';
import 'package:food/features/orders/domain/order_model.dart';
import 'package:food/features/orders/presentation/pages/order_details_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminRepository adminRepository = AdminRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("إدارة الطلبات (للتاجر)"),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: adminRepository.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد طلبات واردة حالياً"));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildAdminOrderCard(context, order, adminRepository);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminOrderCard(BuildContext context, OrderModel order, AdminRepository repo) {
    final Map<String, String> statusTexts = {
      'pending': 'قيد المراجعة',
      'processing': 'جاري التجهيز',
      'shipped': 'في الطريق',
      'delivered': 'تم التوصيل',
      'cancelled': 'تم الإلغاء',
    };

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "طلب #${order.id.substring(0, 5)}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              Text(
                "${order.total.toStringAsFixed(2)} ج.م",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          Text("العميل: ${order.addressTitle}", style: TextStyle(fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.gray),
              SizedBox(width: 8.w),
              Text("الحالة: ${statusTexts[order.orderStatus]}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                  ),
                  child: const Text("التفاصيل"),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showStatusPicker(context, order, repo),
                  child: const Text("تحديث الحالة"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context, OrderModel order, AdminRepository repo) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("تغيير حالة الطلب", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              _statusTile(context, order.id, "processing", "جاري التجهيز", repo),
              _statusTile(context, order.id, "shipped", "في الطريق", repo),
              _statusTile(context, order.id, "delivered", "تم التوصيل", repo),
              _statusTile(context, order.id, "cancelled", "إلغاء الطلب", repo, isDanger: true),
            ],
          ),
        );
      },
    );
  }

  Widget _statusTile(BuildContext context, String orderId, String status, String label, AdminRepository repo, {bool isDanger = false}) {
    return ListTile(
      title: Text(label, style: TextStyle(color: isDanger ? AppColors.error : AppColors.black)),
      onTap: () async {
        await repo.updateOrderStatus(orderId, status);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}
