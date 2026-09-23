import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food/features/cart/data/cart_repository.dart';
import 'package:food/features/products/domain/product_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository = CartRepository();
  StreamSubscription? _cartSubscription;

  CartCubit() : super(CartInitial());

  void fetchCart(String userId) {
    emit(CartLoading());
    _cartSubscription?.cancel();
    _cartSubscription = _cartRepository.getCartItems(userId).listen(
      (items) {
        double subtotal = 0;
        for (var item in items) {
          subtotal += (item['price'] as num) * (item['quantity'] as num);
        }
        emit(CartSuccess(items: items, subtotal: subtotal));
      },
      onError: (error) {
        emit(CartFailure(message: error.toString()));
      },
    );
  }

  Future<void> addToCart(String userId, ProductModel product, int quantity) async {
    try {
      await _cartRepository.addToCart(userId, product, quantity);
    } catch (e) {
      emit(CartFailure(message: e.toString()));
    }
  }

  Future<void> updateQuantity(String userId, String productId, int newQuantity) async {
    try {
      await _cartRepository.updateQuantity(userId, productId, newQuantity);
    } catch (e) {
      emit(CartFailure(message: e.toString()));
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    try {
      await _cartRepository.removeFromCart(userId, productId);
    } catch (e) {
      emit(CartFailure(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
