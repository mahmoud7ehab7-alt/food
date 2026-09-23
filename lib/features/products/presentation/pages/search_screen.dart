import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/features/products/domain/product_model.dart';
import 'package:food/features/products/presentation/pages/product_details_screen.dart';
import 'package:food/features/products/presentation/widgets/filter_bottom_sheet.dart';
import 'package:food/features/products/presentation/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Basic Firestore search (Note: Firestore search is limited to exact matches or prefix)
      // For professional apps, consider Algolia or ElasticSearch.
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        _filteredProducts = snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "ابحث عن وجبتك...",
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          style: const TextStyle(color: AppColors.white),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterBottomSheet(),
              );
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80.sp, color: AppColors.grayLight),
                      SizedBox(height: 16.h),
                      Text(
                        "ابدأ البحث عن أكلتك المفضلة الآن",
                        style: TextStyle(color: AppColors.gray, fontSize: 16.sp),
                      ),
                    ],
                  ),
                )
              : _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80.sp, color: AppColors.grayLight),
                          SizedBox(height: 16.h),
                          Text(
                            "عذراً، لم نجد نتائج لـ \"${_searchController.text}\"",
                            style: TextStyle(color: AppColors.gray, fontSize: 16.sp),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
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
    );
  }
}
