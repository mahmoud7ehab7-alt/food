part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> featuredProducts;

  const HomeSuccess({
    required this.categories,
    required this.featuredProducts,
  });

  @override
  List<Object?> get props => [categories, featuredProducts];
}

class HomeFailure extends HomeState {
  final String message;
  const HomeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
