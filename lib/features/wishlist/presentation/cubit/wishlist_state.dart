part of 'wishlist_cubit.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();
  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistSuccess extends WishlistState {
  final List<String> favoriteIds;
  const WishlistSuccess({required this.favoriteIds});
  @override
  List<Object?> get props => [favoriteIds];
}

class WishlistFailure extends WishlistState {
  final String message;
  const WishlistFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
