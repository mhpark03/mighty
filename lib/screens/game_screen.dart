import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/game_controller.dart';
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
    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.green[800],
          appBar: AppBar(
            title: const Text('마이티'),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '마이티',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '한국의 전통 트릭테이킹 카드 게임',
            style: TextStyle(
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
            child: const Text(
              '게임 시작',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingScreen(GameController controller) {
    final state = controller.state;

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '비딩 단계',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildBiddingInfo(state),
              const SizedBox(height: 20),
              if (state.currentBidder == 0 && !controller.isProcessing)
                _buildBiddingControls(controller),
            ],
          ),
        ),
        _buildPlayerHand(controller),
      ],
    );
  }

  Widget _buildBiddingInfo(GameState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '현재 비딩: ${state.players[state.currentBidder].name}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (state.currentBid != null)
            Text(
              '최고 비딩: ${state.currentBid}',
              style: const TextStyle(color: Colors.amber, fontSize: 16),
            )
          else
            const Text(
              '아직 비딩 없음',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildBiddingControls(GameController controller) {
    return ElevatedButton(
      onPressed: () => _showBiddingDialog(controller),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text(
        '비딩하기',
        style: TextStyle(fontSize: 18, color: Colors.black),
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
    if (controller.state.declarerId != 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'AI가 키티를 선택하고 있습니다...',
            style: TextStyle(color: Colors.white, fontSize: 20),
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
              child: const Text(
                '키티 선택하기',
                style: TextStyle(fontSize: 18, color: Colors.black),
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
    if (controller.state.declarerId != 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'AI가 프렌드를 선언하고 있습니다...',
            style: TextStyle(color: Colors.white, fontSize: 20),
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
              child: const Text(
                '프렌드 선언하기',
                style: TextStyle(fontSize: 18, color: Colors.black),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('기루다', state.giruda != null
              ? _getSuitSymbol(state.giruda!)
              : '노기루다'),
          _buildInfoItem('계약', '${state.currentBid?.tricks ?? 0}'),
          _buildInfoItem('트릭', '${state.tricksPlayed}/10'),
          if (state.friendRevealed && state.friend != null)
            _buildInfoItem('프렌드', state.friend!.name),
        ],
      ),
    );
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
    final state = controller.state;
    final trick = state.currentTrick;

    return Stack(
      children: [
        // AI 플레이어 위치 표시
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: _buildTopPlayers(state),
        ),
        // 가운데 플레이 영역
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
        // 현재 플레이어 표시
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
                controller.isHumanTurn ? '당신의 차례입니다' : '${state.players[state.currentPlayer].name}의 차례',
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
            '카드: ${player.hand.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (isDeclarer)
            const Text(
              '주공',
              style: TextStyle(color: Colors.red, fontSize: 10),
            ),
          if (isFriend)
            const Text(
              '프렌드',
              style: TextStyle(color: Colors.blue, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildTrickCards(Trick? trick, GameState state) {
    if (trick == null || trick.cards.isEmpty) {
      return const Center(
        child: Text(
          '카드를 내세요',
          style: TextStyle(color: Colors.white70, fontSize: 16),
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
              state.declarerWon ? '주공 팀 승리!' : '수비 팀 승리!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: state.declarerWon ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '주공 팀: ${state.declarerTeamPoints}점',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '수비 팀: ${state.defenderTeamPoints}점',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '목표: ${state.currentBid?.tricks ?? 0}점',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              '점수',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final player in state.players)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${player.name} ${player.isDeclarer ? "(주공)" : player.isFriend ? "(프렌드)" : ""}',
                    ),
                    Text(
                      '${state.getPlayerScore(player.id)}점',
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
              child: const Text(
                '새 게임',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
