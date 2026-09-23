import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/features/auth/data/auth_repository.dart';
import 'package:food/features/auth/domain/user_model.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthCubit() : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      try {
        final userModel = await _authRepository.getUserData(currentUser.uid);
        emit(AuthSuccess(user: userModel));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  void logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
