import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:order_booking_app/data/api/api_service.dart';
import 'package:order_booking_app/domain/repository/shop_visit.dart';

import '../../domain/models/visite.dart';
import '../local/offline_visit_dao.dart';

class VisitImpl implements VisitRepository {
  final OfflineVisitDao local;
  final ApiService apiService;

  bool _isSyncing = false;

  VisitImpl({required this.local, required this.apiService});

  Future<void> saveVisitOffline(VisitPayload visit) async {
    debugPrint('Saving visit offline: ${visit.toJson()}');
    await local.insert(visit);
  }

  Future<void> syncOfflineVisits() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final rows = await local.fetchPending();

      for (final row in rows) {
        final id = row['id'] as int;
        final retryCount = row['retry_count'] as int;

        if (retryCount >= 5) continue;

        try {
          await local.markSyncing(id);

          final visit = VisitPayload.fromJson(jsonDecode(row['payload']));

          final response = await apiService.addLocation(visit);
          debugPrint('Sync response for visit id $id: ${response['success']}');

          if (response['success'] != true) {
            throw Exception('Failed to sync visit with id $id');
          }

          await local.delete(id);
        } catch (_) {
          debugPrint(
            'Error syncing visit with id $id, incrementing retry count',
          );
          await local.incrementRetry(id);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

}
