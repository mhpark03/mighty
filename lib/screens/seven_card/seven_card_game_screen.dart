import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/card.dart';
import '../../models/seven_card/seven_card_state.dart';
import '../../services/seven_card/seven_card_controller.dart';
import '../../widgets/banner_ad_widget.dart';

class SevenCardGameScreen extends StatefulWidget {
  const SevenCardGameScreen({super.key});

  @override
  State<SevenCardGameScreen> createState() => _SevenCardGameScreenState();
}

class _SevenCardGameScreenState extends State<SevenCardGameScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SevenCardController>(
      builder: (context, controller, child) {
        final state = controller.state;

        return Scaffold(
          backgroundColor: Colors.blue[900],
          appBar: AppBar(
            backgroundColor: Colors.blue[800],
            title: Text(l10n.sevenCardTitle),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildGameArea(controller, state, l10n),
                ),
                const BannerAdWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    if (state.phase == SevenCardPhase.waiting) {
      return _buildWaitingScreen(controller, l10n);
    } else if (state.phase == SevenCardPhase.selectOpen) {
      return _buildSelectOpenScreen(controller, state, l10n);
    } else if (state.phase == SevenCardPhase.gameEnd) {
      return _buildGameEndScreen(controller, state, l10n);
    } else {
      return _buildPlayingScreen(controller, state, l10n);
    }
  }

  Widget _buildSelectOpenScreen(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final player = state.humanPlayer;
    final isMyTurn = state.currentPlayerIndex == 0;

    return Column(
      children: [
        // 상단 안내
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black26,
          child: Column(
            children: [
              const Icon(Icons.visibility, color: Colors.amber, size: 40),
              const SizedBox(height: 8),
              Text(
                '공개할 카드를 선택하세요',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '선택한 카드가 상대에게 공개됩니다',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const Spacer(),
        // 카드 선택 영역
        if (isMyTurn)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: player.hand.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                return _buildSelectableCard(card, index, controller);
              }).toList(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircularProgressIndicator(color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'AI가 카드를 선택하고 있습니다...',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSelectableCard(PlayingCard card, int index, SevenCardController controller) {
    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return GestureDetector(
      onTap: () => controller.humanSelectOpenCard(index),
      child: Container(
        width: 80,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rankStr,
              style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              suitSymbol,
              style: TextStyle(color: color, fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen(SevenCardController controller, AppLocalizations l10n) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => controller.startNewGame(),
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.startGame),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPlayingScreen(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final opponents = state.players.where((p) => p.id != 0).toList();
    final leftOpponents = opponents.length >= 2 ? opponents.sublist(0, 2) : opponents;
    final rightOpponents = opponents.length > 2 ? opponents.sublist(2) : <SevenCardPlayer>[];

    return Stack(
      children: [
        Column(
          children: [
            // 베팅 단계 표시
            _buildPotInfo(state, l10n),
            // AI 플레이어들 + 중앙 팟 영역
            Expanded(
              child: Row(
                children: [
                  // 왼쪽 AI 2명
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: leftOpponents.map((opponent) =>
                        _buildOpponentArea(opponent, state, l10n, controller)
                      ).toList(),
                    ),
                  ),
                  // 중앙 팟 영역
                  _buildCenterPotArea(state, l10n),
                  // 오른쪽 AI 2명
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: rightOpponents.map((opponent) =>
                        _buildOpponentArea(opponent, state, l10n, controller)
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // 플레이어 영역
            _buildPlayerArea(controller, state, l10n),
            // 액션 버튼 (항상 표시)
            _buildActionButtons(controller, state, l10n),
          ],
        ),
        // 라운드 전환 오버레이
        if (controller.isRoundTransitioning)
          _buildRoundTransitionOverlay(controller),
      ],
    );
  }

  Widget _buildRoundTransitionOverlay(SevenCardController controller) {
    return GestureDetector(
      onTap: () => controller.skipTransition(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                Text(
                  controller.roundTransitionMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.transitionCountdown}초 후 진행',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '(화면을 터치하면 바로 진행)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPotInfo(SevenCardState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPhaseIndicator(state, l10n),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(SevenCardState state, AppLocalizations l10n) {
    String phaseName;
    switch (state.phase) {
      case SevenCardPhase.betting1:
        phaseName = '${l10n.betting} 1';
        break;
      case SevenCardPhase.betting2:
        phaseName = '${l10n.betting} 2';
        break;
      case SevenCardPhase.betting3:
        phaseName = '${l10n.betting} 3';
        break;
      case SevenCardPhase.betting4:
        phaseName = '${l10n.betting} 4';
        break;
      default:
        phaseName = '';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        phaseName,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCenterPotArea(SevenCardState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 팟 (칩 모양)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[700]!, Colors.amber[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 칩 아이콘
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red[400]!, Colors.red[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 팟 금액
                Text(
                  '${state.pot}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 현재 베팅 금액
          if (state.currentBetAmount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.currentBet}: ${state.currentBetAmount}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpponentArea(SevenCardPlayer opponent, SevenCardState state, AppLocalizations l10n, SevenCardController controller) {
    final isCurrentPlayer = state.currentPlayerIndex == opponent.id;
    final isFolded = opponent.isFolded;
    final isBoss = state.bettingRoundStarterIndex == opponent.id && !isFolded;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.amber.withValues(alpha: 0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentPlayer ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 보스 표시
          if (isBoss)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.black, size: 10),
                  SizedBox(width: 2),
                  Text(
                    'BOSS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // 이름과 총 베팅액
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opponent.name,
                style: TextStyle(
                  color: isFolded ? Colors.grey : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (!isFolded) ...[
                const SizedBox(width: 4),
                Text(
                  '(${SevenCardPlayer.maxBettingActions - opponent.bettingActionsInRound})',
                  style: TextStyle(
                    color: opponent.canBet ? Colors.lightGreenAccent : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
          Text(
            '총: ${opponent.totalBetInGame}',
            style: TextStyle(
              color: isFolded ? Colors.grey : Colors.amber,
              fontSize: 11,
            ),
          ),
          // 베팅 정보 (액션 + 금액)
          if (opponent.lastAction != BettingAction.none)
            Text(
              _getBettingActionText(opponent.lastAction, opponent.currentBet),
              style: TextStyle(
                color: _getBettingActionColor(opponent.lastAction),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (opponent.currentBet > 0)
            Text(
              '${l10n.bet}: ${opponent.currentBet}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 10,
              ),
            ),
          if (isFolded)
            Text(
              l10n.folded,
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
          const SizedBox(height: 4),
          // 다이한 플레이어는 모든 카드를 뒷면으로 표시
          if (isFolded) ...[
            if (opponent.hand.isNotEmpty)
              Wrap(
                spacing: 2,
                children: opponent.hand.map((_) => _buildCardBack()).toList(),
              ),
          ] else ...[
            // 히든 카드 (테스트용: 실제 카드 표시)
            if (opponent.hiddenCards.isNotEmpty)
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: opponent.hiddenCards.map((card) => _buildSmallCard(card)).toList(),
              ),
            // 오픈 카드 + 족보 표시
            if (opponent.openCards.isNotEmpty)
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: [
                  ...opponent.openCards.map((card) => _buildSmallCard(card)),
                  // 족보 표시 (오픈 카드 기준)
                  if (opponent.openPokerHand != null)
                    Container(
                      margin: const EdgeInsets.only(left: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        controller.getHandRankDisplayName(opponent.openPokerHand),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallCard(PlayingCard card) {
    // 조커 처리
    if (card.isJoker) {
      return Container(
        width: 28,
        height: 38,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.purple),
        ),
        child: const Center(
          child: Text(
            'JK',
            style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: 28,
      height: 38,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankStr,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            suitSymbol,
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack({bool small = true}) {
    return Container(
      width: small ? 24 : 40,
      height: small ? 32 : 56,
      margin: EdgeInsets.all(small ? 1 : 2),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(small ? 3 : 5),
        border: Border.all(color: Colors.blue[900]!, width: small ? 1 : 2),
        boxShadow: small ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: small ? null : Center(
        child: Icon(Icons.style, color: Colors.blue[300], size: 20),
      ),
    );
  }

  Widget _buildPlayerArea(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final player = state.humanPlayer;
    final isCurrentPlayer = state.currentPlayerIndex == 0;
    final isBoss = state.bettingRoundStarterIndex == 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.amber.withValues(alpha: 0.2) : Colors.black26,
        border: isCurrentPlayer ? const Border(top: BorderSide(color: Colors.amber, width: 2)) : null,
      ),
      child: Column(
        children: [
          // 플레이어 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    l10n.player,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${SevenCardPlayer.maxBettingActions - player.bettingActionsInRound})',
                    style: TextStyle(
                      color: player.canBet ? Colors.lightGreenAccent : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  // 보스 표시
                  if (isBoss) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.black, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'BOSS',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '총: ${player.totalBetInGame}',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 플레이어 카드 (공개 카드 위, 히든 카드+족보 아래)
          Column(
            children: [
              // 공개 카드 (위)
              if (player.openCards.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: player.openCards.map((card) => _buildPlayerOpenCard(card)).toList(),
                  ),
                ),
              const SizedBox(height: 4),
              // 히든 카드 + 족보 (아래)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 히든 카드 (실제 카드 표시 - 플레이어 본인 카드)
                  if (player.hiddenCards.isNotEmpty)
                    ...player.hiddenCards.map((card) => _buildPlayerHiddenCard(card)),
                  // 족보 표시 (베팅4에서는 전체 7장 기준, 그 외에는 오픈 카드 기준)
                  if (state.phase == SevenCardPhase.betting4 && player.pokerHand != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[700]!, Colors.purple[500]!],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '최고 족보',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            controller.getHandRankDisplayName(player.pokerHand),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (player.openPokerHand != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.getHandRankDisplayName(player.openPokerHand),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerOpenCard(PlayingCard card) {
    // 조커 처리
    if (card.isJoker) {
      return Container(
        width: 50,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.purple, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'JOKER',
            style: TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: 50,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankStr,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            suitSymbol,
            style: TextStyle(color: color, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHiddenCard(PlayingCard card) {
    // 조커 처리
    if (card.isJoker) {
      return Container(
        width: 40,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.purple, width: 1),
        ),
        child: const Center(
          child: Text(
            'JK',
            style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: 40,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankStr,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            suitSymbol,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final isMyTurn = controller.isHumanTurn;
    final availableActions = isMyTurn ? state.getAvailableActions() : <String>[];

    // 버튼 활성화 여부 확인 헬퍼
    VoidCallback? getAction(String actionName, VoidCallback action) {
      return isMyTurn && availableActions.contains(actionName) ? action : null;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black38,
      child: Column(
        children: [
          // 상단 행: 삥, 콜, 따당, 다이
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 삥 (기본 판돈 - 보스만)
              _buildBetButton(
                label: '삥',
                amount: state.getBingAmount(),
                color: Colors.green,
                onPressed: getAction('bing', () => controller.humanBing()),
              ),
              // 콜
              _buildBetButton(
                label: '콜',
                amount: state.getCallAmount(),
                color: Colors.cyan,
                onPressed: getAction('call', () => controller.humanCall()),
              ),
              // 따당 (2배)
              _buildBetButton(
                label: '따당',
                amount: state.getDdadangAmount(),
                color: Colors.orange,
                onPressed: getAction('ddadang', () => controller.humanDdadang()),
              ),
              // 다이 (폴드)
              _buildBetButton(
                label: '다이',
                amount: null,
                color: Colors.red,
                onPressed: getAction('die', () => controller.humanDie()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 하단 행: 체크, 쿼터, 하프, 풀
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 체크 (보스만)
              _buildBetButton(
                label: '체크',
                amount: null,
                color: Colors.blue,
                onPressed: getAction('check', () => controller.humanCheck()),
              ),
              // 쿼터 (25%)
              _buildBetButton(
                label: '쿼터',
                amount: state.getQuarterAmount(),
                color: Colors.teal,
                onPressed: getAction('quarter', () => controller.humanQuarter()),
              ),
              // 하프 (50%)
              _buildBetButton(
                label: '하프',
                amount: state.getHalfAmount(),
                color: Colors.indigo,
                onPressed: getAction('half', () => controller.humanHalf()),
              ),
              // 풀 (100%)
              _buildBetButton(
                label: '풀',
                amount: state.getFullAmount(),
                color: Colors.purple,
                onPressed: getAction('full', () => controller.humanFull()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBetButton({
    required String label,
    required int? amount,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? color : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              if (amount != null)
                Text(
                  '$amount',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameEndScreen(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final winner = state.winnerId != null ? state.players[state.winnerId!] : null;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              winner != null ? '${winner.name} ${l10n.wins}!' : l10n.gameEnd,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (winner?.pokerHand != null) ...[
              const SizedBox(height: 8),
              Text(
                controller.getHandRankName(winner!.pokerHand!.rank),
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '${l10n.pot}: ${state.pot}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            // 모든 플레이어의 최종 카드와 칩
            ...state.players.map((player) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: player.id == winner?.id ? FontWeight.bold : FontWeight.normal,
                      color: player.isFolded ? Colors.grey : Colors.black,
                    ),
                  ),
                  Text(
                    player.isFolded ? l10n.folded : (player.pokerHand != null ? controller.getHandRankName(player.pokerHand!.rank) : '-'),
                    style: TextStyle(color: player.isFolded ? Colors.grey : Colors.green),
                  ),
                  Text(
                    '${player.chips}',
                    style: TextStyle(
                      color: player.id == winner?.id ? Colors.green : Colors.black,
                      fontWeight: player.id == winner?.id ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 결과 확인 버튼
                ElevatedButton.icon(
                  onPressed: () => _showDetailedResults(context, controller, state),
                  icon: const Icon(Icons.visibility),
                  label: const Text('결과 확인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                // 새 게임 버튼
                ElevatedButton.icon(
                  onPressed: () => controller.startNewGame(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.newGame),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedResults(BuildContext context, SevenCardController controller, SevenCardState state) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '최종 결과',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // 플레이어 카드 목록
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: state.players.map((player) =>
                      _buildPlayerResultCard(player, controller, state)
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerResultCard(SevenCardPlayer player, SevenCardController controller, SevenCardState state) {
    final isWinner = player.id == state.winnerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner ? Colors.amber.withValues(alpha: 0.2) : Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: isWinner ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 플레이어 이름과 상태
          Row(
            children: [
              if (isWinner)
                const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              if (isWinner)
                const SizedBox(width: 4),
              Text(
                player.name,
                style: TextStyle(
                  color: player.isFolded ? Colors.grey : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (player.isFolded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '다이',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else if (player.pokerHand != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.getHandRankDisplayName(player.pokerHand),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 전체 카드 표시
          if (player.hand.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: player.hand.map((card) {
                // 최고 5장 조합에 포함된 카드인지 확인
                final isInBestFive = player.pokerHand?.bestFive.any(
                  (c) => c.suit == card.suit && c.rank == card.rank
                ) ?? false;
                return _buildResultCard(card, isInBestFive && !player.isFolded);
              }).toList(),
            ),
          // 총 베팅액
          const SizedBox(height: 8),
          Text(
            '총 베팅: ${player.totalBetInGame}',
            style: const TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(PlayingCard card, bool isHighlighted) {
    if (card.isJoker) {
      return Container(
        width: 36,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isHighlighted ? Colors.amber : Colors.purple,
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: const Center(
          child: Text(
            'JK',
            style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: 36,
      height: 50,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.amber[50] : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isHighlighted ? Colors.amber : Colors.grey,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankStr,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            suitSymbol,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getSuitSymbol(Suit? suit) {
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.heart:
        return '♥';
      case Suit.diamond:
        return '♦';
      case Suit.club:
        return '♣';
      default:
        return '';
    }
  }

  String _getRankString(Rank? rank) {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      default:
        return '';
    }
  }

  /// 베팅 액션을 한글 텍스트로 변환
  String _getBettingActionText(BettingAction action, int amount) {
    switch (action) {
      case BettingAction.bing:
        return '삥 ($amount)';
      case BettingAction.check:
        return '체크';
      case BettingAction.call:
        return '콜 ($amount)';
      case BettingAction.ddadang:
        return '따당 ($amount)';
      case BettingAction.quarter:
        return '쿼터 ($amount)';
      case BettingAction.half:
        return '하프 ($amount)';
      case BettingAction.full:
        return '풀 ($amount)';
      case BettingAction.die:
        return '다이';
      case BettingAction.none:
        return '';
    }
  }

  /// 베팅 액션별 색상
  Color _getBettingActionColor(BettingAction action) {
    switch (action) {
      case BettingAction.bing:
        return Colors.green;
      case BettingAction.check:
        return Colors.blue;
      case BettingAction.call:
        return Colors.cyan;
      case BettingAction.ddadang:
        return Colors.orange;
      case BettingAction.quarter:
        return Colors.teal;
      case BettingAction.half:
        return Colors.indigo;
      case BettingAction.full:
        return Colors.purple;
      case BettingAction.die:
        return Colors.red;
      case BettingAction.none:
        return Colors.grey;
    }
  }
}
