import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/features/home/domain/category_model.dart';
import 'package:food/features/products/domain/product_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch featured products for the home screen
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch products by category ID
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      // Trim categoryId to avoid comparison issues with hidden spaces
      final cleanId = categoryId.trim();
      
      final snapshot = await _firestore
          .collection('products')
          .get(); // جلب جميع المنتجات مؤقتاً للتأكد من المقارنة البرمجية

      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .where((product) => product.categoryId == cleanId) // الفلترة هنا تضمن تجاوز مشاكل الـ Types في Firestore
          .toList();
          
      return products;
    } catch (e) {
      rethrow;
    }
  }
}
