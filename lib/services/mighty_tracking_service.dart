import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class BidEvaluationSnapshot {
  final int playerId;
  final List<Map<String, dynamic>> hand;
  final String? bestGiruda;
  final int girudaCount;
  final bool hasMighty;
  final bool hasJoker;
  final bool hasGirudaAce;
  final bool hasGirudaKing;
  final int predictedMin;
  final int predictedMax;
  final int predictedOptimal;
  final String bidAction;
  final int bidAmount;
  bool isDeclarer;
  final List<(Suit, int, int, int)> suitComparison; // (suit, min, max, optimal)

  BidEvaluationSnapshot({
    required this.playerId,
    required this.hand,
    this.bestGiruda,
    required this.girudaCount,
    required this.hasMighty,
    required this.hasJoker,
    required this.hasGirudaAce,
    required this.hasGirudaKing,
    required this.predictedMin,
    required this.predictedMax,
    required this.predictedOptimal,
    required this.bidAction,
    required this.bidAmount,
    this.isDeclarer = false,
    this.suitComparison = const [],
  });

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'hand': hand,
    'bestGiruda': bestGiruda,
    'girudaCount': girudaCount,
    'hasMighty': hasMighty,
    'hasJoker': hasJoker,
    'hasGirudaAce': hasGirudaAce,
    'hasGirudaKing': hasGirudaKing,
    'predictedMin': predictedMin,
    'predictedMax': predictedMax,
    'predictedOptimal': predictedOptimal,
    'bidAction': bidAction,
    'bidAmount': bidAmount,
    'isDeclarer': isDeclarer,
  };
}

class KittySnapshot {
  final List<Map<String, dynamic>> kittyCards;
  final int kittyPointCards;
  final List<Map<String, dynamic>> discardCards;
  final List<Map<String, dynamic>> finalHand;
  final bool girudaChanged;
  final String? originalGiruda;
  final String? newGiruda;
  final int postKittyMin;
  final int postKittyMax;
  final int postKittyOptimal;

  KittySnapshot({
    required this.kittyCards,
    required this.kittyPointCards,
    required this.discardCards,
    required this.finalHand,
    required this.girudaChanged,
    this.originalGiruda,
    this.newGiruda,
    required this.postKittyMin,
    required this.postKittyMax,
    required this.postKittyOptimal,
  });

  Map<String, dynamic> toJson() => {
    'kittyCards': kittyCards,
    'kittyPointCards': kittyPointCards,
    'discardCards': discardCards,
    'finalHand': finalHand,
    'girudaChanged': girudaChanged,
    'originalGiruda': originalGiruda,
    'newGiruda': newGiruda,
    'postKittyMin': postKittyMin,
    'postKittyMax': postKittyMax,
    'postKittyOptimal': postKittyOptimal,
  };
}

class MightyTrackingService {
  static const String _defaultUrl = 'https://center.kaistory.net';
  static const String _prefsKeyUrl = 'mighty_tracking_server_url';
  static const String _prefsKeyDeviceId = 'mighty_device_uuid';
  static const String _prefsKeyPlayerId = 'mighty_player_id_v2';

  static String? _cachedPlayerId;

  /// 디바이스 UUID를 가져오거나 새로 생성
  static Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_prefsKeyDeviceId);
    if (deviceId == null) {
      deviceId = generateUuid();
      await prefs.setString(_prefsKeyDeviceId, deviceId);
    }
    return deviceId;
  }

  /// 서버에서 playerId를 등록/조회
  static Future<String?> getPlayerId() async {
    if (_cachedPlayerId != null) return _cachedPlayerId;

    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedPlayerId = prefs.getString(_prefsKeyPlayerId);
      if (_cachedPlayerId != null) return _cachedPlayerId;

      // 서버에 등록
      final deviceId = await _getOrCreateDeviceId();
      final serverUrl = await _getServerUrl();
      final url = Uri.parse('$serverUrl/api/mighty/players');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId, 'appType': 'mighty'}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedPlayerId = data['playerId'] as String?;
        if (_cachedPlayerId != null) {
          await prefs.setString(_prefsKeyPlayerId, _cachedPlayerId!);
        }
      }
    } catch (_) {
      // 실패 시 null 반환 (다음 기회에 재시도)
    }
    return _cachedPlayerId;
  }

  static String generateUuid() {
    final rng = Random();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  static Future<String> _getServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKeyUrl) ?? _defaultUrl;
    } catch (_) {
      return _defaultUrl;
    }
  }

  static String? _suitName(Suit? suit) {
    if (suit == null) return null;
    return suit.name; // spade, diamond, heart, club
  }

  static String? _friendTypeString(FriendDeclaration? decl) {
    if (decl == null) return null;
    if (decl.isNoFriend) return 'NO_FRIEND';
    if (decl.isFirstTrickWinner) return 'FIRST_TRICK_WINNER';
    if (decl.trickNumber != null) return 'NTH_TRICK';
    if (decl.card != null) return 'CARD';
    return null;
  }

  /// Fire-and-forget: sends game result to server, ignores errors
  static void sendGameResult({
    required String gameUuid,
    required GameState state,
    required List<BidEvaluationSnapshot> bidSnapshots,
    KittySnapshot? kittySnapshot,
    required bool isAutoPlay,
    List<String?>? trickDescriptions,
  }) {
    _doSend(
      gameUuid: gameUuid,
      state: state,
      bidSnapshots: bidSnapshots,
      kittySnapshot: kittySnapshot,
      isAutoPlay: isAutoPlay,
      trickDescriptions: trickDescriptions,
    );
  }


  static Future<void> _doSend({
    required String gameUuid,
    required GameState state,
    required List<BidEvaluationSnapshot> bidSnapshots,
    KittySnapshot? kittySnapshot,
    required bool isAutoPlay,
    List<String?>? trickDescriptions,
  }) async {
    try {
      final serverUrl = await _getServerUrl();
      final url = Uri.parse('$serverUrl/api/mighty/games');

      // Calculate trick-level stats and details
      int? tricksWonByDeclarerTeam;
      int? tricksWonByDefenderTeam;
      bool jokerCalled = false;
      List<Map<String, dynamic>>? trickDetails;

      if (!state.allPassed && state.declarerId != null) {
        final declarer = state.declarerId!;
        final friend = state.friendId;
        final giruda = state.giruda;
        tricksWonByDeclarerTeam = state.tricks.where((t) =>
            t.winnerId == declarer || (friend != null && t.winnerId == friend)
        ).length;
        tricksWonByDefenderTeam = state.tricks.length - tricksWonByDeclarerTeam;
        jokerCalled = state.tricks.any((t) =>
            t.jokerCall == JokerCallType.jokerCall
        );

        trickDetails = [];
        for (int trickIdx = 0; trickIdx < state.tricks.length; trickIdx++) {
          final trick = state.tricks[trickIdx];
          final pointCards = trick.cards.where((c) => c.isPointCard).length;
          final hasMighty = trick.cards.any((c) => c.isMightyWith(giruda));
          final hasJoker = trick.cards.any((c) => c.isJoker);
          final hasGiruda = giruda != null && trick.cards.any((c) => !c.isJoker && c.suit == giruda);
          final wonByDeclarer = trick.winnerId == declarer ||
              (friend != null && trick.winnerId == friend);

          // Detect special interactions
          String? event;
          if (hasMighty && hasGiruda) {
            final mightyPlayer = trick.playerOrder[
              trick.cards.indexWhere((c) => c.isMightyWith(giruda))
            ];
            final wonByMighty = trick.winnerId == mightyPlayer;
            if (wonByMighty && !wonByDeclarer) {
              event = 'MIGHTY_BEAT_GIRUDA';
            } else if (wonByMighty && wonByDeclarer) {
              event = 'DECLARER_MIGHTY_WIN';
            }
          }
          if (hasJoker && hasGiruda && trick.jokerCall != JokerCallType.jokerCall) {
            final jokerIdx = trick.cards.indexWhere((c) => c.isJoker);
            if (jokerIdx >= 0) {
              final jokerPlayer = trick.playerOrder[jokerIdx];
              if (trick.winnerId == jokerPlayer) {
                if (!wonByDeclarer) {
                  event = 'JOKER_BEAT_GIRUDA';
                }
              }
            }
          }
          if (trick.jokerCall == JokerCallType.jokerCall) {
            event = 'JOKER_CALLED';
          }
          if (trick.trickNumber == 1 && hasMighty) {
            event = 'FIRST_TRICK_MIGHTY';
          }

          final description = trickDescriptions != null && trickIdx < trickDescriptions.length
              ? trickDescriptions[trickIdx]
              : null;

          trickDetails.add({
            'trickNumber': trick.trickNumber,
            'winnerId': trick.winnerId,
            'leadPlayerId': trick.leadPlayerId,
            'wonByDeclarer': wonByDeclarer,
            'pointCards': pointCards,
            'hasMighty': hasMighty,
            'hasJoker': hasJoker,
            'hasGiruda': hasGiruda,
            'jokerCalled': trick.jokerCall == JokerCallType.jokerCall,
            'leadSuit': _suitName(trick.leadSuit),
            'cards': List.generate(trick.cards.length, (i) {
              final card = trick.cards[i];
              return {
                'playerId': trick.playerOrder[i],
                'suit': card.isJoker ? null : card.suit?.index,
                'rank': card.isJoker ? null : card.rank?.index,
                'isJoker': card.isJoker,
              };
            }),
            if (event != null) 'event': event,
            if (description != null) 'description': description,
          });
        }
      }

      final playerId = await getPlayerId();

      final body = {
        'gameId': gameUuid,
        'appVersion': '1.2.11',
        if (playerId != null) 'playerId': playerId,
        'allPassed': state.allPassed,
        'declarerId': state.declarerId,
        'giruda': _suitName(state.giruda),
        'bidAmount': state.currentBid?.tricks,
        'friendType': _friendTypeString(state.friendDeclaration),
        'friendCard': state.friendDeclaration?.card?.toJson(),
        'friendId': state.friendId,
        'actualAttackPoints': state.declarerTeamPoints,
        'actualDefensePoints': state.defenderTeamPoints,
        'contractFulfilled': state.declarerId != null && state.currentBid != null
            ? state.declarerWon
            : null,
        'isAutoPlay': isAutoPlay,
        'tricksWonByDeclarerTeam': tricksWonByDeclarerTeam,
        'tricksWonByDefenderTeam': tricksWonByDefenderTeam,
        'jokerCalled': jokerCalled,
        'trickDetails': trickDetails,
        'bidEvaluations': bidSnapshots.map((s) => s.toJson()).toList(),
        'kittyResult': kittySnapshot?.toJson(),
      };

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Fire-and-forget: silently ignore errors
    }
  }
}
