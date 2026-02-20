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
  final Function(List<PlayingCard>, Suit?, bool isFull) onConfirm;

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
  bool _isFull = false;

  // 기루다 비교 (각 무늬별 적정 점수)
  final Map<Suit, (int, int, int)> _girudaComparison = {}; // suit -> (min, max, optimal)

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

    // 기루다 비교: 13장 기준 각 무늬별 점수
    final allCards = [...widget.hand, ...widget.kitty];
    _girudaComparison.clear();
    for (final suit in Suit.values) {
      final (min, max) = _aiPlayer.estimatePointRange(allCards, suit);
      final optimal = (min * 0.3 + max * 0.7 + 1).round();
      _girudaComparison[suit] = (min, max, optimal);
    }
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

  // 무늬별 색상이 적용된 키티 표시 위젯
  Widget _buildKittyNotificationWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.kitty.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;

        if (card.isJoker) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0) const SizedBox(width: 8),
              const Text('JK', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          );
        }

        final suit = card.suit!;
        final suitSymbol = _getSuitSymbol(suit);
        final rank = _getRankSymbol(card.rank!);
        final color = _getSuitColorForDisplay(suit);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index > 0) const SizedBox(width: 8),
            Text(suitSymbol, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Roboto')),
            Text(rank, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        );
      }).toList(),
    );
  }

  // 표시용 무늬 색상 (스페이드/클로버는 검정, 하트/다이아는 빨강)
  Color _getSuitColorForDisplay(Suit suit) {
    switch (suit) {
      case Suit.spade:
      case Suit.club:
        return Colors.black;
      case Suit.heart:
      case Suit.diamond:
        return Colors.red;
    }
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
    final compact = screenHeight < 700;

    // 5장씩 3줄 (5+5+3)
    // 화면 너비 기준 카드 크기
    final cardWidthByWidth = (screenWidth - 48) / 5;
    // 화면 높이 기준 카드 크기 (상단바, 하단 컨트롤 영역 제외)
    final bottomAreaHeight = compact ? 200 : 280;
    final availableHeight = screenHeight - bottomAreaHeight; // 앱바, 안내문, 하단 버튼 영역 제외
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 4 : 8),
              color: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.receivedKitty} ',
                    style: TextStyle(color: Colors.white70, fontSize: compact ? 12 : 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _buildKittyNotificationWidget(),
                  ),
                ],
              ),
            ),

            SizedBox(height: compact ? 4 : 8),

            // 선택 안내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.selectKittyDesc(_selectedDiscards.length),
                style: TextStyle(fontSize: compact ? 12 : 14, color: Colors.white70),
              ),
            ),

            SizedBox(height: compact ? 6 : 12),

            // 13장 카드 (3줄: 5+5+3)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildCardRows(cardWidth, cardHeight),
              ),
            ),

            // 하단 영역: 기루다 변경 + 확인 버튼 (스크롤 가능)
            Flexible(
              flex: 0,
              child: Container(
                constraints: BoxConstraints(maxHeight: compact ? screenHeight * 0.38 : screenHeight * 0.42),
                padding: EdgeInsets.all(compact ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 기루다 변경
                      Text(
                        l10n.changeGiruda,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 11 : 13,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 8),
                      Wrap(
                        spacing: compact ? 4 : 8,
                        runSpacing: compact ? 2 : 4,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildGirudaChip(Suit.spade, '♠', false),
                          _buildGirudaChip(Suit.diamond, '♦', true),
                          _buildGirudaChip(Suit.heart, '♥', true),
                          _buildGirudaChip(Suit.club, '♣', false),
                          ChoiceChip(
                            label: Text(l10n.noGiruda, style: TextStyle(fontSize: compact ? 11 : 12)),
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
                        SizedBox(height: compact ? 4 : 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 2 : 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange, size: compact ? 14 : 16),
                              SizedBox(width: compact ? 4 : 6),
                              Text(
                                l10n.girudaChangeWarning,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: compact ? 4 : 8),
                      // 풀 선언 체크박스
                      GestureDetector(
                        onTap: () => setState(() { _isFull = !_isFull; }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
                          decoration: BoxDecoration(
                            color: _isFull ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isFull ? Colors.red : Colors.white30,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isFull ? Icons.check_box : Icons.check_box_outline_blank,
                                color: _isFull ? Colors.red : Colors.white70,
                                size: compact ? 16 : 20,
                              ),
                              SizedBox(width: compact ? 6 : 8),
                              Text(
                                l10n.fullPoints,
                                style: TextStyle(
                                  color: _isFull ? Colors.red : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isFull) ...[
                        SizedBox(height: compact ? 4 : 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 2 : 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber, color: Colors.red, size: compact ? 14 : 16),
                              SizedBox(width: compact ? 4 : 6),
                              Text(
                                l10n.fullDeclarationWarning,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: compact ? 6 : 12),
                      // 확인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedDiscards.length == 3
                              ? () {
                                  widget.onConfirm(
                                    _selectedDiscards.toList(),
                                    _noGiruda ? null : _selectedGiruda,
                                    _isFull,
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(vertical: compact ? 8 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            l10n.confirm,
                            style: TextStyle(
                              fontSize: compact ? 15 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    final comp = _girudaComparison[suit];
    final optimal = comp != null ? comp.$3 : 0;

    // 최적 무늬 찾기
    int bestOptimal = 0;
    Suit? bestSuit;
    for (final entry in _girudaComparison.entries) {
      if (entry.value.$3 > bestOptimal) {
        bestOptimal = entry.value.$3;
        bestSuit = entry.key;
      }
    }
    final isBest = suit == bestSuit;

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
          if (comp != null) ...[
            const SizedBox(width: 3),
            Text(
              '$optimal',
              style: TextStyle(
                fontSize: 11,
                color: isBest ? Colors.amber[700] : Colors.grey[600],
                fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
          if (isBest && !isOriginal) ...[
            const SizedBox(width: 2),
            Icon(Icons.star, size: 12, color: Colors.amber[700]),
          ],
          if (isOriginal) ...[
            const SizedBox(width: 2),
            const Icon(Icons.check_circle, size: 12, color: Colors.green),
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
