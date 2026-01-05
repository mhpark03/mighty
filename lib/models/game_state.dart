import 'dart:math';

import 'card.dart';
import 'player.dart';

enum GamePhase {
  waiting,
  dealing,
  bidding,
  selectingKitty,
  declaringFriend,
  playing,
  roundEnd,
  gameEnd,
}

enum JokerCallType {
  none,
  jokerCall,
  jokerCalled,
}

class Bid {
  final int playerId;
  final Suit? suit;
  final int tricks;
  final bool passed;

  const Bid({
    required this.playerId,
    this.suit,
    required this.tricks,
    this.passed = false,
  });

  factory Bid.pass(int playerId) => Bid(
        playerId: playerId,
        tricks: 0,
        passed: true,
      );

  bool isHigherThan(Bid other) {
    if (other.passed) return true;
    if (tricks > other.tricks) return true;
    if (tricks == other.tricks && suit == null && other.suit != null) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    if (passed) return 'Pass';
    final suitStr = suit != null ? _suitToString(suit!) : '노기루다';
    return '$tricks $suitStr';
  }

  String _suitToString(Suit suit) {
    switch (suit) {
      case Suit.spade:
        return '스페이드';
      case Suit.diamond:
        return '다이아몬드';
      case Suit.heart:
        return '하트';
      case Suit.club:
        return '클럽';
    }
  }
}

class FriendDeclaration {
  final PlayingCard? card;
  final int? trickNumber;
  final bool isFirstTrickWinner;
  final bool isNoFriend;

  const FriendDeclaration({
    this.card,
    this.trickNumber,
    this.isFirstTrickWinner = false,
    this.isNoFriend = false,
  });

  factory FriendDeclaration.noFriend() =>
      const FriendDeclaration(isNoFriend: true);

  factory FriendDeclaration.firstTrickWinner() =>
      const FriendDeclaration(isFirstTrickWinner: true);

  factory FriendDeclaration.byCard(PlayingCard card) =>
      FriendDeclaration(card: card);

  factory FriendDeclaration.byTrick(int trickNumber) =>
      FriendDeclaration(trickNumber: trickNumber);

  @override
  String toString() {
    if (isNoFriend) return '노프렌드';
    if (isFirstTrickWinner) return '초구 프렌드';
    if (card != null) return '${card!} 소유자';
    if (trickNumber != null) return '$trickNumber번째 트릭 획득자';
    return '';
  }
}

class Trick {
  final int trickNumber;
  final List<PlayingCard> cards;
  final List<int> playerOrder;
  final int leadPlayerId;
  Suit? leadSuit;
  int? winnerId;
  JokerCallType jokerCall;
  Suit? jokerCallSuit;  // 조커 콜로 지정된 무늬
  Suit? jokerLeadSuit;  // 조커 선공 시 지정된 무늬

  Trick({
    required this.trickNumber,
    required this.leadPlayerId,
    List<PlayingCard>? cards,
    List<int>? playerOrder,
    this.leadSuit,
    this.winnerId,
    this.jokerCall = JokerCallType.none,
    this.jokerCallSuit,
    this.jokerLeadSuit,
  })  : cards = cards ?? [],
        playerOrder = playerOrder ?? [];

  void addCard(PlayingCard card, int playerId, {Suit? jokerSuit}) {
    if (cards.isEmpty) {
      if (card.isJoker) {
        // 조커 선공 시 지정된 무늬를 leadSuit으로 사용
        jokerLeadSuit = jokerSuit;
        leadSuit = jokerSuit;
      } else {
        leadSuit = card.suit;
      }
    }
    cards.add(card);
    playerOrder.add(playerId);
  }

  bool get isComplete => cards.length == 5;

  PlayingCard? get leadCard => cards.isNotEmpty ? cards.first : null;
}

class GameState {
  final List<Player> players;
  final Deck deck;
  GamePhase phase;
  List<PlayingCard> kitty;
  Bid? currentBid;
  int currentBidder;
  List<bool> passedPlayers;
  int? declarerId;
  int? friendId;
  Suit? giruda;
  FriendDeclaration? friendDeclaration;
  bool friendRevealed;
  List<Trick> tricks;
  Trick? currentTrick;
  int currentPlayer;
  int startingPlayer;
  bool mightyJokerUsed;
  int declarerTeamPoints;
  int defenderTeamPoints;

  GameState({
    required this.players,
    Deck? deck,
    this.phase = GamePhase.waiting,
    List<PlayingCard>? kitty,
    this.currentBid,
    this.currentBidder = 0,
    List<bool>? passedPlayers,
    this.declarerId,
    this.friendId,
    this.giruda,
    this.friendDeclaration,
    this.friendRevealed = false,
    List<Trick>? tricks,
    this.currentTrick,
    this.currentPlayer = 0,
    this.startingPlayer = 0,
    this.mightyJokerUsed = false,
    this.declarerTeamPoints = 0,
    this.defenderTeamPoints = 0,
  })  : deck = deck ?? Deck(),
        kitty = kitty ?? [],
        passedPlayers = passedPlayers ?? List.filled(5, false),
        tricks = tricks ?? [];

  Player get declarer => players[declarerId!];

  Player? get friend => friendId != null ? players[friendId!] : null;

  bool get isFriendRevealed => friendRevealed || friendId != null && friendId == declarerId;

  int get tricksPlayed => tricks.length;

  int get currentTrickNumber => tricksPlayed + 1;

  // 모두 패스했는지 확인
  bool get allPassed => passedPlayers.every((p) => p);

  // 공개된 점수 카드 목록 (완료된 트릭 + 현재 트릭)
  List<PlayingCard> get playedPointCards {
    List<PlayingCard> pointCards = [];

    // 완료된 트릭에서 점수 카드 수집
    for (final trick in tricks) {
      for (final card in trick.cards) {
        if (card.isPointCard || card.isJoker) {
          pointCards.add(card);
        }
      }
    }

    // 현재 트릭에서 점수 카드 수집
    if (currentTrick != null) {
      for (final card in currentTrick!.cards) {
        if (card.isPointCard || card.isJoker) {
          pointCards.add(card);
        }
      }
    }

    return pointCards;
  }

  // 무늬별 공개된 점수 카드
  Map<Suit, List<PlayingCard>> get playedPointCardsBySuit {
    Map<Suit, List<PlayingCard>> result = {
      Suit.spade: [],
      Suit.diamond: [],
      Suit.heart: [],
      Suit.club: [],
    };

    for (final card in playedPointCards) {
      if (!card.isJoker && card.suit != null) {
        result[card.suit]!.add(card);
      }
    }

    // 각 무늬 내에서 랭크 순으로 정렬 (높은 것부터)
    for (final suit in Suit.values) {
      result[suit]!.sort((a, b) => b.rankValue.compareTo(a.rankValue));
    }

    return result;
  }

  // 조커가 공개되었는지
  bool get isJokerPlayed => playedPointCards.any((c) => c.isJoker);

  // 마이티가 공개되었는지
  bool get isMightyPlayed => playedPointCards.any((c) => c == mighty);

  // 공격팀(주공+프렌드)이 획득한 점수 카드
  List<PlayingCard> get declarerTeamPointCards {
    List<PlayingCard> cards = [];
    for (final player in players) {
      if (player.isDeclarer || player.isFriend) {
        cards.addAll(player.wonCards.where((c) => c.isPointCard || c.isJoker));
      }
    }
    // 랭크 순 정렬
    cards.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });
    return cards;
  }

  // 방어팀이 획득한 점수 카드
  List<PlayingCard> get defenderTeamPointCards {
    List<PlayingCard> cards = [];
    for (final player in players) {
      if (!player.isDeclarer && !player.isFriend) {
        cards.addAll(player.wonCards.where((c) => c.isPointCard || c.isJoker));
      }
    }
    // 랭크 순 정렬
    cards.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });
    return cards;
  }

  bool get isNoGiruda => giruda == null;

  PlayingCard get mighty {
    if (giruda == Suit.spade) {
      return const PlayingCard(suit: Suit.diamond, rank: Rank.ace);
    }
    return const PlayingCard(suit: Suit.spade, rank: Rank.ace);
  }

  PlayingCard get jokerCall {
    if (giruda == Suit.club) {
      return const PlayingCard(suit: Suit.spade, rank: Rank.three);
    }
    return const PlayingCard(suit: Suit.club, rank: Rank.three);
  }

  void reset() {
    phase = GamePhase.waiting;
    kitty.clear();
    currentBid = null;
    currentBidder = 0;
    passedPlayers = List.filled(5, false);
    declarerId = null;
    friendId = null;
    giruda = null;
    friendDeclaration = null;
    friendRevealed = false;
    tricks.clear();
    currentTrick = null;
    currentPlayer = 0;
    startingPlayer = 0;
    mightyJokerUsed = false;
    declarerTeamPoints = 0;
    defenderTeamPoints = 0;

    for (final player in players) {
      player.reset();
    }
  }

  void startNewGame() {
    reset();
    dealCards();
    // 비딩 시작 플레이어를 랜덤하게 지정
    currentBidder = Random().nextInt(5);
    phase = GamePhase.bidding;
  }

  void dealCards() {
    phase = GamePhase.dealing;
    final hands = deck.deal(players: 5, cardsPerPlayer: 10);

    for (int i = 0; i < 5; i++) {
      players[i].addCards(hands[i]);
      players[i].sortHand();
    }

    kitty = deck.getKitty(50);
    phase = GamePhase.bidding;
  }

  void placeBid(Bid bid) {
    if (bid.passed) {
      passedPlayers[currentBidder] = true;
    } else {
      currentBid = bid;
    }

    int passCount = passedPlayers.where((p) => p).length;

    if (passCount == 4 && currentBid != null) {
      declarerId = currentBid!.playerId;
      giruda = currentBid!.suit;
      players[declarerId!].isDeclarer = true;
      players[declarerId!].team = Team.declarer;
      phase = GamePhase.selectingKitty;
      return;
    }

    if (passCount == 5) {
      // 모두 패스 - 컨트롤러에서 처리하도록 phase만 변경
      phase = GamePhase.waiting;
      return;
    }

    do {
      currentBidder = (currentBidder + 1) % 5;
    } while (passedPlayers[currentBidder]);
  }

  // 딜 미스 선언 - 선언한 플레이어가 딜러가 되어 다시 시작
  void declareDealMiss(int playerId) {
    // 모든 플레이어 초기화
    for (final player in players) {
      player.reset();
    }

    // 상태 초기화
    reset();

    // 카드 다시 분배
    dealCards();

    // 딜 미스 선언자가 첫 비딩
    currentBidder = playerId;
    phase = GamePhase.bidding;
  }

  void selectKitty(List<PlayingCard> discardCards, Suit? newGiruda) {
    final declarer = players[declarerId!];
    declarer.addCards(kitty);

    for (final card in discardCards) {
      declarer.removeCard(card);
    }

    kitty = discardCards;

    // 기루다가 변경되면 목표 +2 증가
    if (newGiruda != giruda && currentBid != null) {
      currentBid = Bid(
        playerId: currentBid!.playerId,
        suit: newGiruda,
        tricks: currentBid!.tricks + 2,
      );
    }

    giruda = newGiruda;
    declarer.sortHand();
    phase = GamePhase.declaringFriend;
  }

  void declareFriend(FriendDeclaration declaration) {
    friendDeclaration = declaration;

    if (declaration.isNoFriend) {
      friendId = declarerId;
      friendRevealed = true;
    }

    phase = GamePhase.playing;
    startingPlayer = declarerId!;
    currentPlayer = declarerId!;
    startNewTrick();
  }

  void startNewTrick() {
    currentTrick = Trick(
      trickNumber: currentTrickNumber,
      leadPlayerId: currentPlayer,
    );
  }

  bool canPlayCard(PlayingCard card, Player player) {
    if (currentTrick == null || currentTrick!.cards.isEmpty) {
      // 초구(첫 트릭) 주공 선공 시 기루다 제한 (초간 방지)
      // 주공이 첫 트릭 선공일 때 기루다를 낼 수 없음
      if (currentTrickNumber == 1 && player.isDeclarer && giruda != null) {
        if (!card.isJoker && !card.isMighty && card.suit == giruda) {
          // 기루다가 아닌 다른 카드가 있는지 확인
          final nonGirudaCards = player.hand
              .where((c) => !c.isJoker && !c.isMighty && c.suit != giruda)
              .toList();
          if (nonGirudaCards.isNotEmpty) {
            return false;
          }
        }
      }

      // 첫 트릭 선공에서 조커/마이티 제한
      if (currentTrickNumber == 1 && !mightyJokerUsed) {
        if (card.isJoker || card.isMighty) {
          if (player.hand.length > 1) {
            final otherCards = player.hand
                .where((c) => !c.isJoker && !c.isMighty)
                .toList();
            if (otherCards.isNotEmpty) {
              return false;
            }
          }
        }
      }

      // 마지막 트릭(10번째)에서 조커 제한 - 다른 카드가 있으면 조커 사용 불가
      if (currentTrickNumber == 10 && card.isJoker) {
        final otherCards = player.hand.where((c) => !c.isJoker).toList();
        if (otherCards.isNotEmpty) {
          return false;
        }
      }

      return true;
    }

    final leadSuit = currentTrick!.leadSuit;

    // 조커 콜이 선언된 경우
    if (currentTrick!.jokerCall == JokerCallType.jokerCall) {
      final callSuit = currentTrick!.jokerCallSuit ?? leadSuit;

      // 조커를 가지고 있고, 조커 콜 무늬를 가지고 있으면 조커를 내야 함
      bool hasJoker = player.hand.any((c) => c.isJoker);
      bool hasCallSuit = player.hand.any((c) => !c.isJoker && c.suit == callSuit);

      if (hasJoker && hasCallSuit) {
        // 조커만 낼 수 있음
        return card.isJoker;
      }
    }

    if (leadSuit == null) {
      return true;
    }

    // 마지막 트릭(10번째)에서 조커 제한 - 다른 낼 수 있는 카드가 있으면 조커 사용 불가
    if (currentTrickNumber == 10 && card.isJoker) {
      // 리드 무늬가 있는지 확인
      bool hasLeadSuit = player.hand.any((c) => !c.isJoker && c.suit == leadSuit);
      if (hasLeadSuit) {
        return false;
      }
      // 리드 무늬가 없으면 다른 카드가 있는지 확인
      final otherCards = player.hand.where((c) => !c.isJoker).toList();
      if (otherCards.isNotEmpty) {
        return false;
      }
    }

    if (card.isJoker || card.isMighty) {
      return true;
    }

    if (card.suit == leadSuit) {
      return true;
    }

    if (!player.hasSuit(leadSuit)) {
      return true;
    }

    return false;
  }

  // 조커 콜 선언 (선공 시에만 가능)
  void declareJokerCall(Suit suit) {
    if (currentTrick != null && currentTrick!.cards.isEmpty) {
      currentTrick!.jokerCall = JokerCallType.jokerCall;
      currentTrick!.jokerCallSuit = suit;
    }
  }

  void playCard(PlayingCard card, int playerId, {Suit? jokerLeadSuit}) {
    final player = players[playerId];
    player.removeCard(card);
    currentTrick!.addCard(card, playerId, jokerSuit: jokerLeadSuit);

    if (!friendRevealed && friendDeclaration != null) {
      if (friendDeclaration!.card != null && card == friendDeclaration!.card) {
        // 주공이 프렌드 카드를 내면 프렌드로 설정하지 않음 (주공은 프렌드가 될 수 없음)
        if (playerId != declarerId) {
          friendId = playerId;
          friendRevealed = true;
          players[playerId].isFriend = true;
          players[playerId].team = Team.declarer;
        }
      }
    }

    if (currentTrick!.isComplete) {
      resolveTrick();
    } else {
      currentPlayer = (currentPlayer + 1) % 5;
    }
  }

  void resolveTrick() {
    final winnerId = determineTrickWinner();
    currentTrick!.winnerId = winnerId;
    final winner = players[winnerId];
    winner.wonCards.addAll(currentTrick!.cards);

    if (!friendRevealed && friendDeclaration != null) {
      if (friendDeclaration!.isFirstTrickWinner && tricksPlayed == 0) {
        friendId = winnerId;
        friendRevealed = true;
        players[winnerId].isFriend = true;
        players[winnerId].team = Team.declarer;
      } else if (friendDeclaration!.trickNumber != null &&
          currentTrickNumber == friendDeclaration!.trickNumber) {
        friendId = winnerId;
        friendRevealed = true;
        players[winnerId].isFriend = true;
        players[winnerId].team = Team.declarer;
      }
    }

    tricks.add(currentTrick!);

    if (tricks.length == 10) {
      endGame();
    } else {
      currentPlayer = winnerId;
      startingPlayer = winnerId;
      startNewTrick();
    }
  }

  int determineTrickWinner() {
    int winnerIndex = 0;
    PlayingCard winningCard = currentTrick!.cards[0];
    final leadSuit = currentTrick!.leadSuit;
    bool jokerWasCalled = currentTrick!.jokerCall == JokerCallType.jokerCall;

    for (int i = 1; i < currentTrick!.cards.length; i++) {
      final card = currentTrick!.cards[i];

      if (isCardStronger(card, winningCard, leadSuit, jokerWasCalled)) {
        winnerIndex = i;
        winningCard = card;
      }
    }

    return currentTrick!.playerOrder[winnerIndex];
  }

  bool isCardStronger(
      PlayingCard card, PlayingCard other, Suit? leadSuit, bool jokerCalled) {
    if (card == mighty) return true;
    if (other == mighty) return false;

    if (card.isJoker) {
      if (jokerCalled) return false;
      if (currentTrickNumber == 1) return false;
      return true;
    }
    if (other.isJoker) {
      if (jokerCalled) return true;
      if (currentTrickNumber == 1) return true;
      return false;
    }

    if (giruda != null) {
      if (card.suit == giruda && other.suit != giruda) return true;
      if (card.suit != giruda && other.suit == giruda) return false;
    }

    if (card.suit == leadSuit && other.suit != leadSuit) return true;
    if (card.suit != leadSuit && other.suit == leadSuit) return false;

    if (card.suit == other.suit) {
      return card.rankValue > other.rankValue;
    }

    return false;
  }

  void endGame() {
    phase = GamePhase.gameEnd;
    // 프렌드가 밝혀지지 않은 경우 프렌드 카드를 가진 플레이어 찾기
    _revealFriendIfNeeded();
    calculateScores();
  }

  void _revealFriendIfNeeded() {
    if (friendRevealed) return;
    if (friendDeclaration == null) return;
    if (friendDeclaration!.isNoFriend) return;

    // 카드로 지정된 프렌드 찾기
    if (friendDeclaration!.card != null) {
      final friendCard = friendDeclaration!.card!;
      for (int i = 0; i < players.length; i++) {
        if (i == declarerId) continue;
        // 손에 남아있거나 이미 냈던 카드 확인
        bool hasFriendCard = players[i].hand.any((c) =>
            c.suit == friendCard.suit && c.rank == friendCard.rank);
        bool playedFriendCard = players[i].wonCards.any((c) =>
            c.suit == friendCard.suit && c.rank == friendCard.rank);
        // 트릭에서 낸 카드도 확인
        bool inTricks = false;
        for (final trick in tricks) {
          final cardIndex = trick.cards.indexWhere((c) =>
              c.suit == friendCard.suit && c.rank == friendCard.rank);
          if (cardIndex >= 0 && cardIndex < trick.playerOrder.length) {
            // 이 트릭에서 누가 냈는지 확인
            final friendPlayerId = trick.playerOrder[cardIndex];
            if (friendPlayerId == i) {
              inTricks = true;
              break;
            }
          }
        }
        if (hasFriendCard || playedFriendCard || inTricks) {
          players[i].isFriend = true;
          friendRevealed = true;
          return;
        }
      }
    }
  }

  void calculateScores() {
    int declarerPoints = 0;
    int defenderPoints = 0;

    for (final player in players) {
      final points = player.pointsWon;
      if (player.isDeclarer || player.isFriend) {
        declarerPoints += points;
      } else {
        defenderPoints += points;
      }
    }

    for (final card in kitty) {
      if (card.isPointCard) {
        declarerPoints++;
      }
    }

    declarerTeamPoints = declarerPoints;
    defenderTeamPoints = defenderPoints;
  }

  bool get declarerWon {
    if (currentBid == null) return false;
    return declarerTeamPoints >= currentBid!.tricks;
  }

  int getPlayerScore(int playerId) {
    final player = players[playerId];
    final targetTricks = currentBid?.tricks ?? 13;
    const int minContract = 13;  // 최소 공약
    final isNoFriend = friendDeclaration?.isNoFriend ?? false;

    int baseScore;
    int specialMultiplier = 1;

    if (declarerWon) {
      // === 주공 승리 시 (하이리스크 하이리턴 방식) ===
      // (득점 - 공약) + (득점 - 최소공약) × 2
      baseScore = (declarerTeamPoints - targetTricks) +
                  (declarerTeamPoints - minContract) * 2;

      // 런 (주공팀이 20점 전부 획득): x2
      if (declarerTeamPoints >= 20) {
        specialMultiplier *= 2;
      }

      // 노기루다: x2
      if (isNoGiruda) {
        specialMultiplier *= 2;
      }

      // 노프렌드: x2
      if (isNoFriend) {
        specialMultiplier *= 2;
      }
    } else {
      // === 주공 패배 시 ===
      // (공약 - 득점) 만 적용, 노기루다/노프렌드 제외
      baseScore = -(targetTricks - declarerTeamPoints);

      // 백런 (수비팀이 11점 이상 획득): x2
      if (defenderTeamPoints >= 11) {
        specialMultiplier *= 2;
      }
    }

    baseScore *= specialMultiplier;

    // 역할별 배수 적용
    // 야당과 프렌드는 baseScore, 주공은 2배
    int roleMultiplier;
    if (player.isDeclarer) {
      roleMultiplier = 2;  // 주공: x2
    } else if (player.isFriend) {
      roleMultiplier = 1;  // 프렌드: x1
    } else {
      roleMultiplier = -1;  // 야당(수비): x(-1)
    }

    return baseScore * roleMultiplier;
  }
}
