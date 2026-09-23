import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/auth/presentation/pages/login_screen.dart';
import 'package:food/features/onboarding/domain/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingModel> _contents = [
    OnboardingModel(
      title: "أشهى المأكولات",
      description: "استمتع بتجربة طعام فريدة مع تشكيلة واسعة من الأطباق المحلية والعالمية.",
      image: "assets/images/onboarding1.png", // We will handle missing images gracefully
    ),
    OnboardingModel(
      title: "توصيل سريع",
      description: "نحن نهتم بوقتك، طلبك سيصلك ساخناً وفي أسرع وقت ممكن.",
      image: "assets/images/onboarding2.png",
    ),
    OnboardingModel(
      title: "دفع آمن وسهل",
      description: "نوفر لك خيارات دفع متعددة وآمنة تناسب احتياجاتك.",
      image: "assets/images/onboarding3.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for image since we don't have assets yet
                        Container(
                          height: 250.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grayLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.fastfood
                                : index == 1
                                    ? Icons.delivery_dining
                                    : Icons.payment,
                            size: 100.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          _contents[index].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          _contents[index].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.grayDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == _contents.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        child: Text(
                          _currentIndex == _contents.length - 1 ? "ابدأ الآن" : "التالي",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.h,
      width: _currentIndex == index ? 25.w : 10.w,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentIndex == index ? AppColors.primary : AppColors.grayLight,
      ),
    );
  }
}
