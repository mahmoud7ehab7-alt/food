import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  "نسيت كلمة المرور؟",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رابطاً لاستعادة كلمة المرور.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grayDark,
                  ),
                ),
                SizedBox(height: 40.h),
                CustomTextField(
                  hintText: "البريد الإلكتروني",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال البريد الإلكتروني";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Mock Reset Action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم إرسال رابط الاستعادة إلى بريدك")),
                        );
                      }
                    },
                    child: Text(
                      "إرسال الرابط",
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
