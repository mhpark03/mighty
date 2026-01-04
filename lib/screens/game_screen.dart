import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/game_controller.dart';
import '../services/ai_player.dart';
import '../widgets/card_widget.dart';
import 'bidding_dialog.dart';
import 'kitty_dialog.dart';
import 'friend_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PlayingCard? selectedCard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.green[800],
          appBar: AppBar(
            title: Text(l10n.appTitle),
            backgroundColor: Colors.green[900],
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.reset();
                  controller.startNewGame();
                },
              ),
            ],
          ),
          body: _buildGameBody(controller),
        );
      },
    );
  }

  Widget _buildGameBody(GameController controller) {
    final state = controller.state;

    switch (state.phase) {
      case GamePhase.waiting:
        return _buildWaitingScreen(controller);
      case GamePhase.dealing:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case GamePhase.bidding:
        return _buildBiddingScreen(controller);
      case GamePhase.selectingKitty:
        return _buildKittyScreen(controller);
      case GamePhase.declaringFriend:
        return _buildFriendScreen(controller);
      case GamePhase.playing:
      case GamePhase.roundEnd:
        return _buildPlayingScreen(controller);
      case GamePhase.gameEnd:
        return _buildGameEndScreen(controller);
    }
  }

  Widget _buildWaitingScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.appTitle,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.gameSubtitle,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => controller.startNewGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: Text(
              l10n.startGame,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    return Column(
      children: [
        // 비딩 정보 헤더
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black38,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.biddingPhase,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.reset();
                      controller.startNewGame();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.newGame),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildBiddingInfo(state),
              if (state.currentBidder == 0 && !controller.isProcessing)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildBiddingControls(controller),
                ),
            ],
          ),
        ),
        // DEBUG: 모든 플레이어 카드 및 계산 결과
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 플레이어 (나)
                _buildPlayerDebugInfo(state.players[0], true),
                const SizedBox(height: 8),
                // AI 1~4를 2x2 그리드로 표시
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPlayerDebugInfo(state.players[1], false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPlayerDebugInfo(state.players[2], false)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPlayerDebugInfo(state.players[3], false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPlayerDebugInfo(state.players[4], false)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerDebugInfo(Player player, bool isHuman) {
    final aiPlayer = AIPlayer();
    final bestSuit = aiPlayer.findBestSuit(player.hand);
    final strength = aiPlayer.evaluateHandStrength(player.hand, bestSuit);

    // 카드를 무늬별로 정렬
    final sortedHand = List<PlayingCard>.from(player.hand);
    sortedHand.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHuman ? Colors.blue.withValues(alpha: 0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHuman ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                player.name,
                style: TextStyle(
                  color: isHuman ? Colors.lightBlueAccent : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '기루다: ${bestSuit != null ? _getSuitSymbol(bestSuit) : "없음"}',
                  style: const TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: strength >= 13
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '강도: $strength ${strength >= 13 ? "(비딩가능)" : "(패스)"}',
                  style: TextStyle(
                    color: strength >= 13 ? Colors.lightGreen : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final card in sortedHand)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (bestSuit != null && card.suit == bestSuit)
                          ? Colors.amber
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CardWidget(
                    card: card,
                    width: 36,
                    height: 54,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingInfo(GameState state) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            l10n.currentBidder(state.players[state.currentBidder].name),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (state.currentBid != null)
            Text(
              l10n.highestBid(state.currentBid.toString()),
              style: const TextStyle(color: Colors.amber, fontSize: 16),
            )
          else
            Text(
              l10n.noBidYet,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildBiddingControls(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: () => _showBiddingDialog(controller),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(
        l10n.bidButton,
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  void _showBiddingDialog(GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BiddingDialog(
        currentBid: controller.state.currentBid,
        onBid: (bid) {
          Navigator.pop(context);
          controller.humanBid(bid);
        },
        onPass: () {
          Navigator.pop(context);
          controller.humanPass();
        },
      ),
    );
  }

  Widget _buildKittyScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.state.declarerId != 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.aiSelectingKitty,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.white),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ElevatedButton(
              onPressed: () => _showKittyDialog(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                l10n.selectKitty,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
        ),
        _buildPlayerHand(controller),
      ],
    );
  }

  void _showKittyDialog(GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KittyDialog(
        hand: controller.humanPlayer.hand,
        kitty: controller.state.kitty,
        currentGiruda: controller.state.giruda,
        onConfirm: (discards, newGiruda) {
          Navigator.pop(context);
          controller.humanSelectKitty(discards, newGiruda);
        },
      ),
    );
  }

  Widget _buildFriendScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.state.declarerId != 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.aiDeclaringFriend,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.white),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ElevatedButton(
              onPressed: () => _showFriendDialog(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                l10n.declareFriend,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
        ),
        _buildPlayerHand(controller),
      ],
    );
  }

  void _showFriendDialog(GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FriendDialog(
        mighty: controller.state.mighty,
        onDeclare: (declaration) {
          Navigator.pop(context);
          controller.humanDeclareFriend(declaration);
        },
      ),
    );
  }

  Widget _buildPlayingScreen(GameController controller) {
    final state = controller.state;

    return Column(
      children: [
        _buildGameInfo(state),
        const SizedBox(height: 8),
        Expanded(
          child: _buildPlayArea(controller),
        ),
        _buildPlayerHand(controller),
      ],
    );
  }

  Widget _buildGameInfo(GameState state) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(l10n.giruda, state.giruda != null
              ? _getSuitSymbol(state.giruda!)
              : l10n.noGiruda),
          _buildInfoItem(l10n.contract, '${state.currentBid?.tricks ?? 0}'),
          _buildInfoItem(l10n.trick, '${state.tricksPlayed}/10'),
          // 프렌드 선언 정보 표시
          _buildFriendInfo(state, l10n),
        ],
      ),
    );
  }

  Widget _buildFriendInfo(GameState state, AppLocalizations l10n) {
    String friendLabel = l10n.friend;
    String friendValue;
    Color valueColor = Colors.white;

    if (state.friendRevealed && state.friend != null) {
      // 프렌드가 공개됨
      friendValue = state.friend!.name;
      valueColor = Colors.lightBlueAccent;
    } else if (state.friendDeclaration != null) {
      // 프렌드 선언 조건 표시
      final decl = state.friendDeclaration!;
      if (decl.isNoFriend) {
        friendValue = '없음';
        valueColor = Colors.grey;
      } else if (decl.isFirstTrickWinner) {
        friendValue = '첫트릭';
        valueColor = Colors.amber;
      } else if (decl.trickNumber != null) {
        friendValue = '${decl.trickNumber}트릭';
        valueColor = Colors.amber;
      } else if (decl.card != null) {
        friendValue = _getCardString(decl.card!);
        valueColor = Colors.amber;
      } else {
        friendValue = '?';
      }
    } else {
      friendValue = '?';
    }

    return Column(
      children: [
        Text(
          friendLabel,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          friendValue,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getCardString(PlayingCard card) {
    if (card.isJoker) return 'Joker';
    String suit = _getSuitSymbol(card.suit!);
    String rank;
    switch (card.rank) {
      case Rank.ace:
        rank = 'A';
        break;
      case Rank.king:
        rank = 'K';
        break;
      case Rank.queen:
        rank = 'Q';
        break;
      case Rank.jack:
        rank = 'J';
        break;
      case Rank.ten:
        rank = '10';
        break;
      default:
        rank = '${card.rankValue}';
    }
    return '$suit$rank';
  }

  String _getSuitSymbol(Suit suit) {
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.diamond:
        return '♦';
      case Suit.heart:
        return '♥';
      case Suit.club:
        return '♣';
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayArea(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final trick = state.currentTrick;

    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: _buildTopPlayers(state),
        ),
        Center(
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[600]!, width: 2),
            ),
            child: _buildTrickCards(trick, state),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: controller.isHumanTurn ? Colors.amber : Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.isHumanTurn
                    ? l10n.yourTurn
                    : l10n.playerTurn(state.players[state.currentPlayer].name),
                style: TextStyle(
                  color: controller.isHumanTurn ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlayers(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 1; i < 5; i++)
          _buildPlayerIndicator(state.players[i], state, i),
      ],
    );
  }

  Widget _buildPlayerIndicator(Player player, GameState state, int index) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrentPlayer = state.currentPlayer == index;
    final isDeclarer = player.isDeclarer;
    final isFriend = player.isFriend && state.friendRevealed;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.amber.withValues(alpha: 0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDeclarer
              ? Colors.red
              : (isFriend ? Colors.blue : Colors.transparent),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            player.name,
            style: TextStyle(
              color: isCurrentPlayer ? Colors.amber : Colors.white,
              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            l10n.cards(player.hand.length),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (isDeclarer)
            Text(
              l10n.declarer,
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
          if (isFriend)
            Text(
              l10n.friend,
              style: const TextStyle(color: Colors.blue, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildTrickCards(Trick? trick, GameState state) {
    final l10n = AppLocalizations.of(context)!;

    if (trick == null || trick.cards.isEmpty) {
      return Center(
        child: Text(
          l10n.playCard,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Center(
      child: Wrap(
        spacing: 8,
        children: [
          for (int i = 0; i < trick.cards.length; i++)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.players[trick.playerOrder[i]].name,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                CardWidget(
                  card: trick.cards[i],
                  width: 50,
                  height: 75,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerHand(GameController controller) {
    final hand = controller.humanPlayer.hand;
    final playableCards =
        controller.state.phase == GamePhase.playing ? controller.getPlayableCards() : hand;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.black26,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final card in hand)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CardWidget(
                    card: card,
                    width: 55,
                    height: 80,
                    isSelected: selectedCard == card,
                    isPlayable: playableCards.contains(card),
                    onTap: () => _onCardTap(card, controller),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap(PlayingCard card, GameController controller) {
    if (controller.state.phase != GamePhase.playing) return;
    if (!controller.isHumanTurn) return;
    if (!controller.canPlayCard(card)) return;

    if (selectedCard == card) {
      controller.humanPlayCard(card);
      setState(() {
        selectedCard = null;
      });
    } else {
      setState(() {
        selectedCard = card;
      });
    }
  }

  Widget _buildGameEndScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.declarerWon ? l10n.declarerTeamWins : l10n.defenderTeamWins,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: state.declarerWon ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.declarerTeamPoints(state.declarerTeamPoints),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              l10n.defenderTeamPoints(state.defenderTeamPoints),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              l10n.targetPoints(state.currentBid?.tricks ?? 0),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.score,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final player in state.players)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${player.name} ${player.isDeclarer ? "(${l10n.declarer})" : player.isFriend ? "(${l10n.friend})" : ""}',
                    ),
                    Text(
                      l10n.points(state.getPlayerScore(player.id)),
                      style: TextStyle(
                        color: state.getPlayerScore(player.id) >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.reset();
                controller.startNewGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                l10n.newGame,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
