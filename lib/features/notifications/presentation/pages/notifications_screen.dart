import 'package:flutter/material.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we will show empty state as requested to clean up hardcoded stuff
    final List<dynamic> notifications = [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("الإشعارات"),
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              title: "لا توجد إشعارات",
              description: "سوف تظهر هنا التنبيهات الخاصة بطلباتك والعروض الجديدة.",
              icon: Icons.notifications_none,
            )
          : const Center(child: Text("إشعارات حقيقية قريباً")),
    );
  }
}
