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

  /// 수비팀이 이 트릭에서 기루다를 실제로 냈는지 확인
  static bool _defensePlayedGiruda(Trick trick, GameState state) {
    final giruda = state.giruda;
    if (giruda == null) return false;
    final leadId = trick.leadPlayerId;
    final isLeaderAttack = leadId == state.declarerId || leadId == state.friendId;
    for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
      if (trick.playerOrder[i] == leadId) continue;
      final isPlayerAttack = trick.playerOrder[i] == state.declarerId || trick.playerOrder[i] == state.friendId;
      if (isLeaderAttack != isPlayerAttack &&
          !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
        return true;
      }
    }
    return false;
  }

  static String? _describeLeadFromIntentKo(Trick trick, GameState state, {Set<String>? playedCards}) {
    final intent = trick.leadIntent;
    if (intent == null) return null;

    final giruda = state.giruda;
    final declaredSuit = trick.leadSuit;
    final suitStr = declaredSuit != null ? _suitSymbols[declaredSuit] ?? '' : '';

    switch (intent) {
      case LeadIntent.jokerAfterFriend:
        return suitStr.isNotEmpty ? '프렌드 합류 후 조커 ($suitStr) → 점수 획득' : '프렌드 합류 후 조커 → 점수 획득';
      case LeadIntent.jokerLeadSuit:
        String desc = suitStr.isNotEmpty ? '조커 선공 ($suitStr)' : '조커 선공';
        if (declaredSuit != null && declaredSuit == giruda &&
            _defensePlayedGiruda(trick, state)) {
          desc += ' / 수비팀 기루다 소진 유도';
        }
        return desc;
      case LeadIntent.jokerGirudaExhaust:
        String desc = suitStr.isNotEmpty ? '조커 선공 ($suitStr)' : '조커 선공';
        if (_defensePlayedGiruda(trick, state)) {
          desc += ' / 수비팀 기루다 소진 유도';
        }
        return desc;
      case LeadIntent.mightyLead:
        return '마이티 선공';
      case LeadIntent.mightyTrick9:
        return '마이티 선공';
      case LeadIntent.topGirudaLead:
        return '기루다 최상위 선공';
      case LeadIntent.midGirudaMightyBait:
        return '기루다 중간으로 마이티 유도';
      case LeadIntent.midGirudaLead:
        return '기루다 중간 선공';
      case LeadIntent.midGirudaPassLead:
      case LeadIntent.lowGirudaFriendPass: {
        // 선 넘김 의도: 실제로 팀원이 이겼는지 확인
        final passWinnerId = trick.winnerId;
        if (passWinnerId != null && passWinnerId != trick.leadPlayerId) {
          final leaderIsAttack = trick.leadPlayerId == state.declarerId || trick.leadPlayerId == state.friendId;
          final winnerIsAttack = passWinnerId == state.declarerId || passWinnerId == state.friendId;
          if (leaderIsAttack != winnerIsAttack) {
            // 프렌드 공개 후 수비가 이긴 경우: 선 넘김 실패가 아니라 수비 기루다 소진 물패
            bool friendRevealed = false;
            final fc = state.friendDeclaration?.card;
            if (fc != null && playedCards != null) {
              if (fc.isMightyWith(giruda)) {
                final m = state.mighty;
                friendRevealed = m.suit != null && playedCards.contains('${m.suit!.index}-${m.rankValue}');
              } else if (fc.isJoker) {
                friendRevealed = playedCards.contains('joker');
              } else if (fc.suit != null) {
                friendRevealed = playedCards.contains('${fc.suit!.index}-${fc.rankValue}');
              }
            }
            if (friendRevealed) {
              return '기루다 물패 (수비 기루다 소진)';
            }
            return '기루다 중간으로 선 넘김 실패';
          }
        }
        return '기루다 중간으로 선 넘김';
      }
      case LeadIntent.soleGirudaLeadMaintain:
        return '공격 단독 기루다 보유, 선 유지';
      case LeadIntent.highCardAttack:
        return '추가 점수 공격';
      case LeadIntent.topNonGirudaLead:
        return '비기루다 최상위 선공';
      case LeadIntent.defenseTopCard: {
        // 공격팀이 컷 등으로 이겼으면 방어 실패
        final dtcWinnerId = trick.winnerId;
        if (dtcWinnerId != null && dtcWinnerId != trick.leadPlayerId) {
          final winnerIsAttack = dtcWinnerId == state.declarerId || dtcWinnerId == state.friendId;
          if (winnerIsAttack) return '수비 최상위 카드 선공';
        }
        return '수비 최상위 카드 점수 방어';
      }
      case LeadIntent.firstTrickTopAttack:
        // 선공 플레이어가 직접 이겼는지 구분
        if (trick.winnerId == trick.leadPlayerId) {
          return '초구 비기루다 최상위 선공';
        }
        final ftaIsAttack = (int id) => id == state.declarerId || id == state.friendId;
        final ftaAttackWon = trick.winnerId != null && ftaIsAttack(trick.winnerId!);
        if (ftaAttackWon) {
          return '초구 비기루다 최상위 선공';
        }
        return '초구 비기루다 최상위 선공 실패';
      case LeadIntent.firstTrickMightyBait:
        return '초구 부재 / 물패로 마이티 프렌드 유도';
      case LeadIntent.firstTrickFriendBait:
        return '초구 부재 / 물패 소진 → 행운의 프렌드 승리';
      case LeadIntent.firstTrickWaste:
        return '초구 부재 / 물패 처리';
      case LeadIntent.declarerFriendLure:
        return '프렌드 유도';
      case LeadIntent.defenseMightyExhaust:
        return '수비 마이티 소진 유도 성공';
      case LeadIntent.defenseMightySuitBait:
        final dmbMightyAppeared = trick.cards.asMap().entries.any((e) {
          final idx = trick.playerOrder.indexOf(trick.leadPlayerId);
          return e.key != idx && !e.value.isJoker &&
              e.value.suit == state.mighty.suit && e.value.rank == state.mighty.rank;
        });
        return dmbMightyAppeared ? '마이티 무늬 선공 / 마이티 유도 성공' : '마이티 무늬 선공 (마이티 유도)';
      case LeadIntent.friendVoidPass:
        return '물패 처리';
      case LeadIntent.friendTopCardLead:
        return '비기루다 최상위 선공';
      case LeadIntent.defenseJokerLead:
        return '조커 선공';
      case LeadIntent.defenseHighCard: {
        // 해당 무늬의 최상위 카드가 아니면 수비 물패 공격으로 표시
        final dhcLeadCard = trick.leadCard;
        if (dhcLeadCard != null && !dhcLeadCard.isJoker && dhcLeadCard.suit != null && playedCards != null) {
          bool isTop = true;
          final mighty = state.mighty;
          for (int r = 14; r > dhcLeadCard.rankValue; r--) {
            if (dhcLeadCard.suit == mighty.suit && r == mighty.rankValue) continue;
            if (!playedCards.contains('${dhcLeadCard.suit!.index}-$r')) { isTop = false; break; }
          }
          if (!isTop) return '수비 물패 공격';
        }
        return '수비 최상위 카드 점수 방어';
      }
      case LeadIntent.defenseLowCard:
        return '물패 처리';
      case LeadIntent.waste:
        return '물패 처리';
      case LeadIntent.girudaPreExchange:
        return '선교환 (기루다 보존)';
      case LeadIntent.jokerCallLead:
        String jcDesc = '조커콜 선언';
        final jcLeadId = trick.leadPlayerId;
        final jcLeadIsAttack = jcLeadId == state.declarerId || jcLeadId == state.friendId;
        for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
          if (trick.cards[i].isJoker) {
            final jokerId = trick.playerOrder[i];
            final jokerIsAttack = jokerId == state.declarerId || jokerId == state.friendId;
            if (jcLeadIsAttack == jokerIsAttack) {
              jcDesc += ' → 아군 조커 헌납';
            } else {
              jcDesc += ' → 상대 조커 소진';
            }
            break;
          }
        }
        return jcDesc;
    }
  }

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

    // 트릭 10: 마지막 트릭 + 점수 + 승패 확정
    if (trick.trickNumber == 10) {
      final lastParts = <String>[];
      final pointCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;

      // 게임 결과 선계산 (키티 점수 포함)
      int attackPoints = 0;
      for (final t in state.tricks) {
        if (t.winnerId != null && isAttack(t.winnerId!)) {
          attackPoints += t.cards.where((c) => !c.isJoker && c.isPointCard).length;
        }
      }
      // 키티(버린 카드) 점수는 주공팀에 귀속
      for (final c in state.kitty) {
        if (c.isPointCard) attackPoints++;
      }
      final bidTricks = state.currentBid?.tricks ?? 13;
      final attackWins = attackPoints >= bidTricks;

      {
        String? lastLabel;
        if (trick.winnerId != null) {
          final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
          if (winIdx >= 0 && winIdx < trick.cards.length) {
            final winCard = trick.cards[winIdx];
            final leadIsAttack = isAttack(leadId);
            final winnerIsAttack = isAttack(trick.winnerId!);
            final wonByOvertake = trick.winnerId != leadId;

            if (isMighty(winCard)) {
              lastLabel = '마이티 마지막 트릭';
            } else if (isGiruda(winCard) && wonByOvertake) {
              // 선공 → 상위 기루다 역전 설명
              final leadSuitStr = leadCard.suit != null ? (_suitSymbols[leadCard.suit] ?? '') : '';
              final leadRankStr = _rankSymbols[leadCard.rankValue] ?? '${leadCard.rankValue}';
              final winRankStr = _rankSymbols[winCard.rankValue] ?? '${winCard.rankValue}';
              final girudaStr = _suitSymbols[giruda] ?? '';
              if (leadIsAttack && !winnerIsAttack) {
                // 공격 선공 → 수비 상위 기루다 역전
                if (isGiruda(leadCard)) {
                  lastLabel = '공격 $girudaStr$leadRankStr 선공 → 수비 $girudaStr$winRankStr 역전';
                } else {
                  lastLabel = '공격 $leadSuitStr$leadRankStr 선공 → 수비 기루다 컷';
                }
              } else if (!leadIsAttack && winnerIsAttack) {
                // 수비 선공 → 공격 상위 기루다 역전
                if (isGiruda(leadCard)) {
                  lastLabel = '수비 $girudaStr$leadRankStr 선공 → 공격 $girudaStr$winRankStr 역전';
                } else {
                  lastLabel = '수비 $leadSuitStr$leadRankStr 선공 → 공격 기루다 컷';
                }
              } else {
                lastLabel = '기루다 마지막 트릭';
              }
            } else if (isGiruda(winCard)) {
              lastLabel = '기루다 마지막 트릭';
            }
          }
        }
        // "마지막 카드"는 최상위 카드가 아닐 때만 표시
        if (lastLabel == null && !leadCard.isJoker && leadCard.suit != null) {
          bool isLeadTop = leadCard.rankValue >= 14;
          if (!isLeadTop && leadCard.suit != giruda) {
            isLeadTop = true;
            for (int r = 14; r > leadCard.rankValue; r--) {
              if (leadCard.suit == mighty.suit && r == mighty.rankValue) continue;
              if (!playedCards.contains('${leadCard.suit!.index}-$r')) { isLeadTop = false; break; }
            }
          }
          if (!isLeadTop) lastLabel = '마지막 카드';
        }
        if (lastLabel != null) lastParts.add(lastLabel);

        if (trick.winnerId != null && pointCount > 0 && !isAttack(trick.winnerId!)) {
          lastParts.add('수비 상위 카드 방어');
        }
      }

      // 게임 결과 (런만 별도 표기, 일반 승리는 총평에 포함되므로 생략)
      if (attackWins) {
        final isRun = state.tricks.every((t) => t.winnerId != null && isAttack(t.winnerId!));
        if (isRun) {
          lastParts.add('공격 런(풀) 대승 확정');
        }
      }

      // 총평 - 승패 원인 분석 (점수는 화면 상단에 표시되므로 제외)
      final attackTrickWins = state.tricks.where((t) => t.winnerId != null && isAttack(t.winnerId!)).length;
      final defenseTrickWins = 10 - attackTrickWins;

      if (attackTrickWins == 10) {
        lastParts.add('총평: 전승 런 대승');
      } else if (defenseTrickWins == 10) {
        lastParts.add('총평: 전패 백런 완패');
      } else {
        // 게임 흐름 분석
        final earlyDefWins = state.tricks.where((t) =>
            t.trickNumber <= 5 && t.winnerId != null && !isAttack(t.winnerId!)).length;
        final lateDefWins = state.tricks.where((t) =>
            t.trickNumber >= 7 && t.winnerId != null && !isAttack(t.winnerId!)).length;

        bool atkJoker = false, atkMighty = false;
        bool defJokerWon = false;
        int atkGirudaWins = 0;
        int defCutCount = 0;
        int friendScore = 0;

        for (final t in state.tricks) {
          for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
            if (isAttack(t.playerOrder[i])) {
              if (t.cards[i].isJoker) atkJoker = true;
              if (isMighty(t.cards[i])) atkMighty = true;
            }
          }
          if (t.winnerId != null) {
            if (!isAttack(t.winnerId!)) {
              final wIdx = t.playerOrder.indexOf(t.winnerId!);
              if (wIdx >= 0 && wIdx < t.cards.length && t.cards[wIdx].isJoker) defJokerWon = true;
              if (giruda != null && t.leadSuit != giruda && wIdx >= 0 && wIdx < t.cards.length && isGiruda(t.cards[wIdx])) {
                defCutCount++;
              }
            }
            if (isAttack(t.winnerId!) && giruda != null) {
              final wIdx = t.playerOrder.indexOf(t.winnerId!);
              if (wIdx >= 0 && wIdx < t.cards.length && isGiruda(t.cards[wIdx])) atkGirudaWins++;
            }
            if (state.friendId != null && t.winnerId == state.friendId) {
              friendScore += 2 + t.cards.where((c) => !c.isJoker && c.isPointCard).length;
            } else if (state.friendId != null && isAttack(t.winnerId!)) {
              final fIdx = t.playerOrder.indexOf(state.friendId!);
              if (fIdx >= 0 && fIdx < t.cards.length) {
                final fc = t.cards[fIdx];
                if (!fc.isJoker && fc.isPointCard) friendScore++;
              }
            }
          }
        }

        // 아군 조커콜 피해 확인
        String? jokerCallEvent;
        if (!attackWins) {
          for (final t in state.tricks) {
            if (t.jokerCall == JokerCallType.none) continue;
            for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
              if (t.cards[i].isJoker && isAttack(t.playerOrder[i]) &&
                  t.winnerId != null && !isAttack(t.winnerId!)) {
                jokerCallEvent = '아군 조커 헌납';
                break;
              }
            }
            if (jokerCallEvent != null) break;
          }
        }

        String summary;
        if (attackWins) {
          if (atkGirudaWins >= 3) {
            summary = '기루다 지배로 공격 승리';
          } else if (state.friendId != null && state.friendId != state.declarerId && friendScore >= 6) {
            summary = '프렌드 활약으로 공격 승리';
          } else if (atkJoker && atkMighty) {
            if (attackPoints == bidTricks) {
              summary = '조커/마이티 활용 최소 점수 달성';
            } else {
              summary = '조커/마이티 활용 공격 승리';
            }
          } else {
            summary = '공격 승리';
          }
        } else {
          if (jokerCallEvent != null) {
            summary = '아군 조커 헌납 → 수비 승리';
          } else if (earlyDefWins >= 3) {
            summary = '초반 선 빼앗김 → 탈환 실패 → 수비 승리';
          } else if (defJokerWon && defCutCount >= 2) {
            summary = '수비 조커 반격 + 기루다 컷으로 수비 승리';
          } else if (defJokerWon) {
            summary = '수비 조커 반격으로 수비 승리';
          } else if (defCutCount >= 2) {
            summary = '수비 기루다 컷으로 수비 승리';
          } else if (lateDefWins >= 3) {
            summary = '후반 수비 점수 방어로 수비 승리';
          } else if (atkJoker && atkMighty) {
            summary = '조커/마이티 활용 실패 → 수비 승리';
          } else {
            summary = '수비 승리';
          }
        }
        lastParts.add('총평: $summary');
      }

      return lastParts.join(' / ');
    }

    bool isTeammate(int winnerId) => isAttack(leadId) == isAttack(winnerId);
    final hasMightyInTrick = trick.cards.any((c) => isMighty(c));
    final isDeclarerLead = leadId == state.declarerId;

    bool girudaKInTrick = giruda != null && trick.cards.any((c) =>
        !c.isJoker && c.suit == giruda && c.rank == Rank.king);

    // 이번 트릭 이후 남은 기루다 최상위 카드 계산
    String? topRemainingGirudaStr;
    if (giruda != null) {
      final currentTrickGiruda = trick.cards
          .where((c) => !c.isJoker && c.suit == giruda)
          .map((c) => c.rankValue)
          .toSet();
      for (int r = 14; r >= 2; r--) {
        if (giruda == mighty.suit && r == mighty.rankValue) continue;
        if (playedCards.contains('${giruda.index}-$r')) continue;
        if (currentTrickGiruda.contains(r)) continue;
        topRemainingGirudaStr = '${_suitSymbols[giruda]}${_rankSymbols[r]}';
        break;
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
    bool isDefenseGirudaCut() {
      if (trick.leadSuit == giruda || giruda == null || trick.winnerId == null) return false;
      final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
      if (winIdx < 0 || winIdx >= trick.cards.length) return false;
      return isGiruda(trick.cards[winIdx]) && trick.winnerId != leadId && !isAttack(trick.winnerId!);
    }

    final parts = <String>[];

    // 수동게임에서 플레이어 선공 트릭은 선공 의도를 정확히 알 수 없으므로 결과만 표시
    final bool skipLeadDesc = !isAutoPlay && leadId == 0;

    // Lead card description
    bool leadDescribed = false;
    if (!skipLeadDesc && trick.leadIntent != null) {
      final leadDesc = _describeLeadFromIntentKo(trick, state, playedCards: playedCards);
      if (leadDesc != null) {
        parts.add(leadDesc);
        leadDescribed = true;
        if (trick.leadIntent == LeadIntent.defenseMightyExhaust ||
            trick.leadIntent == LeadIntent.midGirudaMightyBait ||
            trick.leadIntent == LeadIntent.defenseMightySuitBait) {
          mightyExhaustDescribed = true;
        }
      }
    }
    if (!leadDescribed && !skipLeadDesc) {
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
        if (declaredSuit != null && declaredSuit == giruda &&
            _defensePlayedGiruda(trick, state)) {
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
        // 상대 기루다 소진 시: 비기루다 공략, 기루다는 간용 보존
        {
          bool noOpponentGiruda = true;
          for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
            if (i == leadIdx) continue;
            if (isAttack(trick.playerOrder[i]) != isAttack(leadId) &&
                !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
              noOpponentGiruda = false;
              break;
            }
          }
          if (noOpponentGiruda) {
            parts.add('상대 기루다 소진 → 비기루다 공략, 기루다는 간용 보존');
          }
        }
      } else {
        if (hasMightyInTrick) {
          if (isAutoPlay && isDeclarerLead && topRemainingGirudaStr != null) {
            parts.add('$topRemainingGirudaStr 최상위 확보 위해 저액 기루다로 마이티 유도');
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
          bool defOvertake = false;
          for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
            if (i == leadIdx) continue;
            final c = trick.cards[i];
            if (!isAttack(trick.playerOrder[i]) && !c.isJoker &&
                c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
              defOvertake = true;
              break;
            }
          }
          if (defOvertake) {
            parts.add('프렌드 공격 → 수비 역전 시도 → 주공 재역전 (행운)');
          } else {
            parts.add('기루다 중간으로 선 넘김');
          }
        } else if (trick.winnerId != leadId && trick.winnerId != null && !isTeammate(trick.winnerId!)) {
          parts.add('수비팀 기루다 승리');
        } else {
          bool onlyLeaderHasGiruda = true;
          for (int i = 0; i < trick.cards.length; i++) {
            if (i == leadIdx) continue;
            if (!trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
              onlyLeaderHasGiruda = false;
              break;
            }
          }
          if (onlyLeaderHasGiruda && isAttack(leadId)) {
            parts.add('공격 단독 기루다 보유, 선 유지');
          } else {
            parts.add('기루다 중간 선공');
          }
        }
        // Check for high giruda card depletion failure
        if (isAttack(leadId) && giruda != null) {
          final girudaSymbol = _suitSymbols[giruda] ?? '';
          final Set<int> seenGirudaRanks = {};
          for (final pt in state.tricks) {
            if (pt.trickNumber > trick.trickNumber) break;
            for (final c in pt.cards) {
              if (!c.isJoker && c.suit == giruda) {
                seenGirudaRanks.add(c.rankValue);
              }
            }
          }
          int? highestUnflushed;
          for (final ft in state.tricks) {
            if (ft.trickNumber <= trick.trickNumber) continue;
            for (int i = 0; i < ft.cards.length && i < ft.playerOrder.length; i++) {
              final c = ft.cards[i];
              if (!c.isJoker && c.suit == giruda && !isMighty(c) &&
                  c.rankValue > leadCard.rankValue && c.rankValue >= 11 &&
                  !isAttack(ft.playerOrder[i]) && !seenGirudaRanks.contains(c.rankValue)) {
                if (highestUnflushed == null || c.rankValue > highestUnflushed) {
                  highestUnflushed = c.rankValue;
                }
                seenGirudaRanks.add(c.rankValue);
              }
            }
          }
          if (highestUnflushed != null) {
            final rankStr = _rankSymbols[highestUnflushed] ?? highestUnflushed.toString();
            parts.add('$girudaSymbol$rankStr 소진 실패');
          }
        }
      }
    } else {
      final isTop = leadCard.rankValue >= 14 || isTopOfSuit(leadCard.suit!, leadCard.rankValue);
      if (isTop) {
        if (isAutoPlay && isDeclarerLead && trick.trickNumber > 1) {
          parts.add('추가 점수 공격');
        } else if (!isAttack(leadId) && isAttackGirudaCut()) {
          parts.add('수비 비기루다 최상위 선공 → 공격 기루다 컷 선 탈환');
          girudaCutDescribed = true;
        } else if (isAttack(leadId) && isDefenseGirudaCut()) {
          parts.add('공격 비기루다 최상위 선공 → 수비 기루다 컷');
          girudaCutDescribed = true;
        } else if (!isAttack(leadId) && trick.winnerId != null && !isAttack(trick.winnerId!)) {
          bool declarerCutFailed = false;
          int defGirudaCount = 0;
          if (giruda != null && state.declarerId != null) {
            final declIdx = trick.playerOrder.indexOf(state.declarerId!);
            if (declIdx >= 0 && declIdx < trick.cards.length) {
              final declCard = trick.cards[declIdx];
              if (!declCard.isJoker && declCard.suit == giruda) {
                final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
                if (winIdx >= 0 && winIdx < trick.cards.length) {
                  final winCard = trick.cards[winIdx];
                  if (!winCard.isJoker && winCard.suit == giruda) {
                    declarerCutFailed = true;
                    for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
                      if (i == leadIdx) continue;
                      if (!isAttack(trick.playerOrder[i]) && !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
                        defGirudaCount++;
                      }
                    }
                  }
                }
              }
            }
          }
          if (declarerCutFailed && defGirudaCount >= 2) {
            parts.add('수비 최상위 선공 → 주공 기루다 컷 → 수비 팀워크 기루다 방어');
            girudaCutDescribed = true;
          } else if (declarerCutFailed) {
            parts.add('수비 최상위 선공 → 주공 기루다 컷 → 수비 상위 기루다 방어');
            girudaCutDescribed = true;
          } else {
            parts.add('수비 최상위 카드 점수 방어');
          }
        } else {
          parts.add('비기루다 최상위 선공');
        }
      } else if (trick.trickNumber == 1) {
        if (trick.winnerId != null && isAttack(trick.winnerId!)) {
          final isMightyFriend = state.friendDeclaration?.card != null &&
              state.friendDeclaration!.card!.isMightyWith(giruda);
          if (isMightyFriend) {
            parts.add('초구 부재 / 물패로 마이티 프렌드 유도');
          } else {
            parts.add('초구 부재 / 물패 소진 → 행운의 프렌드 승리');
          }
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

        // 주공 프렌드 유도
        bool isDeclarerFriendLure = false;
        if (leadId == state.declarerId && state.friendDeclaration?.card != null) {
          final fCard = state.friendDeclaration!.card!;
          final fSuit = fCard.isJoker ? null : fCard.suit;
          if (fSuit != null && leadCard.suit == fSuit) {
            bool friendCardInTrick = false;
            for (int i = 0; i < trick.cards.length; i++) {
              if (i == leadIdx) continue;
              final c = trick.cards[i];
              if (!c.isJoker && c.suit == fCard.suit && c.rank == fCard.rank) {
                friendCardInTrick = true;
                break;
              }
            }
            if (friendCardInTrick) {
              bool alreadyRevealed = false;
              for (final t in state.tricks) {
                if (t.trickNumber >= trick.trickNumber) break;
                for (final c in t.cards) {
                  if (!fCard.isJoker && !c.isJoker && c.suit == fCard.suit && c.rank == fCard.rank) {
                    alreadyRevealed = true;
                    break;
                  }
                }
                if (alreadyRevealed) break;
              }
              if (!alreadyRevealed) {
                isDeclarerFriendLure = true;
              }
            }
          }
        }

        // 프렌드 물패 → 주공 기루다 컷 시도 → 수비 기루다 재역전
        bool isFriendWasteDeclarerCutDefenseOvercut = false;
        if (isAttack(leadId) && leadId != state.declarerId &&
            leadCard.suit != giruda &&
            trick.winnerId != null && !isAttack(trick.winnerId!)) {
          final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
          if (winIdx >= 0 && winIdx < trick.cards.length) {
            final winCard = trick.cards[winIdx];
            if (!winCard.isJoker && winCard.suit == giruda) {
              if (state.declarerId != null) {
              final declIdx = trick.playerOrder.indexOf(state.declarerId!);
              if (declIdx >= 0 && declIdx < trick.cards.length) {
                final declCard = trick.cards[declIdx];
                if (!declCard.isJoker && declCard.suit == giruda) {
                  isFriendWasteDeclarerCutDefenseOvercut = true;
                }
              }
              }
            }
          }
        }

        // 프렌드 선공 → 수비 역전 → 주공 기루다 컷 재역전
        bool isFriendLeadDefenseBeatDeclarerCut = false;
        if (isAttack(leadId) && leadId != state.declarerId && trick.winnerId == state.declarerId) {
          final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
          if (winIdx >= 0 && winIdx < trick.cards.length) {
            final winCard = trick.cards[winIdx];
            if (!winCard.isJoker && winCard.suit == giruda && leadCard.suit != giruda) {
              for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
                if (i == leadIdx || i == winIdx) continue;
                final c = trick.cards[i];
                if (!isAttack(trick.playerOrder[i]) && !c.isJoker && c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
                  isFriendLeadDefenseBeatDeclarerCut = true;
                  break;
                }
              }
            }
          }
        }

        if (isDeclarerFriendLure) {
          if (trick.winnerId != null && isAttack(trick.winnerId!)) {
            parts.add('프렌드 유도');
          } else {
            parts.add('프렌드 유도 실패');
          }
        } else if (isFriendWasteDeclarerCutDefenseOvercut) {
          final ptCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;
          if (ptCount > 0) {
            parts.add('프렌드 물패 → 주공 기루다 컷 → 수비 기루다 재역전 ${ptCount}점 방어');
          } else {
            parts.add('프렌드 물패 → 주공 기루다 컷 → 수비 기루다 재역전');
          }
          girudaCutDescribed = true;
        } else if (isFriendLeadDefenseBeatDeclarerCut) {
          parts.add('프렌드 선공 → 수비 역전 → 주공 기루다 컷 재역전');
          girudaCutDescribed = true;
        // 수비팀이 마이티 무늬를 내서 마이티 소진 유도
        } else if (!isAttack(leadId) && leadCard.suit == mighty.suit && hasMightyInTrick) {
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
          final fWinIdx = trick.playerOrder.indexOf(trick.winnerId!);
          final fWinCard = (fWinIdx >= 0 && fWinIdx < trick.cards.length) ? trick.cards[fWinIdx] : null;
          final friendWonWithMighty = fWinCard != null && fWinCard.isMightyWith(giruda);
          if (!isAttack(leadId) && friendWonWithMighty) {
            if (topCardStr != null) {
              parts.add('물패 ($topCardStr 최상위) → 수비 공격을 마이티로 선 탈환');
            } else {
              parts.add('물패 → 수비 공격을 마이티로 선 탈환');
            }
          } else {
            if (topCardStr != null) {
              parts.add('물패 ($topCardStr 최상위) → 프렌드 기사회생!');
            } else {
              parts.add('물패 → 프렌드 기사회생!');
            }
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
    } // end if (!leadDescribed)

    // 조커콜 선언 (leadIntent로 리드 설명에 포함되지 않은 경우만)
    if (trick.jokerCall == JokerCallType.jokerCall && (skipLeadDesc || trick.leadIntent != LeadIntent.jokerCallLead)) {
      parts.add('조커콜 선언');
    }

    // Outcome: 기루다 컷 - 모든 컷 카운트
    if (!girudaCutDescribed && trick.leadSuit != giruda && giruda != null) {
      int attackCuts = 0;
      int defenseCuts = 0;
      for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
        if (i == leadIdx) continue;
        if (!trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
          if (isAttack(trick.playerOrder[i])) {
            attackCuts++;
          } else {
            defenseCuts++;
          }
        }
      }
      // 양 팀 모두 기루다 간 → 상위 기루다 역전/방어 설명
      if (attackCuts > 0 && defenseCuts > 0) {
        final attackWonThisTrick = trick.winnerId != null && isAttack(trick.winnerId!);
        if (attackWonThisTrick) {
          parts.add('수비 1차 간 → 공격 상위 기루다 컷');
        } else {
          parts.add('공격 1차 간 → 수비 상위 기루다 방어');
        }
      } else if (attackCuts > 0) {
        final leadIsAttack = isAttack(leadId);
        if (leadIsAttack) {
          // 같은팀 간: 선공자가 비기루다 최상위로 이기려 했는데 같은팀이 기루다 간한 경우만
          // 물패(선 넘기기 의도)일 때는 표시하지 않음
          bool leadWasTopOfSuit = false;
          if (!leadCard.isJoker && leadCard.suit != null && leadCard.suit != giruda) {
            leadWasTopOfSuit = true;
            for (int r = 14; r > leadCard.rankValue; r--) {
              if (leadCard.suit == mighty.suit && r == mighty.rankValue) continue;
              if (!playedCards.contains('${leadCard.suit!.index}-$r')) { leadWasTopOfSuit = false; break; }
            }
          }
          if (leadWasTopOfSuit) {
            parts.add(attackCuts > 1 ? '공격 기루다 소진 (같은팀 간 ${attackCuts}회)' : '같은팀 기루다 간 (불가피)');
          }
        } else {
          parts.add(attackCuts > 1 ? '공격 기루다 컷 ${attackCuts}회' : '공격 기루다 컷');
        }
      } else if (defenseCuts > 0) {
        final leadIsDefense = !isAttack(leadId);
        if (leadIsDefense) {
          // 같은팀 간: 선공자가 비기루다 최상위로 이기려 했는데 같은팀이 기루다 간한 경우만
          bool leadWasTopOfSuit = false;
          if (!leadCard.isJoker && leadCard.suit != null && leadCard.suit != giruda) {
            leadWasTopOfSuit = true;
            for (int r = 14; r > leadCard.rankValue; r--) {
              if (leadCard.suit == mighty.suit && r == mighty.rankValue) continue;
              if (!playedCards.contains('${leadCard.suit!.index}-$r')) { leadWasTopOfSuit = false; break; }
            }
          }
          if (leadWasTopOfSuit) {
            parts.add(defenseCuts > 1 ? '수비 기루다 소진 (같은팀 간 ${defenseCuts}회)' : '같은팀 기루다 간 (불가피)');
          }
        } else {
          parts.add(defenseCuts > 1 ? '수비 기루다 컷 ${defenseCuts}회' : '수비 기루다 컷');
        }
        bool attackHasGirudaLeft = false;
        for (final ft in state.tricks) {
          if (ft.trickNumber <= trick.trickNumber) continue;
          for (int i = 0; i < ft.cards.length && i < ft.playerOrder.length; i++) {
            if (isAttack(ft.playerOrder[i]) && !ft.cards[i].isJoker && ft.cards[i].suit == giruda) {
              attackHasGirudaLeft = true;
            }
          }
        }
        if (!attackHasGirudaLeft) {
          bool attackPlayedGirudaHere = false;
          for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
            if (isAttack(trick.playerOrder[i]) && !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
              attackPlayedGirudaHere = true;
            }
          }
          if (!attackPlayedGirudaHere) {
            parts.add('공격팀 기루다 소진 / 수비만 기루다 보유');
          }
        }
      }
    }

    // Outcome: K/Q 소진 성공 (공격팀 승리 시만)
    // 기루다 K가 프렌드 카드인 경우, K는 프렌드 합류이므로 소진이 아님
    final attackWonTrick = trick.winnerId != null && isAttack(trick.winnerId!);
    final girudaKIsFriend = friendCard != null && !friendCard.isJoker &&
        friendCard.suit == giruda && friendCard.rank == Rank.king;
    if (giruda != null && girudaKInTrick && attackWonTrick) {
      final kIdx = trick.cards.indexWhere((c) =>
          !c.isJoker && c.suit == giruda && c.rank == Rank.king);
      final qIdx = trick.cards.indexWhere((c) =>
          !c.isJoker && c.suit == giruda && c.rank == Rank.queen);
      if (girudaKIsFriend) {
        // K는 프렌드 합류이므로 Q 소진만 표기
        if (qIdx >= 0 && qIdx != leadIdx) {
          parts.add('Q 소진 성공');
        }
      } else if (kIdx >= 0 && kIdx != leadIdx && qIdx >= 0 && qIdx != leadIdx) {
        parts.add('K/Q 동시 소진 대성공');
      } else if (kIdx >= 0 && kIdx != leadIdx) {
        parts.add('K 소진 성공');
      }
    }

    // Outcome: 마이티 출현 (비선공 카드, 마이티 소진 유도에서 이미 기술된 경우 생략)
    if (!mightyExhaustDescribed) {
      for (int i = 0; i < trick.cards.length; i++) {
        if (i == leadIdx) continue;
        if (isMighty(trick.cards[i])) {
          // 마이티 무늬가 선공 무늬와 같으면 유일 보유로 불가피하게 낸 것
          final mightyFollowedSuit = mighty.suit != null && trick.leadSuit == mighty.suit;
          if (mightyFollowedSuit) {
            parts.add('마이티 유일 보유, 불가피한 출현');
          } else {
            parts.add('마이티 출현');
          }
          break;
        }
      }
    }

    // Outcome: 수비팀 조커 반격 / 런 저지
    {
      bool defenseJokerWin = false;
      for (int i = 0; i < trick.cards.length; i++) {
        if (i == leadIdx) continue;
        if (trick.cards[i].isJoker &&
            i < trick.playerOrder.length &&
            trick.winnerId == trick.playerOrder[i] &&
            !isAttack(trick.playerOrder[i])) {
          defenseJokerWin = true;
          break;
        }
      }
      if (defenseJokerWin) {
        if (trick.trickNumber >= 2) {
          final allPrevAttackWin = state.tricks
              .where((t) => t.trickNumber < trick.trickNumber)
              .every((t) => t.winnerId != null && isAttack(t.winnerId!));
          if (allPrevAttackWin) {
            parts.add('수비 조커 런 저지');
          }
        }
        final bool mightyAlreadyPlayed = mighty.suit != null &&
            playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}');
        if (mightyAlreadyPlayed) {
          parts.add('마이티 소멸 → 수비 조커 반격');
        }
      }
    }

    // Outcome: 조커 출현 (비선공 조커, 위에서 이미 기술되지 않은 경우)
    {
      bool jokerDescribedAbove = leadDescribed && (
          (trick.leadIntent == LeadIntent.jokerCallLead) ||
          (trick.leadIntent == LeadIntent.jokerLeadSuit) ||
          (trick.leadIntent == LeadIntent.jokerAfterFriend) ||
          (trick.leadIntent == LeadIntent.jokerGirudaExhaust) ||
          (trick.leadIntent == LeadIntent.defenseJokerLead));
      if (!jokerDescribedAbove) {
        for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
          if (i == leadIdx) continue;
          if (trick.cards[i].isJoker) {
            final jokerWon = trick.winnerId == trick.playerOrder[i];
            if (!jokerWon || isAttack(trick.playerOrder[i])) {
              parts.add('조커 출현');
            }
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
            if (giruda != null && friendPlayedCard.suit == giruda && friendPlayedCard.rank == Rank.king) {
              bool declarerHasGirudaA = false;
              for (final t in state.tricks) {
                for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
                  if (t.playerOrder[i] == state.declarerId && !t.cards[i].isJoker &&
                      t.cards[i].suit == giruda && t.cards[i].rank == Rank.ace) {
                    declarerHasGirudaA = true;
                  }
                }
              }
              parts.add(declarerHasGirudaA ? '프렌드 기루다 K 승리, 주공 A 보유 공격팀 기루다 장악' : '프렌드 최상위 카드 승리');
            } else {
              parts.add('프렌드 최상위 카드 승리');
            }
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
        if (jokerHolder != null && !isAttack(jokerHolder)) {
          final name = jokerHolder >= 0 && jokerHolder < _playerNamesKo.length ? _playerNamesKo[jokerHolder] : '?';
          parts.add('$name: 조커 보유, 무득점 트릭 스킵');
        }
      }

      if (giruda != null && !playedCards.contains('${giruda.index}-14') &&
          !trick.cards.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace)) {
        final girudaAHolder = findCardHolder((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
        // 선공자가 A를 쓰지 않은 것은 의도적 선택이므로 제외
        if (girudaAHolder != null && girudaAHolder != leadId) {
          // ★ 선행 무늬를 보유하여 기루다 A를 낼 수 없는 경우 제외
          // 선공자가 아니고, 선행 무늬가 기루다가 아니며, 선행 무늬를 따라냈으면
          // 기루다 A를 낼 수 있는 상황이 아니었으므로 "미사용" 표시 불필요
          bool couldPlayGirudaA = true;
          if (girudaAHolder != leadId && trick.leadSuit != null && trick.leadSuit != giruda) {
            final holderIdx = trick.playerOrder.indexOf(girudaAHolder);
            if (holderIdx >= 0 && holderIdx < trick.cards.length) {
              final holderCard = trick.cards[holderIdx];
              if (!holderCard.isJoker && holderCard.suit == trick.leadSuit) {
                couldPlayGirudaA = false;
              }
            }
          }
          // 같은팀 조커가 기루다를 호출한 경우, A를 아끼는 것은 당연한 전략이므로 제외
          if (leadCard.isJoker && trick.leadSuit == giruda &&
              isAttack(leadId) == isAttack(girudaAHolder)) {
            couldPlayGirudaA = false;
          }
          if (couldPlayGirudaA) {
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
    }

    // 수동게임 플레이어 선공: 선공 의도는 생략하되 트릭 결과는 표시
    if (parts.isEmpty && skipLeadDesc && trick.winnerId != null) {
      final leadIsAttack = isAttack(leadId);
      final winnerIsAttack = isAttack(trick.winnerId!);
      if (leadIsAttack) {
        parts.add(winnerIsAttack ? '공격팀 최상위 카드로 승리' : '공격팀 선공 실패');
      } else {
        parts.add(winnerIsAttack ? '수비팀 선공 실패' : '수비팀 최상위 카드로 승리');
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
