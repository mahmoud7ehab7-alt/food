import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';

class ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 24.h),
            Text(
              "عذراً، حدث خطأ ما",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              errorMessage ?? "نواجه مشكلة في تحميل البيانات. يرجى المحاولة مرة أخرى.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grayDark,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: 150.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text("إعادة المحاولة"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
