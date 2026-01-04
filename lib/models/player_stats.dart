import 'dart:convert';

class PlayerStats {
  String name;
  int wins;
  int losses;
  int totalScore;
  int gamesPlayed;

  PlayerStats({
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.totalScore = 0,
    this.gamesPlayed = 0,
  });

  /// 승리 횟수 / 게임 수 비율
  double get winRate => gamesPlayed > 0 ? wins / gamesPlayed : 0;

  /// 평균 점수
  double get averageScore => gamesPlayed > 0 ? totalScore / gamesPlayed : 0;

  /// 게임 결과 추가
  void addGameResult({required bool won, required int score}) {
    gamesPlayed++;
    totalScore += score;
    if (won) {
      wins++;
    } else {
      losses++;
    }
  }

  /// 통계 초기화
  void reset() {
    wins = 0;
    losses = 0;
    totalScore = 0;
    gamesPlayed = 0;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'wins': wins,
        'losses': losses,
        'totalScore': totalScore,
        'gamesPlayed': gamesPlayed,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        name: json['name'] as String,
        wins: json['wins'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        totalScore: json['totalScore'] as int? ?? 0,
        gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      );

  static String encodeList(List<PlayerStats> stats) {
    return jsonEncode(stats.map((s) => s.toJson()).toList());
  }

  static List<PlayerStats> decodeList(String jsonStr) {
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => PlayerStats.fromJson(json)).toList();
  }
}
