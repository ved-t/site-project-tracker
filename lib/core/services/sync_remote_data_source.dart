import 'dart:convert';

import 'package:dio/dio.dart';
import '../utils/logger.dart';

import '../../features/projects/data/models/project_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/sites/settings/data/models/category_model.dart';
import '../../features/sites/settings/data/models/vendor_model.dart';

class SyncRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  SyncRemoteDataSource({required this.dio, required this.baseUrl});

  Future<SyncChanges> pull({
    required String deviceId,
    required DateTime since,
  }) async {
    try {
      AppLogger.debug('Sync Pull', name: 'REMOTE');
      final response = await dio.post(
        '$baseUrl/api/v1/sync/pull',
        data: {'device_id': deviceId, 'since': since.toIso8601String()},
      );

      return SyncChanges.fromJson(response.data);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Sync Pull Error',
        error: e,
        stackTrace: stackTrace,
        name: 'REMOTE',
      );
      rethrow;
    }
  }

  Future<SyncPushResponse> push({
    required String deviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prettyData = JsonEncoder.withIndent('  ').convert(data);
      AppLogger.debug('Sync Push Data: $prettyData', name: 'REMOTE');

      AppLogger.debug('Sync Push', name: 'REMOTE');
      final response = await dio.post(
        '$baseUrl/api/v1/sync/push',
        data: {'device_id': deviceId, ...data},
      );

      return SyncPushResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Sync Push Error',
        error: e,
        stackTrace: stackTrace,
        name: 'REMOTE',
      );
      rethrow;
    }
  }

  Future<DeviceSync?> getDeviceLastSync(String deviceId) async {
    try {
      AppLogger.debug(
        'Fetching last sync for device: $deviceId',
        name: 'REMOTE',
      );
      final response = await dio.get('$baseUrl/api/v1/sync/devices/$deviceId');
      return DeviceSync.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.warning(
          'No sync record found for device: $deviceId',
          name: 'REMOTE',
        );
        return null;
      }
      AppLogger.error(
        'Error fetching device last sync',
        error: e,
        name: 'REMOTE',
      );
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error fetching device last sync',
        error: e,
        stackTrace: stackTrace,
        name: 'REMOTE',
      );
      rethrow;
    }
  }
}

class DeviceSync {
  final String deviceId;
  final DateTime lastSyncAt;
  final DateTime createdAt;

  DeviceSync({
    required this.deviceId,
    required this.lastSyncAt,
    required this.createdAt,
  });

  factory DeviceSync.fromJson(Map<String, dynamic> json) {
    return DeviceSync(
      deviceId: json['device_id'] as String,
      lastSyncAt: DateTime.parse(json['last_sync_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SyncChanges {
  final List<ProjectModel> sites;
  final List<CategoryModel> categories;
  final List<VendorModel> vendors;
  final List<ExpenseModel> expenses;
  final DateTime timestamp;

  SyncChanges({
    required this.sites,
    required this.categories,
    required this.vendors,
    required this.expenses,
    required this.timestamp,
  });

  factory SyncChanges.fromJson(Map<String, dynamic> json) {
    return SyncChanges(
      sites: (json['sites'] as List? ?? [])
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vendors: (json['vendors'] as List? ?? [])
          .map((e) => VendorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenses: (json['expenses'] as List? ?? [])
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class SyncPushResponse {
  final bool success;
  final String message;
  final List<dynamic> conflicts;
  final Map<String, dynamic> syncedCount;
  final DateTime timestamp;

  SyncPushResponse({
    required this.success,
    required this.message,
    required this.conflicts,
    required this.syncedCount,
    required this.timestamp,
  });

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) {
    return SyncPushResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      conflicts: json['conflicts'] as List? ?? [],
      syncedCount: json['synced_count'] as Map<String, dynamic>? ?? {},
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
