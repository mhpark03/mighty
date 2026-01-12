import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/ai_player.dart';
import '../widgets/card_widget.dart';

class KittySelectionScreen extends StatefulWidget {
  final List<PlayingCard> hand;
  final List<PlayingCard> kitty;
  final Suit? currentGiruda;
  final GameState gameState;
  final Function(List<PlayingCard>, Suit?) onConfirm;

  const KittySelectionScreen({
    super.key,
    required this.hand,
    required this.kitty,
    required this.currentGiruda,
    required this.gameState,
    required this.onConfirm,
  });

  @override
  State<KittySelectionScreen> createState() => _KittySelectionScreenState();
}

class _KittySelectionScreenState extends State<KittySelectionScreen> {
  late List<PlayingCard> _allCards;
  final Set<PlayingCard> _selectedDiscards = {};
  Suit? _selectedGiruda;
  bool _noGiruda = false;

  // 추천 결과
  final AIPlayer _aiPlayer = AIPlayer();
  late List<PlayingCard> _recommendedDiscards;
  late Suit? _recommendedGiruda;
  late bool _recommendedNoGiruda;

  @override
  void initState() {
    super.initState();
    _allCards = [...widget.hand, ...widget.kitty];
    _allCards.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });

    _selectedGiruda = widget.currentGiruda;
    _noGiruda = widget.currentGiruda == null;

    // AI 추천 계산 및 자동 적용
    _calculateRecommendation();
    _applyRecommendation();
  }

  void _calculateRecommendation() {
    final tempPlayer = Player(id: 0, name: 'temp', type: PlayerType.human);
    tempPlayer.hand.clear();
    tempPlayer.hand.addAll(widget.hand);

    _recommendedGiruda = _aiPlayer.decideGirudaChange(
      tempPlayer,
      widget.gameState,
      widget.kitty,
    );

    _recommendedNoGiruda = _recommendedGiruda == null && widget.currentGiruda != null;

    _recommendedDiscards = _aiPlayer.selectKittyCardsWithGiruda(
      tempPlayer,
      widget.gameState,
      widget.kitty,
      _recommendedGiruda,
    );
  }

  void _applyRecommendation() {
    _selectedDiscards.clear();
    _selectedDiscards.addAll(_recommendedDiscards);
    _selectedGiruda = _recommendedGiruda;
    _noGiruda = _recommendedNoGiruda;
  }

  String _getKittyNotification() {
    return widget.kitty.map((card) {
      if (card.isJoker) return 'JK';
      final suit = _getSuitSymbol(card.suit!);
      final rank = _getRankSymbol(card.rank!);
      return '$suit$rank';
    }).join(' ');
  }

  String _getSuitSymbol(Suit suit) {
    switch (suit) {
      case Suit.spade: return '♠';
      case Suit.diamond: return '♦';
      case Suit.heart: return '♥';
      case Suit.club: return '♣';
    }
  }

  String _getRankSymbol(Rank rank) {
    switch (rank) {
      case Rank.ace: return 'A';
      case Rank.king: return 'K';
      case Rank.queen: return 'Q';
      case Rank.jack: return 'J';
      case Rank.ten: return '10';
      default: return '${rank.index + 2}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 5장씩 3줄 (5+5+3)
    // 화면 너비 기준 카드 크기
    final cardWidthByWidth = (screenWidth - 48) / 5;
    // 화면 높이 기준 카드 크기 (상단바, 하단 컨트롤 영역 제외)
    final availableHeight = screenHeight - 280; // 앱바, 안내문, 하단 버튼 영역 제외
    final cardHeightByHeight = (availableHeight - 24) / 3; // 3줄, 간격 제외
    final cardWidthByHeight = cardHeightByHeight / 1.4;

    // 더 작은 값 사용
    final cardWidth = cardWidthByWidth < cardWidthByHeight ? cardWidthByWidth : cardWidthByHeight;
    final cardHeight = cardWidth * 1.4;

    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text(l10n.selectKitty),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 받은 키티 노티 (작게 표시, 반응 없음)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.receivedKitty} ',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getKittyNotification(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 선택 안내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.selectKittyDesc(_selectedDiscards.length),
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),

            const SizedBox(height: 12),

            // 13장 카드 (3줄: 5+5+3)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildCardRows(cardWidth, cardHeight),
              ),
            ),

            // 하단 영역: 기루다 변경 + 확인 버튼
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 기루다 변경
                  Text(
                    l10n.changeGiruda,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildGirudaChip(Suit.spade, '♠', false),
                      _buildGirudaChip(Suit.diamond, '♦', true),
                      _buildGirudaChip(Suit.heart, '♥', true),
                      _buildGirudaChip(Suit.club, '♣', false),
                      ChoiceChip(
                        label: Text(l10n.noGiruda, style: const TextStyle(fontSize: 12)),
                        selected: _noGiruda,
                        onSelected: (_) => setState(() {
                          _noGiruda = true;
                          _selectedGiruda = null;
                        }),
                      ),
                    ],
                  ),
                  // 기루다 변경 경고
                  if (_isGirudaChanged) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            l10n.girudaChangeWarning,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDiscards.length == 3
                          ? () {
                              widget.onConfirm(
                                _selectedDiscards.toList(),
                                _noGiruda ? null : _selectedGiruda,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.confirm,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRows(double cardWidth, double cardHeight) {
    // 13장 카드를 3줄로 나누기 (5+5+3)
    final firstRow = _allCards.take(5).toList();
    final secondRow = _allCards.skip(5).take(5).toList();
    final thirdRow = _allCards.skip(10).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: firstRow
              .map((card) => Padding(
                    padding: const EdgeInsets.all(2),
                    child: CardWidget(
                      card: card,
                      width: cardWidth,
                      height: cardHeight,
                      isSelected: _selectedDiscards.contains(card),
                      onTap: () => _toggleCard(card),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: secondRow
              .map((card) => Padding(
                    padding: const EdgeInsets.all(2),
                    child: CardWidget(
                      card: card,
                      width: cardWidth,
                      height: cardHeight,
                      isSelected: _selectedDiscards.contains(card),
                      onTap: () => _toggleCard(card),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: thirdRow
              .map((card) => Padding(
                    padding: const EdgeInsets.all(2),
                    child: CardWidget(
                      card: card,
                      width: cardWidth,
                      height: cardHeight,
                      isSelected: _selectedDiscards.contains(card),
                      onTap: () => _toggleCard(card),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _toggleCard(PlayingCard card) {
    setState(() {
      if (_selectedDiscards.contains(card)) {
        _selectedDiscards.remove(card);
      } else if (_selectedDiscards.length < 3) {
        _selectedDiscards.add(card);
      }
    });
  }

  bool get _isGirudaChanged {
    final currentGiruda = _noGiruda ? null : _selectedGiruda;
    return currentGiruda != widget.currentGiruda;
  }

  Widget _buildGirudaChip(Suit suit, String symbol, bool isRed) {
    final isSelected = _selectedGiruda == suit && !_noGiruda;
    final isOriginal = widget.currentGiruda == suit;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: TextStyle(
              color: isRed ? Colors.red : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isOriginal) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_circle, size: 14, color: Colors.green),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() {
        _selectedGiruda = suit;
        _noGiruda = false;
      }),
    );
  }
}
