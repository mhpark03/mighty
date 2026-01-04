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

    // AI 추천 계산 및 자동 적용
    _calculateRecommendation();
    _applyRecommendation();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.9 - 48) / 7; // 7장씩 한 줄에
    final cardHeight = cardWidth * 1.4;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: screenWidth * 0.95,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectKitty,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.selectKittyDesc(_selectedDiscards.length),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            // 받은 키티
            Text(l10n.receivedKitty, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.kitty
                  .map((card) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
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
            const SizedBox(height: 12),
            // 내 카드 (13장)
            Text(l10n.myCards, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            // 2줄로 표시 (7장 + 6장)
            _buildCardRows(cardWidth, cardHeight),
            const SizedBox(height: 12),
            // 기루다 변경
            Text(l10n.changeGiruda,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
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
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      l10n.girudaChangeWarning,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
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
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text(
                l10n.confirm,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRows(double cardWidth, double cardHeight) {
    // 13장 카드를 2줄로 나누기 (7장 + 6장)
    final firstRow = _allCards.take(7).toList();
    final secondRow = _allCards.skip(7).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: firstRow
              .map((card) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: secondRow
              .map((card) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
