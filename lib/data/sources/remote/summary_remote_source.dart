// data/sources/remote/summary_remote_source.dart

import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/summary_model.dart';

class SummaryRemoteSource {
  Future<DaySummaryModel> getDaySummary(DateTime date) async {
    final formattedDate = date.toIso8601String().substring(0, 10);
    final response = await ApiClient.instance.get('/activity/day/$formattedDate');
    return DaySummaryModel.fromJson(response.data as Map<String, dynamic>);
  }
}