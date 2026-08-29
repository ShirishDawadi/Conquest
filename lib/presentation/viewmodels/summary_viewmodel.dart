import 'package:conquest/core/services/summary_sync_service.dart';
import 'package:conquest/data/models/summary_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final daySummaryProvider =
    FutureProvider.family<DaySummaryModel?, DateTime>((ref, date) async {
  final normalized = DateTime(date.year, date.month, date.day);
  return SummarySyncService().getDaySummary(normalized);
});