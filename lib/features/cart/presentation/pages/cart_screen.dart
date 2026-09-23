import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/empty_state.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:food/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:food/features/checkout/presentation/pages/checkout_screen.dart';
import 'package:food/features/products/domain/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<CartCubit>().fetchCart(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("سلة التسوق"),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartFailure) {
            return Center(child: Text("خطأ: ${state.message}"));
          } else if (state is CartSuccess) {
            if (state.items.isEmpty) {
              return EmptyState(
                title: "السلة فارغة",
                description: "ابدأ بإضافة وجباتك المفضلة للسلة الآن!",
                icon: Icons.shopping_cart_outlined,
                buttonText: "تصفح الوجبات",
                onButtonPressed: () => Navigator.pop(context),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final product = ProductModel(
                        id: item['productId'],
                        name: item['name'],
                        price: (item['price'] as num).toDouble(),
                        image: item['image'],
                        description: '',
                        categoryId: '',
                        rating: 0,
                      );
                      return CartItemCard(
                        product: product,
                        quantity: item['quantity'],
                        onAdd: () {
                          final authState = context.read<AuthCubit>().state as AuthSuccess;
                          context.read<CartCubit>().updateQuantity(
                                authState.user.id,
                                product.id,
                                item['quantity'] + 1,
                              );
                        },
                        onRemove: () {
                          final authState = context.read<AuthCubit>().state as AuthSuccess;
                          context.read<CartCubit>().updateQuantity(
                                authState.user.id,
                                product.id,
                                item['quantity'] - 1,
                              );
                        },
                        onDelete: () {
                          final authState = context.read<AuthCubit>().state as AuthSuccess;
                          context.read<CartCubit>().removeFromCart(
                                authState.user.id,
                                product.id,
                              );
                        },
                      );
                    },
                  ),
                ),
                _buildOrderSummary(context, state.subtotal),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, double subtotal) {
    double shipping = subtotal > 0 ? 20.0 : 0.0;
    double total = subtotal + shipping;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow("المجموع الفرعي", "${subtotal.toStringAsFixed(2)} ج.م"),
            SizedBox(height: 8.h),
            _summaryRow("رسوم التوصيل", "${shipping.toStringAsFixed(2)} ج.م"),
            SizedBox(height: 8.h),
            const Divider(),
            SizedBox(height: 8.h),
            _summaryRow("الإجمالي", "${total.toStringAsFixed(2)} ج.م", isTotal: true),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: subtotal > 0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                        );
                      }
                    : null,
                child: const Text("إتمام الشراء"),
              ),
            ),
          ],
        ),
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
              fontSize: isTotal ? 18.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.black : AppColors.grayDark,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.black,
          ),
        ),
      ],
    );
  }
}
