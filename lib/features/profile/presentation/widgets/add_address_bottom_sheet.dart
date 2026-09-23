import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/custom_text_field.dart';
import 'package:food/features/profile/domain/address_model.dart';
import 'package:food/features/profile/data/address_repository.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final String userId;
  const AddAddressBottomSheet({super.key, required this.userId});

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "إضافة عنوان جديد",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Future: Implement Geolocator
                    _cityController.text = "القاهرة (موقعك الحالي)";
                    _detailsController.text = "المعادي، شارع 9";
                  },
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text("موقعي الحالي"),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _titleController,
              hintText: "اسم العنوان (مثلاً: المنزل، العمل)",
              validator: (v) => v == null || v.isEmpty ? "مطلوب" : null,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _cityController,
              hintText: "المدينة",
              validator: (v) => v == null || v.isEmpty ? "مطلوب" : null,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _detailsController,
              hintText: "تفاصيل العنوان (الشارع، رقم البناية، الشقة)",
              validator: (v) => v == null || v.isEmpty ? "مطلوب" : null,
            ),
            SizedBox(height: 12.h),
            SwitchListTile(
              title: const Text("تعيين كعنوان افتراضي"),
              value: _isDefault,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("حفظ العنوان"),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newAddress = AddressModel(
        id: '',
        title: _titleController.text.trim(),
        city: _cityController.text.trim(),
        details: _detailsController.text.trim(),
        isDefault: _isDefault,
      );
      try {
        await AddressRepository().addAddress(widget.userId, newAddress);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    }
  }
}
