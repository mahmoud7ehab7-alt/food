import 'package:flutter/material.dart';
import 'package:food/core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("الإعدادات"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("اللغة"),
            trailing: const Text("العربية"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text("الوضع الليلي"),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          const Divider(),
          ListTile(
            title: const Text("إشعارات التطبيق"),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}
