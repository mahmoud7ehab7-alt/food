import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/empty_state.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/profile/data/address_repository.dart';
import 'package:food/features/profile/domain/address_model.dart';
import 'package:food/features/profile/presentation/widgets/add_address_bottom_sheet.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state as AuthSuccess;
    final AddressRepository addressRepository = AddressRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("عناويني"),
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: addressRepository.getAddresses(authState.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyState(
              title: "لا يوجد عناوين",
              description: "أضف عنوانك الأول الآن لتسهيل عملية التوصيل.",
              icon: Icons.location_on_outlined,
              buttonText: "إضافة عنوان جديد",
              onButtonPressed: () {
                _showAddAddress(context, authState.user.id);
              },
            );
          }

          final addresses = snapshot.data!;

          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressItem(context, address, authState.user.id, addressRepository);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddress(context, authState.user.id),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAddress(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAddressBottomSheet(userId: userId),
    );
  }

  Widget _buildAddressItem(BuildContext context, AddressModel address, String userId, AddressRepository repo) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    if (address.isDefault) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "افتراضي",
                          style: TextStyle(color: AppColors.secondary, fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "${address.city}, ${address.details}",
                  style: TextStyle(color: AppColors.grayDark, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              repo.deleteAddress(userId, address.id);
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
