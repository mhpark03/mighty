import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SevenCardPlayerStats {
  String name;
  int wins;
  int losses;
  int totalScore; // 누적 점수 (칩)

  SevenCardPlayerStats({
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.totalScore = 0,
  });

  int get gamesPlayed => wins + losses;

  void addGameResult({required bool won, required int score}) {
    totalScore += score;
    if (won) {
      wins++;
    } else {
      losses++;
    }
  }

  void reset() {
    wins = 0;
    losses = 0;
    totalScore = 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'wins': wins,
    'losses': losses,
    'totalScore': totalScore,
  };

  factory SevenCardPlayerStats.fromJson(Map<String, dynamic> json) => SevenCardPlayerStats(
    name: json['name'] as String,
    wins: json['wins'] as int? ?? 0,
    losses: json['losses'] as int? ?? 0,
    totalScore: json['totalScore'] as int? ?? 0,
  );
}

class SevenCardStatsService extends ChangeNotifier {
  static const String _statsKey = 'seven_card_player_stats';

  List<SevenCardPlayerStats> _playerStats = [];
  bool _isLoaded = false;

  List<SevenCardPlayerStats> get playerStats => _playerStats;
  bool get isLoaded => _isLoaded;

  Future<void> loadStats() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(statsJson);
        _playerStats = jsonList.map((json) => SevenCardPlayerStats.fromJson(json)).toList();
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
    final defaultNames = ['Player', 'AI 1', 'AI 2', 'AI 3', 'AI 4'];
    for (int i = 0; i < _playerStats.length && i < defaultNames.length; i++) {
      _playerStats[i].name = defaultNames[i];
    }
  }

  void _initDefaultStats() {
    _playerStats = [
      SevenCardPlayerStats(name: 'Player'),
      SevenCardPlayerStats(name: 'AI 1'),
      SevenCardPlayerStats(name: 'AI 2'),
      SevenCardPlayerStats(name: 'AI 3'),
      SevenCardPlayerStats(name: 'AI 4'),
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
  /// [winnerId]는 승자의 플레이어 ID
  /// [playerScores]는 각 플레이어의 점수 변화 (승자: +pot, 패자: -totalBetInGame)
  Future<void> recordGameResult({
    required int winnerId,
    required Map<int, int> playerScores,
  }) async {
    if (!_isLoaded) await loadStats();

    for (int i = 0; i < 5; i++) {
      final score = playerScores[i] ?? 0;
      final won = i == winnerId;
      _playerStats[i].addGameResult(won: won, score: score);
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

  SevenCardPlayerStats? getPlayerStats(int playerId) {
    if (playerId >= 0 && playerId < _playerStats.length) {
      return _playerStats[playerId];
    }
    return null;
  }
}
