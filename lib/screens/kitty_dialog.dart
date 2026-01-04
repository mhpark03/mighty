import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../widgets/card_widget.dart';

class KittyDialog extends StatefulWidget {
  final List<PlayingCard> hand;
  final List<PlayingCard> kitty;
  final Suit? currentGiruda;
  final Function(List<PlayingCard>, Suit?) onConfirm;

  const KittyDialog({
    super.key,
    required this.hand,
    required this.kitty,
    required this.currentGiruda,
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
            const SizedBox(height: 16),
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
