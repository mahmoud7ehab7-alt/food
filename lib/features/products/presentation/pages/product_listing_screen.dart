import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/home/data/home_repository.dart';
import 'package:food/features/products/presentation/pages/product_details_screen.dart';
import 'package:food/features/products/presentation/widgets/product_card.dart';
import 'package:food/features/products/domain/product_model.dart';

class ProductListingScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const ProductListingScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _selectedSort = "الأكثر رواجاً";

  @override
  Widget build(BuildContext context) {
    final HomeRepository homeRepository = HomeRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: widget.categoryId == "featured"
            ? homeRepository.getFeaturedProducts()
            : homeRepository.getProductsByCategory(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد وجبات حالياً"));
          }

          List<ProductModel> products = snapshot.data!;

          // Applying Sort
          if (_selectedSort == "الأقل سعراً") {
            products.sort((a, b) => a.price.compareTo(b.price));
          } else if (_selectedSort == "الأعلى سعراً") {
            products.sort((a, b) => b.price.compareTo(a.price));
          }

          return Column(
            children: [
              // Sorting UI
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${products.length} وجبة متاحة",
                      style: TextStyle(color: AppColors.grayDark, fontSize: 14.sp),
                    ),
                    DropdownButton<String>(
                      value: _selectedSort,
                      items: <String>["الأكثر رواجاً", "الأقل سعراً", "الأعلى سعراً"]
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 14.sp)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSort = newValue!;
                        });
                      },
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              // Product Grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
