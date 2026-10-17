import 'package:conquest/core/network/api_client.dart';

class ConfigRemoteSource {
  Future<int> getVersion() async {
    final res = await ApiClient.instance.get('/config/version');
    return res.data['version'] as int;
  }

  Future<Map<String, dynamic>> getRules() async {
    final res = await ApiClient.instance.get('/config/rules');
    return res.data as Map<String, dynamic>;
  }
}