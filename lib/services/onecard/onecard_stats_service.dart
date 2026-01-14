import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneCardPlayerStats {
  String name;
  int wins;
  int losses;

  OneCardPlayerStats({
    required this.name,
    this.wins = 0,
    this.losses = 0,
  });

  int get gamesPlayed => wins + losses;

  double get winRate => gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

  void addGameResult({required bool won}) {
    if (won) {
      wins++;
    } else {
      losses++;
    }
  }

  void reset() {
    wins = 0;
    losses = 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'wins': wins,
    'losses': losses,
  };

  factory OneCardPlayerStats.fromJson(Map<String, dynamic> json) => OneCardPlayerStats(
    name: json['name'] as String,
    wins: json['wins'] as int? ?? 0,
    losses: json['losses'] as int? ?? 0,
  );
}

class OneCardStatsService extends ChangeNotifier {
  static const String _statsKey = 'onecard_player_stats';

  List<OneCardPlayerStats> _playerStats = [];
  bool _isLoaded = false;

  List<OneCardPlayerStats> get playerStats => _playerStats;
  bool get isLoaded => _isLoaded;

  Future<void> loadStats() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(statsJson);
        _playerStats = jsonList.map((json) => OneCardPlayerStats.fromJson(json)).toList();
        _updatePlayerNames();
      } catch (e) {
        _initDefaultStats();
      }
    } else {
      _initDefaultStats();
    }

    _isLoaded = true;
    notifyListeners();
  }

  void _updatePlayerNames() {
    final defaultNames = ['Player', 'AI 1', 'AI 2', 'AI 3'];
    // 기존 통계가 4명이 아닌 경우 초기화
    if (_playerStats.length != 4) {
      _initDefaultStats();
      return;
    }
    for (int i = 0; i < _playerStats.length && i < defaultNames.length; i++) {
      _playerStats[i].name = defaultNames[i];
    }
  }

  void _initDefaultStats() {
    _playerStats = [
      OneCardPlayerStats(name: 'Player'),
      OneCardPlayerStats(name: 'AI 1'),
      OneCardPlayerStats(name: 'AI 2'),
      OneCardPlayerStats(name: 'AI 3'),
    ];
  }

  /// 지역화된 플레이어 이름으로 업데이트
  void updateLocalizedNames(List<String> names) {
    for (int i = 0; i < _playerStats.length && i < names.length; i++) {
      _playerStats[i].name = names[i];
    }
    notifyListeners();
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _playerStats.map((s) => s.toJson()).toList();
    await prefs.setString(_statsKey, jsonEncode(jsonList));
  }

  /// 게임 결과 기록
  /// [winnerId]는 승자의 플레이어 ID (0 = 플레이어, 1-3 = AI)
  /// [playerCount]는 게임에 참여한 플레이어 수 (2-4)
  Future<void> recordGameResult({
    required int winnerId,
    required int playerCount,
  }) async {
    if (!_isLoaded) await loadStats();

    for (int i = 0; i < playerCount && i < _playerStats.length; i++) {
      _playerStats[i].addGameResult(won: i == winnerId);
    }

    await _saveStats();
    notifyListeners();
  }

  Future<void> resetStats() async {
    for (final stats in _playerStats) {
      stats.reset();
    }
    await _saveStats();
    notifyListeners();
  }

  OneCardPlayerStats? getPlayerStats(int playerId) {
    if (playerId >= 0 && playerId < _playerStats.length) {
      return _playerStats[playerId];
    }
    return null;
  }
}
