import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.bid),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.currentBid != null && !widget.currentBid!.passed)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.highestBid(widget.currentBid.toString()),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            Text(l10n.tricks, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Text(l10n.giruda, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text('♠ ${l10n.spade}', style: const TextStyle(fontFamily: 'Roboto')),
                  selected: _selectedSuit == Suit.spade && !_noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = Suit.spade;
                      _noGiruda = false;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(
                    '♦ ${l10n.diamond}',
                    style: const TextStyle(color: Colors.red, fontFamily: 'Roboto'),
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
                  label: Text(
                    '♥ ${l10n.heart}',
                    style: const TextStyle(color: Colors.red, fontFamily: 'Roboto'),
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
                  label: Text('♣ ${l10n.club}', style: const TextStyle(fontFamily: 'Roboto')),
                  selected: _selectedSuit == Suit.club && !_noGiruda,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSuit = Suit.club;
                      _noGiruda = false;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.noGiruda),
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
          child: Text(l10n.pass),
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
          child: Text(l10n.bid),
        ),
      ],
    );
  }
}
