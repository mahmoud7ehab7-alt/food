import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/features/products/domain/product_model.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _wishlistCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('wishlist');

  // Toggle favorite status
  Future<void> toggleFavorite(String userId, ProductModel product) async {
    final docRef = _wishlistCollection(userId).doc(product.id);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'image': product.image,
        'rating': product.rating,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Stream wishlist item IDs to keep UI in sync
  Stream<List<String>> getWishlistIds(String userId) {
    return _wishlistCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Stream full wishlist items for the Wishlist Screen
  Stream<List<ProductModel>> getWishlistItems(String userId) {
    return _wishlistCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          image: data['image'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          description: '',
          categoryId: '',
        );
      }).toList();
    });
  }
}
