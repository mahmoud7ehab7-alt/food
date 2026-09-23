import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:food/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:food/features/main/presentation/pages/main_screen.dart';
import 'package:food/features/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Start checking auth status as soon as splash starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthSuccess || current is AuthUnauthenticated || current is AuthFailure,
      listener: (context, state) async {
        // Wait at least for the animation/minimum splash time (e.g., 3 seconds total)
        if (state is AuthSuccess || state is AuthUnauthenticated || state is AuthFailure) {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;

          if (state is AuthSuccess) {
            // Force fetch initial data before entering MainScreen
            context.read<WishlistCubit>().fetchWishlist(state.user.id);
            context.read<CartCubit>().fetchCart(state.user.id);
            
            await Future.delayed(const Duration(seconds: 2));
            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else {
            // Unauthenticated or Error (default to Onboarding)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: AppColors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'المطعم',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
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
