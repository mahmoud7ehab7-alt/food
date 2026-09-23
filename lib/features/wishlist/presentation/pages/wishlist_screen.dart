import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/empty_state.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/main/presentation/pages/main_screen.dart';
import 'package:food/features/products/presentation/pages/product_details_screen.dart';
import 'package:food/features/products/presentation/widgets/product_card.dart';
import 'package:food/features/products/domain/product_model.dart';
import 'package:food/features/wishlist/data/wishlist_repository.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state as AuthSuccess;
    final WishlistRepository wishlistRepository = WishlistRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("المفضلة"),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: wishlistRepository.getWishlistItems(authState.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyState(
              title: "قائمة المفضلة فارغة",
              description: "لم تقم بإضافة أي وجبات للمفضلة بعد. استكشف القائمة وأضف ما تحب!",
              icon: Icons.favorite_border,
              buttonText: "استكشف الوجبات",
              onButtonPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
                );
              },
            );
          }

          final wishlistItems = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final product = wishlistItems[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
