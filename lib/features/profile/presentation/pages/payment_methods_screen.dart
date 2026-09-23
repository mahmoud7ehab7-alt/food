import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/empty_state.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("طرق الدفع"),
      ),
      body: EmptyState(
        title: "لا يوجد بطاقات مسجلة",
        description: "أضف بطاقة ائتمان لتجربة شراء أسرع وأكثر سهولة.",
        icon: Icons.payment_outlined,
        buttonText: "إضافة بطاقة جديدة",
        onButtonPressed: () {
          // Future: Implement card entry UI
        },
      ),
    );
  }
}
