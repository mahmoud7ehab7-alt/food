import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/features/orders/domain/order_model.dart';
import 'package:food/features/cart/data/cart_repository.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartRepository _cartRepository = CartRepository();

  // Create a new order
  Future<void> placeOrder(OrderModel order) async {
    final batch = _firestore.batch();
    
    try {
      // 1. Create the order document
      final orderRef = _firestore.collection('orders').doc();
      batch.set(orderRef, order.toMap());

      // 2. We should ideally clear the cart here as well
      // Note: Full transaction/batch for clearing sub-collections requires care
      // For now, we will perform the clear after the batch success for simplicity
      
      await batch.commit();

      // 3. Clear user's cart
      await _cartRepository.clearCart(order.userId);
      
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all orders for a specific user
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
