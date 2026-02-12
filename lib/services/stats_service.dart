import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';

class StatsService extends ChangeNotifier {
  static const String _statsKey = 'player_stats';

  List<PlayerStats> _playerStats = [];
  bool _isLoaded = false;

  List<PlayerStats> get playerStats => _playerStats;
  bool get isLoaded => _isLoaded;

  /// 플레이어 통계 로드
  Future<void> loadStats() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        _playerStats = PlayerStats.decodeList(statsJson);
        // 기존 AI 이름을 새 이름으로 업데이트
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

  /// 플레이어 이름 업데이트 (기존 데이터 마이그레이션)
  void _updatePlayerNames() {
    final defaultNames = ['Player', 'AI 1', 'AI 2', 'AI 3', 'AI 4'];
    for (int i = 0; i < _playerStats.length && i < defaultNames.length; i++) {
      _playerStats[i].name = defaultNames[i];
    }
  }

  /// 기본 플레이어 통계 초기화
  void _initDefaultStats() {
    _playerStats = [
      PlayerStats(name: 'Player'),
      PlayerStats(name: 'AI 1'),
      PlayerStats(name: 'AI 2'),
      PlayerStats(name: 'AI 3'),
      PlayerStats(name: 'AI 4'),
    ];
  }

  /// 지역화된 플레이어 이름으로 업데이트
  void updateLocalizedNames(List<String> names) {
    for (int i = 0; i < _playerStats.length && i < names.length; i++) {
      _playerStats[i].name = names[i];
    }
    notifyListeners();
  }

  /// 플레이어 통계 저장
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, PlayerStats.encodeList(_playerStats));
  }

  /// 게임 결과 기록
  /// [playerScores]는 플레이어 ID를 키로, 점수를 값으로 가지는 맵
  /// [declarerWon]은 주공팀이 이겼는지 여부
  /// [declarerId]는 주공의 플레이어 ID
  /// [friendId]는 프렌드의 플레이어 ID (없으면 null)
  Future<void> recordGameResult({
    required Map<int, int> playerScores,
    required bool declarerWon,
    required int declarerId,
    int? friendId,
  }) async {
    if (!_isLoaded) await loadStats();

    final isNoFriend = friendId == null;
    final numDefenders = isNoFriend ? 4 : 3;

    for (int i = 0; i < 5; i++) {
      final score = playerScores[i] ?? 0;
      final isDeclarer = i == declarerId;
      final isFriend = i == friendId;
      final isDeclarerTeam = isDeclarer || isFriend;

      // 주공팀이 이기면 주공팀 승리, 수비팀이 이기면 수비팀 승리
      final won = declarerWon ? isDeclarerTeam : !isDeclarerTeam;

      // 역할별 승/패 배율 (점수 배분 방식과 동일)
      // 주공: 2/3 (노프렌드: 4/4=1), 프렌드: 1/3, 수비: 각 1/3 (노프렌드: 1/4)
      double amount;
      if (isDeclarer) {
        amount = (isNoFriend ? 4 : 2) / numDefenders;
      } else {
        amount = 1 / numDefenders;
      }

      _playerStats[i].addGameResult(won: won, score: score, amount: amount);
    }

    await _saveStats();
    notifyListeners();
  }

  /// 통계 초기화
  Future<void> resetStats() async {
    for (final stats in _playerStats) {
      stats.reset();
    }
    await _saveStats();
    notifyListeners();
  }

  /// 특정 플레이어의 통계 가져오기
  PlayerStats? getPlayerStats(int playerId) {
    if (playerId >= 0 && playerId < _playerStats.length) {
      return _playerStats[playerId];
    }
    return null;
  }

  /// 플레이어 통계 (0번은 사용자)
  PlayerStats? get humanStats => _playerStats.isNotEmpty ? _playerStats[0] : null;
}
