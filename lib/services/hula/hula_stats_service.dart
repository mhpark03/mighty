import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HulaPlayerStats {
  String name;
  int wins;
  int losses;
  int totalScore; // 누적 점수

  HulaPlayerStats({
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

  factory HulaPlayerStats.fromJson(Map<String, dynamic> json) => HulaPlayerStats(
    name: json['name'] as String,
    wins: json['wins'] as int? ?? 0,
    losses: json['losses'] as int? ?? 0,
    totalScore: json['totalScore'] as int? ?? 0,
  );
}

class HulaStatsService extends ChangeNotifier {
  static const String _statsKey = 'hula_player_stats';

  List<HulaPlayerStats> _playerStats = [];
  bool _isLoaded = false;

  List<HulaPlayerStats> get playerStats => _playerStats;
  bool get isLoaded => _isLoaded;

  Future<void> loadStats() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(statsJson);
        _playerStats = jsonList.map((json) => HulaPlayerStats.fromJson(json)).toList();
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
      HulaPlayerStats(name: '플레이어'),
      HulaPlayerStats(name: '민준'),
      HulaPlayerStats(name: '서연'),
      HulaPlayerStats(name: '지호'),
    ];
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _playerStats.map((s) => s.toJson()).toList();
    await prefs.setString(_statsKey, jsonEncode(jsonList));
  }

  /// 게임 결과 기록 (손패 점수 기반)
  /// [winnerId]는 승자의 플레이어 ID (0 = 플레이어, 1-3 = AI)
  /// [handScores]는 각 플레이어의 손패 점수 (낮을수록 좋음)
  /// [isHula]는 훌라 여부 (훌라면 점수 2배)
  Future<void> recordGameResult({
    required int winnerId,
    required List<int> handScores,
    bool isHula = false,
  }) async {
    if (!_isLoaded) await loadStats();

    final winnerHandScore = handScores[winnerId];
    final multiplier = isHula ? 2 : 1;

    // 각 플레이어의 점수 변화 계산
    // 승자: 다른 플레이어들의 (손패점수 - 승자손패점수) 합계
    // 패자: -(자신의 손패점수 - 승자손패점수)
    int winnerGain = 0;

    for (int i = 0; i < handScores.length && i < _playerStats.length; i++) {
      if (i == winnerId) continue;
      final diff = (handScores[i] - winnerHandScore) * multiplier;
      winnerGain += diff;
      _playerStats[i].addGameResult(won: false, score: -diff);
    }

    _playerStats[winnerId].addGameResult(won: true, score: winnerGain);

    await _saveStats();
    notifyListeners();
  }

  /// 게임 결과 기록 (라운드 점수 기반 - 스톱 실패 등 특별 케이스용)
  /// [winnerId]는 승자의 플레이어 ID
  /// [roundScores]는 이미 계산된 각 플레이어의 라운드 점수
  Future<void> recordGameResultWithRoundScores({
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

  HulaPlayerStats? getPlayerStats(int playerId) {
    if (playerId >= 0 && playerId < _playerStats.length) {
      return _playerStats[playerId];
    }
    return null;
  }
}
