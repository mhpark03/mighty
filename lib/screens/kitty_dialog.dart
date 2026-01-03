import 'package:flutter/material.dart';
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
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '키티 선택',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '버릴 카드 3장을 선택하세요 (선택됨: ${_selectedDiscards.length}/3)',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('받은 키티:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text('내 카드:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text('기루다 변경 (선택사항):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('♠'),
                  selected: _selectedGiruda == Suit.spade && !_noGiruda,
                  onSelected: (_) => setState(() {
                    _selectedGiruda = Suit.spade;
                    _noGiruda = false;
                  }),
                ),
                ChoiceChip(
                  label: const Text('♦', style: TextStyle(color: Colors.red)),
                  selected: _selectedGiruda == Suit.diamond && !_noGiruda,
                  onSelected: (_) => setState(() {
                    _selectedGiruda = Suit.diamond;
                    _noGiruda = false;
                  }),
                ),
                ChoiceChip(
                  label: const Text('♥', style: TextStyle(color: Colors.red)),
                  selected: _selectedGiruda == Suit.heart && !_noGiruda,
                  onSelected: (_) => setState(() {
                    _selectedGiruda = Suit.heart;
                    _noGiruda = false;
                  }),
                ),
                ChoiceChip(
                  label: const Text('♣'),
                  selected: _selectedGiruda == Suit.club && !_noGiruda,
                  onSelected: (_) => setState(() {
                    _selectedGiruda = Suit.club;
                    _noGiruda = false;
                  }),
                ),
                ChoiceChip(
                  label: const Text('노기루다'),
                  selected: _noGiruda,
                  onSelected: (_) => setState(() {
                    _noGiruda = true;
                    _selectedGiruda = null;
                  }),
                ),
              ],
            ),
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
              child: const Text(
                '확인',
                style: TextStyle(fontSize: 18, color: Colors.black),
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
}
