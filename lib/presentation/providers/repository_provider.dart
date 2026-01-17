import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/dio_provider.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/data/repositories/auth_impl.dart';
import 'package:order_booking_app/domain/repository/auth_repo.dart';




final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider).value!;
  final api = ApiService(dio);
  return AuthImpl(api);
});





