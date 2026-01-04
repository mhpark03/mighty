import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/ai_player.dart';
import '../widgets/card_widget.dart';

class KittyDialog extends StatefulWidget {
  final List<PlayingCard> hand;
  final List<PlayingCard> kitty;
  final Suit? currentGiruda;
  final GameState gameState;
  final Function(List<PlayingCard>, Suit?) onConfirm;

  const KittyDialog({
    super.key,
    required this.hand,
    required this.kitty,
    required this.currentGiruda,
    required this.gameState,
    required this.onConfirm,
  });

  @override
  State<KittyDialog> createState() => _KittyDialogState();
}

class _KittyDialogState extends State<KittyDialog> {
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

    // AI 추천 계산
    _calculateRecommendation();
  }

  void _calculateRecommendation() {
    // 임시 Player 객체 생성 (AI 로직 사용을 위해)
    final tempPlayer = Player(id: 0, name: 'temp', type: PlayerType.human);
    tempPlayer.hand.clear();
    tempPlayer.hand.addAll(widget.hand);

    // 1. 13장으로 기루다 변경 여부 결정
    _recommendedGiruda = _aiPlayer.decideGirudaChange(
      tempPlayer,
      widget.gameState,
      widget.kitty,
    );

    _recommendedNoGiruda = _recommendedGiruda == null && widget.currentGiruda != null;

    // 2. 최종 기루다를 기준으로 버릴 카드 선택
    _recommendedDiscards = _aiPlayer.selectKittyCardsWithGiruda(
      tempPlayer,
      widget.gameState,
      widget.kitty,
      _recommendedGiruda,
    );
  }

  void _applyRecommendation() {
    setState(() {
      _selectedDiscards.clear();
      _selectedDiscards.addAll(_recommendedDiscards);
      _selectedGiruda = _recommendedGiruda;
      _noGiruda = _recommendedNoGiruda;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.selectKitty,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectKittyDesc(_selectedDiscards.length),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(l10n.receivedKitty, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.kitty
                  .map((card) => Padding(
                        padding: const EdgeInsets.all(4),
                        child: CardWidget(
                          card: card,
                          width: 50,
                          height: 75,
                          isSelected: _selectedDiscards.contains(card),
                          onTap: () => _toggleCard(card),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            // AI 추천 영역
            _buildRecommendationSection(),
            const SizedBox(height: 12),
            Text(l10n.myCards, style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _allCards
                      .map((card) => CardWidget(
                            card: card,
                            width: 50,
                            height: 75,
                            isSelected: _selectedDiscards.contains(card),
                            onTap: () => _toggleCard(card),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.changeGiruda,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildGirudaChip(Suit.spade, '♠', false),
                _buildGirudaChip(Suit.diamond, '♦', true),
                _buildGirudaChip(Suit.heart, '♥', true),
                _buildGirudaChip(Suit.club, '♣', false),
                ChoiceChip(
                  label: Text(l10n.noGiruda),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '기루다 변경 시 목표 +2 증가',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                l10n.confirm,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection() {
    final isGirudaChangeRecommended = _recommendedGiruda != widget.currentGiruda;
    String girudaText;
    if (_recommendedNoGiruda) {
      girudaText = '노기루다';
    } else if (_recommendedGiruda != null) {
      girudaText = _getSuitSymbol(_recommendedGiruda!);
    } else {
      girudaText = '유지';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI 추천',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 추천 버릴 카드
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('버릴 카드: ', style: TextStyle(fontSize: 12)),
              ..._recommendedDiscards.map((card) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildMiniCard(card),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          // 추천 기루다
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('기루다: ', style: TextStyle(fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isGirudaChangeRecommended
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  girudaText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isGirudaChangeRecommended ? Colors.orange[800] : null,
                  ),
                ),
              ),
              if (isGirudaChangeRecommended) ...[
                const SizedBox(width: 4),
                Text(
                  '(목표 +2)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 추천 적용 버튼
          ElevatedButton.icon(
            onPressed: _applyRecommendation,
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text('추천 적용'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(PlayingCard card) {
    if (card.isJoker) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.purple),
        ),
        child: const Text('🃏', style: TextStyle(fontSize: 14)),
      );
    }

    final isRed = card.suit == Suit.diamond || card.suit == Suit.heart;
    final suitSymbol = _getSuitSymbol(card.suit!);
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        '$suitSymbol$rank',
        style: TextStyle(
          color: isRed ? Colors.red : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
