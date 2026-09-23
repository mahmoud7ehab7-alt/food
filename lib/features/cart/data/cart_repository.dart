import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/features/products/domain/product_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference: users/{userId}/cart/{productId}
  CollectionReference _cartCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('cart');

  // Add item to cart or update quantity
  Future<void> addToCart(String userId, ProductModel product, int quantity) async {
    try {
      final doc = await _cartCollection(userId).doc(product.id).get();
      if (doc.exists) {
        // Update existing quantity
        int currentQty = doc.get('quantity');
        await _cartCollection(userId).doc(product.id).update({
          'quantity': currentQty + quantity,
        });
      } else {
        // Add new item
        await _cartCollection(userId).doc(product.id).set({
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'image': product.image,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch cart items
  Stream<List<Map<String, dynamic>>> getCartItems(String userId) {
    return _cartCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Update item quantity directly
  Future<void> updateQuantity(String userId, String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(userId, productId);
    } else {
      await _cartCollection(userId).doc(productId).update({'quantity': newQuantity});
    }
  }

  // Remove item
  Future<void> removeFromCart(String userId, String productId) async {
    await _cartCollection(userId).doc(productId).delete();
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    final items = await _cartCollection(userId).get();
    for (var doc in items.docs) {
      await doc.reference.delete();
    }
  }
}
