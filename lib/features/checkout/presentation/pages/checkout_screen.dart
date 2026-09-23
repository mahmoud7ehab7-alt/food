import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/custom_text_field.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:food/features/profile/data/address_repository.dart';
import 'package:food/features/profile/domain/address_model.dart';
import 'package:food/features/profile/presentation/widgets/add_address_bottom_sheet.dart';
import 'package:food/features/checkout/presentation/pages/order_success_screen.dart';
import 'package:food/features/orders/domain/order_model.dart';
import 'package:food/features/orders/data/order_repository.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressModel? _selectedAddress;
  String _selectedPaymentMethod = "بطاقة ائتمان";
  bool _isPlacingOrder = false;
  final AddressRepository _addressRepository = AddressRepository();
  final OrderRepository _orderRepository = OrderRepository();

  // Controllers for Card Validation
  final _cardFormKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  final List<String> _paymentMethods = [
    "بطاقة ائتمان",
    "الدفع عند الاستلام",
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state as AuthSuccess;
    final cartState = context.read<CartCubit>().state as CartSuccess;

    double shipping = 20.0;
    double total = cartState.subtotal + shipping;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("إتمام الشراء"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "عنوان التوصيل",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => AddAddressBottomSheet(userId: authState.user.id),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("إضافة عنوان"),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Live Address List
            StreamBuilder<List<AddressModel>>(
              stream: _addressRepository.getAddresses(authState.user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoAddressUI();
                }

                final addresses = snapshot.data!;
                _selectedAddress ??= addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return _buildAddressCard(address);
                  },
                );
              },
            ),
            SizedBox(height: 24.h),

            // Payment Section
            Text(
              "طريقة الدفع",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paymentMethods.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return RadioListTile<String>(
                        title: Text(_paymentMethods[index]),
                        value: _paymentMethods[index],
                        groupValue: _selectedPaymentMethod,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      );
                    },
                  ),
                  if (_selectedPaymentMethod == "بطاقة ائتمان")
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Form(
                        key: _cardFormKey,
                        child: Column(
                          children: [
                            const Divider(),
                            SizedBox(height: 10.h),
                            CustomTextField(
                              controller: _cardNumberController,
                              hintText: "رقم البطاقة",
                              prefixIcon: Icons.credit_card,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v?.length ?? 0) < 16 ? "رقم غير صحيح" : null,
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _expiryController,
                                    hintText: "MM/YY",
                                    keyboardType: TextInputType.datetime,
                                    validator: (v) => (v?.isEmpty ?? true) ? "مطلوب" : null,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _cvvController,
                                    hintText: "CVV",
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    validator: (v) => (v?.length ?? 0) < 3 ? "خطأ" : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Order Summary
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _summaryRow("قيمة الطلبات", "${cartState.subtotal.toStringAsFixed(2)} ج.م"),
                  SizedBox(height: 8.h),
                  _summaryRow("رسوم التوصيل", "${shipping.toStringAsFixed(2)} ج.م"),
                  const Divider(),
                  _summaryRow("الإجمالي", "${total.toStringAsFixed(2)} ج.م", isTotal: true),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Final Order Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: (_selectedAddress == null || _isPlacingOrder)
                    ? null
                    : () => _handlePlaceOrder(authState.user.id, cartState, total, shipping),
                child: _isPlacingOrder
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تأكيد الطلب"),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _handlePlaceOrder(String userId, CartSuccess cartState, double total, double shipping) async {
    // 1. Validation for Card if selected
    if (_selectedPaymentMethod == "بطاقة ائتمان") {
      if (!_cardFormKey.currentState!.validate()) return;
    }

    setState(() => _isPlacingOrder = true);

    final newOrder = OrderModel(
      id: '', // Will be generated by Firestore
      userId: userId,
      items: cartState.items,
      subtotal: cartState.subtotal,
      shipping: shipping,
      total: total,
      addressTitle: _selectedAddress!.title,
      addressDetails: "${_selectedAddress!.city}, ${_selectedAddress!.details}",
      paymentMethod: _selectedPaymentMethod,
      createdAt: DateTime.now(),
    );

    try {
      await _orderRepository.placeOrder(newOrder);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تقديم الطلب: $e")),
      );
    }
  }

  Widget _buildNoAddressUI() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(
        child: Text("يرجى إضافة عنوان توصيل للمتابعة"),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    bool isSelected = _selectedAddress?.id == address.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = address),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.location_on : Icons.location_on_outlined,
              color: isSelected ? AppColors.primary : AppColors.gray,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  Text(
                    "${address.city}, ${address.details}",
                    style: TextStyle(color: AppColors.grayDark, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
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
