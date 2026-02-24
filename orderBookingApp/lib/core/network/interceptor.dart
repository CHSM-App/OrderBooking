import 'dart:io';
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

  bool _isRefreshing = false;
  Future<TokenResponse>? _refreshFuture;
  bool _isNavigatingToLogin = false;

  static const int _maxRetryCount = 1;

  TokenInterceptor({
    required this.dio,
    required this.ref,
    required this.authRepository,
  });

  // ===============================
  // 1️⃣ Attach Access Token
  // ===============================
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(tokenProvider).accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = "Bearer $token";
    }

    handler.next(options);
  }

  // ===============================
  // 2️⃣ Handle Errors
  // ===============================
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // -------------------------------
    // A. Retry for temporary connection errors
    // -------------------------------
    if (_shouldRetryConnectionError(err)) {
      final retryCount =
          (requestOptions.extra['retry_count'] ?? 0) as int;

      if (retryCount < _maxRetryCount) {
        requestOptions.extra['retry_count'] = retryCount + 1;

        try {
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(e is DioException ? e : err);
        }
      }
    }

    // -------------------------------
    // B. If no response → network issue
    // -------------------------------
    if (err.response == null) {
      return handler.next(err);
    }

    // -------------------------------
    // C. Only handle 401
    // -------------------------------
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent infinite 401 retry loop
    if (requestOptions.extra['retry_401'] == true) {
      await _forceLogout();
      return handler.next(err);
    }

    final refreshToken = ref.read(tokenProvider).refreshToken;

    // If refresh token missing → logout
    if (refreshToken == null || refreshToken.isEmpty) {
      await _forceLogout();
      return handler.next(err);
    }

    try {
      // If refresh already running → wait
      if (_isRefreshing) {
        await _refreshFuture;
        return _retryWithNewToken(requestOptions, handler);
      }

      // Start refresh
      _isRefreshing = true;

      _refreshFuture = authRepository.refreshAccessToken(
        TokenResponse(refreshToken: refreshToken),
      );

      final tokenResponse = await _refreshFuture!;
      _isRefreshing = false;

      // Validate new tokens
      if (tokenResponse.accessToken == null ||
          tokenResponse.accessToken!.isEmpty ||
          tokenResponse.refreshToken == null ||
          tokenResponse.refreshToken!.isEmpty) {
        await _forceLogout();
        return handler.next(err);
      }

      // Save tokens
      await ref.read(tokenProvider.notifier).saveTokens(
            tokenResponse.accessToken!,
            tokenResponse.refreshToken!,
            tokenResponse.roleId ?? 0,
          );

      // Mark retry
      requestOptions.extra['retry_401'] = true;

      return _retryWithNewToken(requestOptions, handler);
    } catch (e) {
      _isRefreshing = false;
      await _forceLogout();
      return handler.next(err);
    }
  }

  // ===============================
  // 3️⃣ Retry with Updated Token
  // ===============================
  Future<void> _retryWithNewToken(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final newToken = ref.read(tokenProvider).accessToken;

      final options = Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          'Authorization': "Bearer $newToken",
        },
      );

      final response = await dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );

      handler.resolve(response);
    } catch (e) {
      handler.next(e is DioException ? e : DioException(
        requestOptions: requestOptions,
        error: e,
      ));
    }
  }

  // ===============================
  // 4️⃣ Retry Only Safe Network Errors
  // ===============================
  bool _shouldRetryConnectionError(DioException err) {
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    final error = err.error;
    if (error is SocketException || error is HandshakeException) {
      return true;
    }

    final message = err.message?.toLowerCase();
    if (message != null &&
        (message.contains('connection reset') ||
            message.contains('broken pipe') ||
            message.contains('connection closed'))) {
      return true;
    }

    return false;
  }

  // ===============================
  // 5️⃣ Force Logout Safely
  // ===============================
  Future<void> _forceLogout() async {
    await ref.read(tokenProvider.notifier).clearTokens();

    if (_isNavigatingToLogin) return;
    _isNavigatingToLogin = true;

    Future.microtask(() {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }
}