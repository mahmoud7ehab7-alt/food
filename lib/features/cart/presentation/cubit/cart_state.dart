part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  final List<Map<String, dynamic>> items;
  final double subtotal;

  const CartSuccess({required this.items, required this.subtotal});

  @override
  List<Object?> get props => [items, subtotal];
}

class CartFailure extends CartState {
  final String message;
  const CartFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
