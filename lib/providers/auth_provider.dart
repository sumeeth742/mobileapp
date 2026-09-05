import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({this.displayName, this.isSubmitting = false, this.errorMessage});

  final String? displayName;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isAuthenticated => displayName != null;

  AuthState copyWith({String? displayName, bool? isSubmitting, String? errorMessage, bool clearError = false}) => AuthState(
        displayName: displayName ?? this.displayName,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (email.trim().isEmpty || password.length < 8) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Enter a valid email and an 8-character password.');
      return false;
    }
    final String localName = email.split('@').first.replaceAll(RegExp(r'[._-]'), ' ');
    state = AuthState(displayName: _titleCase(localName), isSubmitting: false);
    return true;
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (name.trim().isEmpty || email.trim().isEmpty || password.length < 8) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Complete every field and use an 8-character password.');
      return false;
    }
    state = AuthState(displayName: name.trim(), isSubmitting: false);
    return true;
  }

  void signOut() => state = const AuthState();

  String _titleCase(String value) => value.split(' ').where((String word) => word.isNotEmpty).map((String word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
}

final NotifierProvider<AuthController, AuthState> authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
