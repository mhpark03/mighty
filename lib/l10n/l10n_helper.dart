import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';
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

/// 5명 플레이어 이름 목록 반환 (마이티 등)
List<String> getPlayerNames5(BuildContext context) {
  final l10n = getL10n(context);
  return [l10n.player, l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3, l10n.aiPlayer4];
}

/// 4명 플레이어 이름 목록 반환 (원카드, 하트, 훌라 등)
List<String> getPlayerNames4(BuildContext context) {
  final l10n = getL10n(context);
  return [l10n.player, l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3];
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

