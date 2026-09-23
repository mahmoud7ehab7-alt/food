import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food/features/wishlist/data/wishlist_repository.dart';
import 'package:food/features/products/domain/product_model.dart';

part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _wishlistRepository = WishlistRepository();
  StreamSubscription? _wishlistSubscription;

  WishlistCubit() : super(WishlistInitial());

  void fetchWishlist(String userId) {
    print("🔍 DEBUG: WishlistCubit.fetchWishlist for user: $userId");
    _wishlistSubscription?.cancel();
    _wishlistSubscription = _wishlistRepository.getWishlistIds(userId).listen(
      (ids) {
        print("🔍 DEBUG: Wishlist IDs received from Firestore: $ids");
        emit(WishlistSuccess(favoriteIds: ids));
      },
      onError: (e) {
        print("❌ DEBUG: Wishlist Error: $e");
        emit(WishlistFailure(message: e.toString()));
      },
    );
  }

  Future<void> toggleFavorite(String userId, ProductModel product) async {
    print("🔍 DEBUG: Toggling favorite for product: ${product.name}");
    try {
      await _wishlistRepository.toggleFavorite(userId, product);
      print("✅ DEBUG: Firestore update successful");
    } catch (e) {
      print("❌ DEBUG: Toggle Error: $e");
      emit(WishlistFailure(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _wishlistSubscription?.cancel();
    return super.close();
  }
}
