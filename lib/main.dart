import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/core/theme/app_theme.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/home/presentation/cubit/home_cubit.dart';
import 'package:food/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:food/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:food/features/onboarding/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => HomeCubit()..fetchHomeData()),
        BlocProvider(create: (context) => CartCubit()),
        BlocProvider(create: (context) => WishlistCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Food E-Commerce',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, child) {
              return child!;
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'EG'),
            ],
            locale: const Locale('ar', 'EG'),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
