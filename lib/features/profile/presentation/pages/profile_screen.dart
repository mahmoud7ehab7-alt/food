import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/auth/domain/user_model.dart';
import 'package:food/features/profile/data/profile_repository.dart';
import 'package:food/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:food/features/profile/presentation/pages/addresses_screen.dart';
import 'package:food/features/profile/presentation/pages/payment_methods_screen.dart';
import 'package:food/features/profile/presentation/pages/settings_screen.dart';
import 'package:food/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:food/features/auth/presentation/pages/login_screen.dart';
import 'package:food/features/admin/presentation/pages/admin_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state as AuthSuccess;
    final ProfileRepository profileRepository = ProfileRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("حسابي"),
      ),
      body: StreamBuilder<UserModel>(
        stream: profileRepository.streamUserData(authState.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = snapshot.data ?? authState.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.h),
                // User Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                        child: user.profileImage == null 
                            ? Icon(Icons.person, size: 60.sp, color: AppColors.primary)
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        user.name,
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.grayDark),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                // Profile Options
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      if (user.role == 'admin')
                        _buildProfileTile(
                          Icons.admin_panel_settings_outlined,
                          "لوحة تحكم التاجر",
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                          ),
                        ),
                      _buildProfileTile(
                        Icons.person_outline, 
                        "تعديل الملف الشخصي", 
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => EditProfileScreen(user: user))
                        ),
                      ),
                      _buildProfileTile(
                        Icons.location_on_outlined, 
                        "عناويني", 
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const AddressesScreen())
                        ),
                      ),
                      _buildProfileTile(
                        Icons.payment_outlined, 
                        "طرق الدفع", 
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const PaymentMethodsScreen())
                        ),
                      ),
                      _buildProfileTile(
                        Icons.notifications_none, 
                        "الإشعارات", 
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const NotificationsScreen())
                        ),
                      ),
                      _buildProfileTile(
                        Icons.settings_outlined, 
                        "الإعدادات", 
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const SettingsScreen())
                        ),
                      ),
                      _buildProfileTile(Icons.help_outline, "المساعدة والدعم", () {}),
                      _buildProfileTile(
                        Icons.logout,
                        "تسجيل الخروج",
                        () {
                          context.read<AuthCubit>().logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        isDanger: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? AppColors.error : AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? AppColors.error : AppColors.black,
          fontWeight: isDanger ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
