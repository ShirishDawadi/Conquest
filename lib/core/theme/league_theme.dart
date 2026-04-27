import 'dart:ui';

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
    light: Color(0xFFEFB49B),
    mid: Color(0xFFBE7D63),
    dark: Color(0xFF6C2B11),
  ),
  League.silver: LeagueTheme(
    light: Color(0xFF8D9CA4),
    mid: Color(0xFF829199),
    dark: Color(0xFF2E3D45),
  ),
  League.gold: LeagueTheme(
    light: Color(0xFFD9A846),
    mid: Color(0xFFB78323),
    dark: Color(0xFF553700),
  ),
  League.platinum: LeagueTheme(
    light: Color(0xFFAE74FE),
    mid: Color(0xFF8679FF),
    dark: Color(0xFF70118C),
  ),
  League.diamond: LeagueTheme(
    light: Color(0xFFCBE2F0),
    mid: Color(0xFFB8D8E7),
    dark: Color(0xFF3998CB),
  ),
  League.master: LeagueTheme(
    light: Color(0xFF8F3C44),
    mid: Color(0xFF720A15),
    dark: Color(0xFF3F060C),
  ),
  League.legend: LeagueTheme(
    light: Color(0xFF8EB69B),
    mid: Color(0xFF235347),
    dark: Color(0xFF051F20),
  ),
};

League leagueFromString(String league) {
  return League.values.firstWhere(
    (l) => l.name.toLowerCase() == league.toLowerCase(),
    orElse: () => League.bronze,
  );
}