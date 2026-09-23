import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/orders/domain/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("طلب #${order.id.substring(0, 5)}"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Stepper
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _buildStatusRow("تم استلام الطلب", true, true),
                  _buildStatusRow("جاري تجهيز الطلب", order.orderStatus != 'pending', true),
                  _buildStatusRow("الطلب في الطريق", order.orderStatus == 'shipped' || order.orderStatus == 'delivered', true),
                  _buildStatusRow("تم التوصيل", order.orderStatus == 'delivered', false),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Order Items
            Text(
              "محتويات الطلب",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: order.items.map((item) {
                  return Column(
                    children: [
                      _buildItemRow(
                        item['name'] ?? 'وجبة',
                        item['quantity'].toString(),
                        "${(item['price'] as num).toStringAsFixed(2)} ج.م",
                      ),
                      if (order.items.last != item) const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24.h),

            // Delivery Address Summary
            Text(
              "عنوان التوصيل",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.addressTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    order.addressDetails,
                    style: TextStyle(color: AppColors.grayDark, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Payment Summary
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _summaryRow("المجموع الفرعي", "${order.subtotal.toStringAsFixed(2)} ج.م"),
                  SizedBox(height: 8.h),
                  _summaryRow("رسوم التوصيل", "${order.shipping.toStringAsFixed(2)} ج.م"),
                  const Divider(),
                  _summaryRow("الإجمالي", "${order.total.toStringAsFixed(2)} ج.م", isTotal: true),
                  SizedBox(height: 8.h),
                  _summaryRow("طريقة الدفع", order.paymentMethod),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isDone, bool showLine) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppColors.secondary : AppColors.gray,
              size: 24.sp,
            ),
            if (showLine)
              Container(
                width: 2.w,
                height: 30.h,
                color: isDone ? AppColors.secondary : AppColors.grayLight,
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDone ? AppColors.black : AppColors.gray,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(String name, String qty, String price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("$name x$qty")),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.black,
          ),
        ),
      ],
    );
  }
}
