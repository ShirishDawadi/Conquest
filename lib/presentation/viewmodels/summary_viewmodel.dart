import 'dart:io';
import 'package:conquest/core/services/summary_sync_service.dart';
import 'package:conquest/data/models/summary_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoInternetException implements Exception {
  const NoInternetException();
}

class DaySummaryNotifier extends AsyncNotifier<DaySummaryModel?> {
  DaySummaryNotifier(this.date);
  final DateTime date;

  @override
  Future<DaySummaryModel?> build() => _load();

  Future<DaySummaryModel?> _load() async {
    final normalized = DateTime(date.year, date.month, date.day);
    try {
      return await SummarySyncService().getDaySummary(normalized);
    } on SocketException {
      throw const NoInternetException();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final daySummaryProvider = AsyncNotifierProvider.autoDispose
    .family<DaySummaryNotifier, DaySummaryModel?, DateTime>(
      DaySummaryNotifier.new,
      retry: (retryCount, error) => null,
    );