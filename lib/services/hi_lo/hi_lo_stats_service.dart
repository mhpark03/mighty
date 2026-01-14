import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiLoPlayerStats {
  String name;
  int hiWins;
  int loWins;
  int swingWins;
  int losses;
  int totalScore;

  HiLoPlayerStats({
    required this.name,
    this.hiWins = 0,
    this.loWins = 0,
    this.swingWins = 0,
    this.losses = 0,
    this.totalScore = 0,
  });

  int get wins => hiWins + loWins + swingWins;
  int get gamesPlayed => wins + losses;

  void addGameResult({
    bool hiWin = false,
    bool loWin = false,
    bool swingWin = false,
    bool lost = false,
    required int score,
  }) {
    totalScore += score;
    if (hiWin) hiWins++;
    if (loWin) loWins++;
    if (swingWin) swingWins++;
    if (lost) losses++;
  }

  void reset() {
    hiWins = 0;
    loWins = 0;
    swingWins = 0;
    losses = 0;
    totalScore = 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'hiWins': hiWins,
    'loWins': loWins,
    'swingWins': swingWins,
    'losses': losses,
    'totalScore': totalScore,
  };

  factory HiLoPlayerStats.fromJson(Map<String, dynamic> json) => HiLoPlayerStats(
    name: json['name'] as String,
    hiWins: json['hiWins'] as int? ?? 0,
    loWins: json['loWins'] as int? ?? 0,
    swingWins: json['swingWins'] as int? ?? 0,
    losses: json['losses'] as int? ?? 0,
    totalScore: json['totalScore'] as int? ?? 0,
  );
}

class HiLoStatsService extends ChangeNotifier {
  static const String _statsKey = 'hi_lo_player_stats';

  List<HiLoPlayerStats> _playerStats = [];
  bool _isLoaded = false;

  List<HiLoPlayerStats> get playerStats => _playerStats;
  bool get isLoaded => _isLoaded;

  Future<void> loadStats() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(statsJson);
        _playerStats = jsonList.map((json) => HiLoPlayerStats.fromJson(json)).toList();
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
      HiLoPlayerStats(name: 'Player'),
      HiLoPlayerStats(name: 'AI 1'),
      HiLoPlayerStats(name: 'AI 2'),
      HiLoPlayerStats(name: 'AI 3'),
      HiLoPlayerStats(name: 'AI 4'),
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
  Future<void> recordGameResult({
    int? hiWinnerId,
    int? loWinnerId,
    bool swingSuccess = false,
    int? swingPlayerId,
    required Map<int, int> playerScores,
  }) async {
    if (!_isLoaded) await loadStats();

    for (int i = 0; i < 5; i++) {
      final score = playerScores[i] ?? 0;
      final isHiWinner = i == hiWinnerId && !swingSuccess;
      final isLoWinner = i == loWinnerId && !swingSuccess;
      final isSwingWinner = swingSuccess && i == swingPlayerId;
      final isLoser = score < 0;

      _playerStats[i].addGameResult(
        hiWin: isHiWinner,
        loWin: isLoWinner,
        swingWin: isSwingWinner,
        lost: isLoser,
        score: score,
      );
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

  HiLoPlayerStats? getPlayerStats(int playerId) {
    if (playerId >= 0 && playerId < _playerStats.length) {
      return _playerStats[playerId];
    }
    return null;
  }
}
