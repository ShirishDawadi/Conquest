import 'dart:convert';
import 'dart:developer';
import 'package:conquest/data/models/rules_model.dart';
import 'package:conquest/data/sources/remote/config_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RulesViewModel extends Notifier<GameRules> {
  static const _key = 'game_rules';
  final _source = ConfigRemoteSource();
  Future<void>? _cacheLoad;

  @override
  GameRules build() {
    _cacheLoad = _loadCached();
    return GameRules.defaults;
  }

  Future<void> _loadCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        state = GameRules.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      log('Rules cache read failed: $e', name: 'RulesViewModel');
    }
  }

  Future<void> checkForUpdates() async {
    try {
      await _cacheLoad;
      final serverVersion = await _source.getVersion();
      if (serverVersion == state.version) return;

      final json = await _source.getRules();
      final fresh = GameRules.fromJson(json);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(json));
      state = fresh;
    } catch (e) {
      log('Rules update failed: $e', name: 'RulesViewModel');
    }
  }
}

final rulesProvider = NotifierProvider<RulesViewModel, GameRules>(
  RulesViewModel.new,
);