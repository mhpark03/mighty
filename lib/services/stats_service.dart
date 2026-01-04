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
    final defaultNames = ['플레이어', '민준', '서연', '지호', '수빈'];
    for (int i = 0; i < _playerStats.length && i < defaultNames.length; i++) {
      _playerStats[i].name = defaultNames[i];
    }
  }

  /// 기본 플레이어 통계 초기화
  void _initDefaultStats() {
    _playerStats = [
      PlayerStats(name: '플레이어'),
      PlayerStats(name: '민준'),
      PlayerStats(name: '서연'),
      PlayerStats(name: '지호'),
      PlayerStats(name: '수빈'),
    ];
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

    for (int i = 0; i < 5; i++) {
      final score = playerScores[i] ?? 0;
      final isDeclarer = i == declarerId;
      final isFriend = i == friendId;
      final isDeclarerTeam = isDeclarer || isFriend;

      // 주공팀이 이기면 주공팀 승리, 수비팀이 이기면 수비팀 승리
      final won = declarerWon ? isDeclarerTeam : !isDeclarerTeam;

      _playerStats[i].addGameResult(won: won, score: score);
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
