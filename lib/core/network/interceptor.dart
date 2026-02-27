import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/token_response.dart';
import 'package:order_booking_app/main.dart';
import 'package:order_booking_app/screens/login_screen.dart';

import '../../data/repositories/auth_impl.dart';
import 'token_provider.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final Ref ref;
  final AuthImpl authRepository;

  TokenInterceptor({
    required this.dio,
    required this.ref,
    required this.authRepository,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(tokenProvider).accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = ref.read(tokenProvider).refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await ref.read(tokenProvider.notifier).clearTokens();
      _goToLogin();
      return handler.next(err);
    }

    try {
      final tokenResponse = await authRepository.refreshAccessToken(
        TokenResponse(refreshToken: refreshToken),
      );

      await ref
          .read(tokenProvider.notifier)
          .saveTokens(
            tokenResponse.accessToken!,
            tokenResponse.refreshToken!,
            tokenResponse.roleId ?? 0,
          );

      return _retryRequest(err, handler);
    } catch (_) {
      await ref.read(tokenProvider.notifier).clearTokens();
      _goToLogin();
      return handler.next(err);
    }
  }

  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final reqOptions = err.requestOptions;

    // Update header with the new access token
    final newToken = ref.read(tokenProvider).accessToken;
    reqOptions.headers['Authorization'] = "Bearer $newToken";

    try {
      final response = await dio.fetch(reqOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  void _goToLogin() {
    Future.microtask(() {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false, // remove all previous screens
      );
    });
  }
}
