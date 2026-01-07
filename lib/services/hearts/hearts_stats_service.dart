import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeartsPlayerStats {
  String name;
  int wins;
  int losses;
  int totalScore; // 누적 점수 (낮을수록 좋음)

  HeartsPlayerStats({
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

  factory HeartsPlayerStats.fromJson(Map<String, dynamic> json) => HeartsPlayerStats(
    name: json['name'] as String,
    wins: json['wins'] as int? ?? 0,
    losses: json['losses'] as int? ?? 0,
    totalScore: json['totalScore'] as int? ?? 0,
  );
}

class HeartsStatsService extends ChangeNotifier {
  static const String _statsKey = 'hearts_player_stats';

  List<HeartsPlayerStats> _playerStats = [];
  bool _isLoaded = false;

  List<HeartsPlayerStats> get playerStats => _playerStats;
  bool get isLoaded => _isLoaded;

  Future<void> loadStats() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(statsJson);
        _playerStats = jsonList.map((json) => HeartsPlayerStats.fromJson(json)).toList();
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
    final defaultNames = ['플레이어', '민준', '서연', '지호'];
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
      HeartsPlayerStats(name: '플레이어'),
      HeartsPlayerStats(name: '민준'),
      HeartsPlayerStats(name: '서연'),
      HeartsPlayerStats(name: '지호'),
    ];
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _playerStats.map((s) => s.toJson()).toList();
    await prefs.setString(_statsKey, jsonEncode(jsonList));
  }

  /// 게임 결과 기록
  /// [winnerId]는 승자의 플레이어 ID (0 = 플레이어, 1-3 = AI)
  /// [roundScores]는 각 플레이어의 라운드 점수
  Future<void> recordGameResult({
    required int winnerId,
    required List<int> roundScores,
  }) async {
    if (!_isLoaded) await loadStats();

    for (int i = 0; i < roundScores.length && i < _playerStats.length; i++) {
      final won = i == winnerId;
      _playerStats[i].addGameResult(won: won, score: roundScores[i]);
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

  HeartsPlayerStats? getPlayerStats(int playerId) {
    if (playerId >= 0 && playerId < _playerStats.length) {
      return _playerStats[playerId];
    }
    return null;
  }
}
