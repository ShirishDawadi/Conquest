import 'dart:ui';

import 'package:conquest/core/theme/app_colors.dart';

enum League { bronze, silver, gold, platinum, diamond, master, legend }

class LeagueTheme {
  final Color light;
  final Color mid;
  final Color dark;

  const LeagueTheme({
    required this.light,
    required this.mid,
    required this.dark,
  });
}

const leagueThemes = {
  League.bronze: LeagueTheme(
    light: AppColors.bronze_light,
    mid: AppColors.bronze_mid,
    dark: AppColors.bronze_dark,
  ),
  League.silver: LeagueTheme(
    light: AppColors.silver_light,
    mid: AppColors.silver_mid,
    dark: AppColors.silver_dark,
  ),
  League.gold: LeagueTheme(
    light: AppColors.gold_light,
    mid: AppColors.gold_mid,
    dark: AppColors.gold_dark,
  ),
  League.platinum: LeagueTheme(
    light: AppColors.platinum_light,
    mid: AppColors.platinum_mid,
    dark: AppColors.platinum_dark,
  ),
  League.diamond: LeagueTheme(
    light: AppColors.diamond_light,
    mid: AppColors.diamond_mid,
    dark: AppColors.diamond_dark,
  ),
  League.master: LeagueTheme(
    light: AppColors.master_light,
    mid: AppColors.master_mid,
    dark: AppColors.master_dark,
  ),
  League.legend: LeagueTheme(
    light: AppColors.legend_light,
    mid: AppColors.legend_mid,
    dark: AppColors.legend_dark,
  ),
};
League leagueFromString(String league) {
  return League.values.firstWhere(
    (l) => l.name.toLowerCase() == league.toLowerCase(),
    orElse: () => League.bronze,
  );
}
