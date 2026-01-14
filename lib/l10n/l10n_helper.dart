import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';
import '../models/seven_card/poker_hand.dart';
import '../models/seven_card/seven_card_state.dart';
import '../models/hi_lo/hi_lo_state.dart';
import '../models/hi_lo/hi_lo_hand.dart';
import '../models/card.dart';
import '../models/game_state.dart';

/// AppLocalizations 인스턴스를 간편하게 가져오는 헬퍼 함수
AppLocalizations getL10n(BuildContext context) {
  return AppLocalizations.of(context)!;
}

/// 플레이어 인덱스에 해당하는 번역된 이름을 반환
String getPlayerName(BuildContext context, int playerIndex) {
  final l10n = getL10n(context);
  switch (playerIndex) {
    case 0:
      return l10n.player;
    case 1:
      return l10n.aiPlayer1;
    case 2:
      return l10n.aiPlayer2;
    case 3:
      return l10n.aiPlayer3;
    case 4:
      return l10n.aiPlayer4;
    default:
      return l10n.player;
  }
}

/// 5명 플레이어 이름 목록 반환 (마이티, 세븐포커, 하이로우 등)
List<String> getPlayerNames5(BuildContext context) {
  final l10n = getL10n(context);
  return [l10n.player, l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3, l10n.aiPlayer4];
}

/// 4명 플레이어 이름 목록 반환 (원카드, 하트, 훌라 등)
List<String> getPlayerNames4(BuildContext context) {
  final l10n = getL10n(context);
  return [l10n.player, l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3];
}

/// 포커 족보 이름 반환
String getHandRankName(BuildContext context, HandRank rank) {
  final l10n = getL10n(context);
  switch (rank) {
    case HandRank.royalStraightFlush:
      return l10n.handRoyalStraightFlush;
    case HandRank.backStraightFlush:
      return l10n.handBackStraightFlush;
    case HandRank.straightFlush:
      return l10n.handStraightFlush;
    case HandRank.fourOfAKind:
      return l10n.handFourOfAKind;
    case HandRank.fullHouse:
      return l10n.handFullHouse;
    case HandRank.flush:
      return l10n.handFlush;
    case HandRank.mountain:
      return l10n.handMountain;
    case HandRank.backStraight:
      return l10n.handBackStraight;
    case HandRank.straight:
      return l10n.handStraight;
    case HandRank.triple:
      return l10n.handTriple;
    case HandRank.twoPair:
      return l10n.handTwoPair;
    case HandRank.onePair:
      return l10n.handOnePair;
    case HandRank.highCard:
      return l10n.handHighCard;
  }
}

/// 포커 족보 표시 이름 반환 (하이카드는 X탑 형식)
String getHandRankDisplayName(BuildContext context, PokerHand? hand) {
  if (hand == null) return '';
  final l10n = getL10n(context);

  if (hand.rank == HandRank.highCard) {
    final highCard = hand.tiebreakers.isNotEmpty ? hand.tiebreakers.first : 0;
    return l10n.highCardTop(_getRankSymbol(highCard));
  }

  return getHandRankName(context, hand.rank);
}

/// 로우 핸드 표시 이름 반환
String getLowHandDisplayName(BuildContext context, LowHand? hand) {
  if (hand == null || !hand.isQualified) return getL10n(context).noLow;
  if (hand.cardRanks.isEmpty) return getL10n(context).noLow;

  final l10n = getL10n(context);
  final highCard = hand.cardRanks.last;

  String rankName;
  if (highCard == 1) {
    rankName = 'A';
  } else if (highCard == 11) {
    rankName = 'J';
  } else if (highCard == 12) {
    rankName = 'Q';
  } else if (highCard == 13) {
    rankName = 'K';
  } else {
    rankName = highCard.toString();
  }

  return l10n.highCardTop(rankName);
}

String _getRankSymbol(int rankValue) {
  switch (rankValue) {
    case 14: return 'A';
    case 13: return 'K';
    case 12: return 'Q';
    case 11: return 'J';
    case 10: return '10';
    default: return '$rankValue';
  }
}

/// 베팅 액션 이름 반환
String getBettingActionName(BuildContext context, String action) {
  final l10n = getL10n(context);
  switch (action) {
    case 'bing': return l10n.betPing;
    case 'check': return l10n.betCheck;
    case 'call': return l10n.betCall;
    case 'ddadang': return l10n.betDdadang;
    case 'quarter': return l10n.betQuarter;
    case 'half': return l10n.betHalf;
    case 'full': return l10n.betFull;
    case 'die': return l10n.betDie;
    default: return action;
  }
}

/// 하이로우 선택 이름 반환
String getHiLoChoiceName(BuildContext context, HiLoChoice choice) {
  final l10n = getL10n(context);
  switch (choice) {
    case HiLoChoice.hi: return l10n.hiLoHi;
    case HiLoChoice.lo: return l10n.hiLoLo;
    case HiLoChoice.swing: return l10n.hiLoSwing;
    case HiLoChoice.none: return '';
  }
}

/// 라운드 전환 메시지 반환
String getRoundTransitionMessage(BuildContext context, int roundNumber) {
  final l10n = getL10n(context);
  String message = '${l10n.roundComplete(roundNumber)}\n';

  switch (roundNumber) {
    case 1:
      message += '${l10n.cardDistribution5}\n\n${l10n.goodLuck}';
      break;
    case 2:
      message += '${l10n.cardDistribution6}\n\n${l10n.goodLuck}';
      break;
    case 3:
      message += '${l10n.cardDistribution7}\n\n${l10n.goodLuck}';
      break;
    default:
      message += l10n.goodLuck;
  }

  return message;
}

/// 무늬 이름 반환
String getSuitName(BuildContext context, Suit suit) {
  final l10n = getL10n(context);
  switch (suit) {
    case Suit.spade:
      return l10n.suitSpade;
    case Suit.diamond:
      return l10n.suitDiamond;
    case Suit.heart:
      return l10n.suitHeart;
    case Suit.club:
      return l10n.suitClub;
  }
}

/// 비드 표시 문자열 반환
String getBidDisplayString(BuildContext context, Bid bid) {
  if (bid.passed) return 'Pass';
  final l10n = getL10n(context);
  final suitStr = bid.suit != null ? getSuitName(context, bid.suit!) : l10n.noGiruda;
  return '${bid.tricks} $suitStr';
}

/// 프렌드 선언 표시 문자열 반환
String getFriendDeclarationString(BuildContext context, FriendDeclaration declaration) {
  final l10n = getL10n(context);
  if (declaration.isNoFriend) return l10n.noFriend;
  if (declaration.isFirstTrickWinner) return l10n.firstTrickFriend;
  if (declaration.card != null) return l10n.cardOwner(declaration.card.toString());
  if (declaration.trickNumber != null) return l10n.trickWinner(declaration.trickNumber!);
  return '';
}

/// 베팅 액션 텍스트 반환 (금액 포함) - 세븐포커용
String getBettingActionText(BuildContext context, BettingAction action, int amount) {
  final l10n = getL10n(context);
  switch (action) {
    case BettingAction.bing:
      return '${l10n.betPing} ($amount)';
    case BettingAction.check:
      return l10n.betCheck;
    case BettingAction.call:
      return '${l10n.betCall} ($amount)';
    case BettingAction.ddadang:
      return '${l10n.betDdadang} ($amount)';
    case BettingAction.quarter:
      return '${l10n.betQuarter} ($amount)';
    case BettingAction.half:
      return '${l10n.betHalf} ($amount)';
    case BettingAction.full:
      return '${l10n.betFull} ($amount)';
    case BettingAction.die:
      return l10n.betDie;
    case BettingAction.none:
      return '';
  }
}

/// 베팅 액션 텍스트 반환 (금액 포함) - 하이로우용
String getHiLoBettingActionText(BuildContext context, HiLoBettingAction action, int amount) {
  final l10n = getL10n(context);
  switch (action) {
    case HiLoBettingAction.bing:
      return '${l10n.betPing} ($amount)';
    case HiLoBettingAction.check:
      return l10n.betCheck;
    case HiLoBettingAction.call:
      return '${l10n.betCall} ($amount)';
    case HiLoBettingAction.ddadang:
      return '${l10n.betDdadang} ($amount)';
    case HiLoBettingAction.quarter:
      return '${l10n.betQuarter} ($amount)';
    case HiLoBettingAction.half:
      return '${l10n.betHalf} ($amount)';
    case HiLoBettingAction.full:
      return '${l10n.betFull} ($amount)';
    case HiLoBettingAction.die:
      return l10n.betDie;
    case HiLoBettingAction.none:
      return '';
  }
}

/// 베팅 액션 이름 반환 (문자열 기반) - AI 추천용
String getBettingActionNameFromString(BuildContext context, String action) {
  final l10n = getL10n(context);
  switch (action) {
    case 'bing':
      return l10n.betPing;
    case 'check':
      return l10n.betCheck;
    case 'call':
      return l10n.betCall;
    case 'ddadang':
      return l10n.betDdadang;
    case 'quarter':
      return l10n.betQuarter;
    case 'half':
      return l10n.betHalf;
    case 'full':
      return l10n.betFull;
    case 'die':
      return l10n.betDie;
    default:
      return action;
  }
}
