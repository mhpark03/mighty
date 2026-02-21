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

  static const _playerNamesKo = ['플레이어', '민준', '서연', '지호', '수빈'];
  static const _suitSymbols = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
  static const _rankSymbols = {14: 'A', 13: 'K', 12: 'Q', 11: 'J', 10: '10', 9: '9', 8: '8', 7: '7', 6: '6', 5: '5', 4: '4', 3: '3', 2: '2'};

  static String? _describeTrickKo(Trick trick, GameState state, Set<String> playedCards, {bool isAutoPlay = false}) {
    if (trick.cards.isEmpty) return null;

    final giruda = state.giruda;
    final leadId = trick.leadPlayerId;
    final leadIdx = trick.playerOrder.indexOf(leadId);
    if (leadIdx < 0 || leadIdx >= trick.cards.length) return null;
    final leadCard = trick.cards[leadIdx];

    final mighty = state.mighty;
    bool isMighty(PlayingCard c) => !c.isJoker && c.suit == mighty.suit && c.rank == mighty.rank;
    bool isGiruda(PlayingCard c) => !c.isJoker && giruda != null && c.suit == giruda;
    bool isAttack(int id) => id == state.declarerId || id == state.friendId;

    // 트릭 10: 마지막 카드 + 승패 결과
    if (trick.trickNumber == 10) {
      final lastParts = <String>['마지막 카드'];
      final pointCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;
      if (trick.winnerId != null && pointCount > 0) {
        if (!isAttack(trick.winnerId!)) {
          lastParts.add('수비 상위 카드 ${pointCount}점 방어');
        } else {
          lastParts.add('공격 ${pointCount}점 획득');
        }
        if (trick.winnerId != leadId && pointCount >= 2) {
          final leadName = leadId >= 0 && leadId < _playerNamesKo.length ? _playerNamesKo[leadId] : '?';
          lastParts.add('$leadName 선공 실패, ${pointCount}점 놓침');
        }
      }
      return lastParts.join(' / ');
    }

    bool isTeammate(int winnerId) => isAttack(leadId) == isAttack(winnerId);
    final hasMightyInTrick = trick.cards.any((c) => isMighty(c));
    final isDeclarerLead = leadId == state.declarerId;

    bool girudaKInTrick = giruda != null && trick.cards.any((c) =>
        !c.isJoker && c.suit == giruda && c.rank == Rank.king);

    bool declarerPlaysGirudaA = false;
    bool declarerPlaysGirudaQ = false;
    if (isAutoPlay && giruda != null) {
      for (final t in state.tricks) {
        for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
          if (t.playerOrder[i] == state.declarerId) {
            final c = t.cards[i];
            if (!c.isJoker && c.suit == giruda) {
              if (c.rank == Rank.ace) declarerPlaysGirudaA = true;
              if (c.rank == Rank.queen) declarerPlaysGirudaQ = true;
            }
          }
        }
      }
    }

    bool friendAlreadyRevealed = false;
    final friendCard = state.friendDeclaration?.card;
    if (friendCard != null) {
      if (friendCard.isMightyWith(giruda)) {
        friendAlreadyRevealed = mighty.suit != null && playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}');
      } else if (friendCard.isJoker) {
        friendAlreadyRevealed = playedCards.any((s) => s == 'joker');
      } else if (friendCard.suit != null) {
        friendAlreadyRevealed = playedCards.contains('${friendCard.suit!.index}-${friendCard.rankValue}');
      }
    }

    bool isTopOfSuit(Suit suit, int rankValue) {
      final mightySuit = mighty.suit;
      final mightyRankValue = mighty.rankValue;
      for (int r = 14; r > rankValue; r--) {
        if (suit == mightySuit && r == mightyRankValue) continue;
        if (!playedCards.contains('${suit.index}-$r')) return false;
      }
      return true;
    }

    bool girudaCutDescribed = false;
    bool mightyExhaustDescribed = false;
    bool isAttackGirudaCut() {
      if (trick.leadSuit == giruda || giruda == null || trick.winnerId == null) return false;
      final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
      if (winIdx < 0 || winIdx >= trick.cards.length) return false;
      return isGiruda(trick.cards[winIdx]) && trick.winnerId != leadId && isAttack(trick.winnerId!);
    }

    final parts = <String>[];

    // Lead card description
    if (leadCard.isJoker) {
      final declaredSuit = trick.leadSuit;
      final suitStr = declaredSuit != null ? _suitSymbols[declaredSuit] ?? '' : '';
      if (isAutoPlay && isDeclarerLead && friendAlreadyRevealed) {
        String jokerDesc = suitStr.isNotEmpty
            ? '프렌드 합류 후 조커 ($suitStr) → 점수 획득'
            : '프렌드 합류 후 조커 → 점수 획득';
        parts.add(jokerDesc);
      } else {
        String jokerDesc = suitStr.isNotEmpty
            ? '조커 선공 ($suitStr)'
            : '조커 선공';
        if (declaredSuit != null && declaredSuit == giruda) {
          jokerDesc += ' / 수비팀 기루다 소진 유도';
        }
        parts.add(jokerDesc);
      }
    } else if (isMighty(leadCard)) {
      parts.add('마이티 선공');
    } else if (isGiruda(leadCard)) {
      final isTop = leadCard.rankValue >= 14 || isTopOfSuit(leadCard.suit!, leadCard.rankValue);
      if (isTop) {
        parts.add('기루다 최상위 선공');
      } else {
        if (hasMightyInTrick) {
          if (isAutoPlay && isDeclarerLead && declarerPlaysGirudaA) {
            parts.add('A 최상위 확보 위해 저액 기루다로 마이티 유도');
          } else if (isAutoPlay && isDeclarerLead && declarerPlaysGirudaQ) {
            parts.add('Q 공격 위해 저액 기루다로 마이티 유도');
          } else {
            parts.add('기루다 중간으로 마이티 유도');
          }
        } else if (isAutoPlay && isDeclarerLead && leadCard.rank == Rank.queen) {
          final won = trick.winnerId == leadId;
          if (won) {
            parts.add('기루다 Q → 선 탈환 성공');
          } else {
            parts.add('기루다 Q 선 탈환 실패, 수비 승리');
          }
        } else if (trick.winnerId != leadId && trick.winnerId != null && isTeammate(trick.winnerId!)) {
          parts.add('기루다 중간으로 선 넘김');
        } else if (trick.winnerId != leadId && trick.winnerId != null && !isTeammate(trick.winnerId!)) {
          parts.add('수비팀 기루다 승리');
        } else {
          parts.add('기루다 중간 선공');
        }
      }
    } else {
      final isTop = leadCard.rankValue >= 14 || isTopOfSuit(leadCard.suit!, leadCard.rankValue);
      if (isTop) {
        if (isAutoPlay && isDeclarerLead && trick.trickNumber > 1) {
          parts.add('추가 점수 공격');
        } else if (!isAttack(leadId) && isAttackGirudaCut()) {
          parts.add('수비 비기루다 공격 → 기루다 컷 선 탈환');
          girudaCutDescribed = true;
        } else if (!isAttack(leadId) && trick.winnerId != null && !isAttack(trick.winnerId!)) {
          parts.add('수비 최상위 카드 점수 방어');
        } else {
          parts.add('비기루다 최상위 선공');
        }
      } else if (trick.trickNumber == 1) {
        if (trick.winnerId != null && isAttack(trick.winnerId!)) {
          parts.add('초구 부재 / 물패로 프렌드 유도');
        } else {
          parts.add('초구 부재 / 물패 처리');
        }
      } else {
        String? topCardStr;
        if (leadCard.suit != null) {
          final s = leadCard.suit!;
          for (int r = 14; r > leadCard.rankValue; r--) {
            if (s == mighty.suit && r == mighty.rankValue) continue;
            if (!playedCards.contains('${s.index}-$r')) {
              topCardStr = '${_suitSymbols[s]}${_rankSymbols[r]}';
              break;
            }
          }
        }

        bool leadPlayedBestOfSuit = false;
        if (leadCard.suit != null && isAttack(leadId)) {
          leadPlayedBestOfSuit = true;
          for (final c in state.players[leadId].hand) {
            if (!c.isJoker && c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
              leadPlayedBestOfSuit = false;
              break;
            }
          }
          if (leadPlayedBestOfSuit) {
            for (final t in state.tricks) {
              if (t.trickNumber <= trick.trickNumber) continue;
              for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
                if (t.playerOrder[i] == leadId) {
                  final c = t.cards[i];
                  if (!c.isJoker && c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
                    leadPlayedBestOfSuit = false;
                  }
                }
              }
              if (!leadPlayedBestOfSuit) break;
            }
          }
        }

        // 수비팀이 마이티 무늬를 내서 마이티 소진 유도
        if (!isAttack(leadId) && leadCard.suit == mighty.suit && hasMightyInTrick) {
          final ptCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;
          if (ptCount <= 1) {
            parts.add('수비 마이티 소진 유도 성공');
          } else {
            parts.add('수비 마이티 유도, ${ptCount}점 유출');
          }
          mightyExhaustDescribed = true;
        } else if (trick.winnerId != null && trick.winnerId != leadId && trick.winnerId == state.declarerId) {
          if (topCardStr != null) {
            parts.add('물패 ($topCardStr 최상위) → 주공 선 탈환');
          } else {
            parts.add('물패 → 주공 선 탈환');
          }
        } else if (trick.winnerId != null && trick.winnerId != leadId && isAttack(trick.winnerId!)) {
          if (topCardStr != null) {
            parts.add('물패 ($topCardStr 최상위) → 프렌드 기사회생!');
          } else {
            parts.add('물패 → 프렌드 기사회생!');
          }
        } else if (leadPlayedBestOfSuit && trick.winnerId != null && trick.winnerId != leadId && !isAttack(trick.winnerId!)) {
          if (topCardStr != null) {
            parts.add('공격 ($topCardStr 최상위) 실패 → 수비에 패배');
          } else {
            parts.add('공격 실패 → 수비 상위 카드에 패배');
          }
        } else {
          if (topCardStr != null) {
            parts.add('물패 ($topCardStr 최상위)');
          } else {
            parts.add('물패 처리');
          }
        }
      }
    }

    // Outcome: 기루다 컷
    if (!girudaCutDescribed && trick.leadSuit != giruda && giruda != null && trick.winnerId != null) {
      final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
      if (winIdx >= 0 && winIdx < trick.cards.length) {
        final winCard = trick.cards[winIdx];
        if (isGiruda(winCard) && trick.winnerId != leadId) {
          if (isAttack(trick.winnerId!)) {
            parts.add('공격 기루다 컷');
          } else {
            parts.add('수비 기루다 컷');
          }
        }
      }
    }

    // Outcome: K 소진 성공
    if (giruda != null && girudaKInTrick) {
      final kIdx = trick.cards.indexWhere((c) =>
          !c.isJoker && c.suit == giruda && c.rank == Rank.king);
      if (kIdx >= 0 && kIdx != leadIdx) {
        parts.add('K 소진 성공');
      }
    }

    // Outcome: 마이티 출현 (비선공 카드, 마이티 소진 유도에서 이미 기술된 경우 생략)
    if (!mightyExhaustDescribed) {
      for (int i = 0; i < trick.cards.length; i++) {
        if (i == leadIdx) continue;
        if (isMighty(trick.cards[i])) {
          parts.add('마이티 출현');
          break;
        }
      }
    }

    // Outcome: 마이티 소멸 후 수비팀 조커 반격
    {
      final bool mightyAlreadyPlayed = mighty.suit != null &&
          playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}');
      if (mightyAlreadyPlayed) {
        for (int i = 0; i < trick.cards.length; i++) {
          if (i == leadIdx) continue;
          if (trick.cards[i].isJoker &&
              i < trick.playerOrder.length &&
              trick.winnerId == trick.playerOrder[i] &&
              !isAttack(trick.playerOrder[i])) {
            parts.add('마이티 소멸 → 수비 조커 반격');
            break;
          }
        }
      }
    }

    // Outcome: 프렌드 합류
    if (friendCard != null && !friendAlreadyRevealed) {
      bool friendInTrick = false;
      if (friendCard.isJoker) {
        friendInTrick = trick.cards.any((c) => c.isJoker);
      } else if (friendCard.suit != null) {
        friendInTrick = trick.cards.any((c) =>
            !c.isJoker && c.suit == friendCard.suit && c.rank == friendCard.rank);
      }
      if (friendInTrick) {
        parts.add('프렌드 합류');
      }
    }

    // Outcome: 프렌드 최상위 카드 승리 & 공격 기여
    if (state.friendRevealed && state.friendId != null && trick.winnerId == state.friendId) {
      final friendPlayerIdx = trick.playerOrder.indexOf(state.friendId!);
      if (friendPlayerIdx >= 0 && friendPlayerIdx < trick.cards.length) {
        final friendPlayedCard = trick.cards[friendPlayerIdx];
        if (!friendPlayedCard.isJoker && !friendPlayedCard.isMightyWith(giruda) &&
            friendPlayedCard.suit != null) {
          if (isTopOfSuit(friendPlayedCard.suit!, friendPlayedCard.rankValue)) {
            parts.add('프렌드 최상위 카드 승리');
          }
        }
      }
      int friendWinCount = 0;
      for (final t in state.tricks) {
        if (t.trickNumber > trick.trickNumber) break;
        if (t.winnerId == state.friendId) friendWinCount++;
      }
      if (friendWinCount >= 2) {
        parts.add('프렌드 도움 ${friendWinCount}트릭 공격 성공');
      }
    }

    // 주요 카드 보유 미사용 분석
    {
      int? findCardHolder(bool Function(PlayingCard) matcher) {
        for (final pid in trick.playerOrder) {
          if (state.players[pid].hand.any(matcher)) return pid;
        }
        for (final t in state.tricks) {
          if (t.trickNumber <= trick.trickNumber) continue;
          for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
            if (matcher(t.cards[i])) return t.playerOrder[i];
          }
        }
        return null;
      }

      final pointCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;

      if (trick.trickNumber > 1 && !playedCards.contains('joker') &&
          !trick.cards.any((c) => c.isJoker) && pointCount == 0) {
        final jokerHolder = findCardHolder((c) => c.isJoker);
        if (jokerHolder != null) {
          final name = jokerHolder >= 0 && jokerHolder < _playerNamesKo.length ? _playerNamesKo[jokerHolder] : '?';
          parts.add('$name: 조커 보유, 무득점 트릭 스킵');
        }
      }

      if (giruda != null && !playedCards.contains('${giruda.index}-14') &&
          !trick.cards.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace)) {
        final girudaAHolder = findCardHolder((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
        if (girudaAHolder != null) {
          final name = girudaAHolder >= 0 && girudaAHolder < _playerNamesKo.length ? _playerNamesKo[girudaAHolder] : '?';
          final mightyPlayed = mighty.suit != null &&
              (playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}') ||
               trick.cards.any((c) => isMighty(c)));
          if (!mightyPlayed && !isAttack(girudaAHolder)) {
            parts.add('$name: 기루다 A 보유, 마이티 경계로 미사용');
          } else if (mightyPlayed) {
            parts.add('$name: 기루다 A 보유, 미사용');
          }
        }
      }
    }

    return parts.isNotEmpty ? parts.join(' / ') : null;
  }

  /// Fire-and-forget: sends game result to server, ignores errors
  static void sendGameResult({
    required String gameUuid,
    required GameState state,
    required List<BidEvaluationSnapshot> bidSnapshots,
    KittySnapshot? kittySnapshot,
    required bool isAutoPlay,
  }) {
    _doSend(
      gameUuid: gameUuid,
      state: state,
      bidSnapshots: bidSnapshots,
      kittySnapshot: kittySnapshot,
      isAutoPlay: isAutoPlay,
    );
  }

  static Future<void> _doSend({
    required String gameUuid,
    required GameState state,
    required List<BidEvaluationSnapshot> bidSnapshots,
    KittySnapshot? kittySnapshot,
    required bool isAutoPlay,
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
        final playedCards = <String>{};
        for (final trick in state.tricks) {
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

          // Compute description before updating playedCards
          final description = _describeTrickKo(trick, state, playedCards, isAutoPlay: isAutoPlay);

          // Update playedCards after description
          for (final c in trick.cards) {
            if (c.isJoker) {
              playedCards.add('joker');
            } else if (c.suit != null) {
              playedCards.add('${c.suit!.index}-${c.rankValue}');
            }
          }

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

      final body = {
        'gameId': gameUuid,
        'appVersion': '1.0.99',
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
