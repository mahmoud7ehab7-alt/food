import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food/features/home/data/home_repository.dart';
import 'package:food/features/home/domain/category_model.dart';
import 'package:food/features/products/domain/product_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository = HomeRepository();

  HomeCubit() : super(HomeInitial());

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      final categories = await _homeRepository.getCategories();
      final featuredProducts = await _homeRepository.getFeaturedProducts();
      emit(HomeSuccess(
        categories: categories,
        featuredProducts: featuredProducts,
      ));
    } catch (e) {
      emit(HomeFailure(message: e.toString()));
    }
  }
}
