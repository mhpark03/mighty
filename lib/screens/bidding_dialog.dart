import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class BiddingDialog extends StatefulWidget {
  final Bid? currentBid;
  final Function(Bid) onBid;
  final VoidCallback onPass;

  const BiddingDialog({
    super.key,
    this.currentBid,
    required this.onBid,
    required this.onPass,
  });

  @override
  State<BiddingDialog> createState() => _BiddingDialogState();
}

class _BiddingDialogState extends State<BiddingDialog> {
  int _selectedTricks = 13;
  Suit? _selectedSuit;
  bool _noGiruda = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentBid != null && !widget.currentBid!.passed) {
      _selectedTricks = widget.currentBid!.tricks + 1;
    }
  }

  bool get _isValidBid {
    if (widget.currentBid == null || widget.currentBid!.passed) {
      return _selectedTricks >= 13;
    }

    if (_selectedTricks > widget.currentBid!.tricks) {
      return true;
    }

    if (_selectedTricks == widget.currentBid!.tricks) {
      if (_noGiruda && widget.currentBid!.suit != null) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('비딩'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.currentBid != null && !widget.currentBid!.passed)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '현재 최고 비딩: ${widget.currentBid}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            const Text('트릭 수', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 13; i <= 20; i++)
                  ChoiceChip(
                    label: Text('$i'),
                    selected: _selectedTricks == i,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTricks = i;
                        });
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('기루다', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('♠ 스페이드'),
                  selected: _selectedSuit == Suit.spade && !_noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = Suit.spade;
                      _noGiruda = false;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text(
                    '♦ 다이아',
                    style: TextStyle(color: Colors.red),
                  ),
                  selected: _selectedSuit == Suit.diamond && !_noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = Suit.diamond;
                      _noGiruda = false;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text(
                    '♥ 하트',
                    style: TextStyle(color: Colors.red),
                  ),
                  selected: _selectedSuit == Suit.heart && !_noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = Suit.heart;
                      _noGiruda = false;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('♣ 클럽'),
                  selected: _selectedSuit == Suit.club && !_noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = Suit.club;
                      _noGiruda = false;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('노기루다'),
                  selected: _noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _noGiruda = selected;
                      _selectedSuit = null;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onPass,
          child: const Text('패스'),
        ),
        ElevatedButton(
          onPressed: _isValidBid
              ? () {
                  widget.onBid(Bid(
                    playerId: 0,
                    suit: _noGiruda ? null : _selectedSuit,
                    tricks: _selectedTricks,
                  ));
                }
              : null,
          child: const Text('비딩'),
        ),
      ],
    );
  }
}
