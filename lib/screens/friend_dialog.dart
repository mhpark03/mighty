import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class FriendDialog extends StatefulWidget {
  final PlayingCard mighty;
  final Function(FriendDeclaration) onDeclare;

  const FriendDialog({
    super.key,
    required this.mighty,
    required this.onDeclare,
  });

  @override
  State<FriendDialog> createState() => _FriendDialogState();
}

class _FriendDialogState extends State<FriendDialog> {
  String _selectedType = 'card';
  Suit _selectedSuit = Suit.spade;
  Rank _selectedRank = Rank.ace;
  int _selectedTrick = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('프렌드 선언'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('프렌드 선언 방식:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('카드로 지정'),
              value: 'card',
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            RadioListTile<String>(
              title: const Text('초구 프렌드'),
              subtitle: const Text('첫 트릭을 따는 사람'),
              value: 'first',
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            RadioListTile<String>(
              title: const Text('N번째 트릭 프렌드'),
              value: 'trick',
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            RadioListTile<String>(
              title: const Text('노프렌드'),
              subtitle: const Text('혼자 플레이'),
              value: 'none',
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            if (_selectedType == 'card') _buildCardSelector(),
            if (_selectedType == 'trick') _buildTrickSelector(),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            FriendDeclaration declaration;
            switch (_selectedType) {
              case 'card':
                declaration = FriendDeclaration.byCard(
                  PlayingCard(suit: _selectedSuit, rank: _selectedRank),
                );
                break;
              case 'first':
                declaration = FriendDeclaration.firstTrickWinner();
                break;
              case 'trick':
                declaration = FriendDeclaration.byTrick(_selectedTrick);
                break;
              case 'none':
              default:
                declaration = FriendDeclaration.noFriend();
                break;
            }
            widget.onDeclare(declaration);
          },
          child: const Text('선언'),
        ),
      ],
    );
  }

  Widget _buildCardSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('무늬:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('♠'),
              selected: _selectedSuit == Suit.spade,
              onSelected: (_) => setState(() => _selectedSuit = Suit.spade),
            ),
            ChoiceChip(
              label: const Text('♦', style: TextStyle(color: Colors.red)),
              selected: _selectedSuit == Suit.diamond,
              onSelected: (_) => setState(() => _selectedSuit = Suit.diamond),
            ),
            ChoiceChip(
              label: const Text('♥', style: TextStyle(color: Colors.red)),
              selected: _selectedSuit == Suit.heart,
              onSelected: (_) => setState(() => _selectedSuit = Suit.heart),
            ),
            ChoiceChip(
              label: const Text('♣'),
              selected: _selectedSuit == Suit.club,
              onSelected: (_) => setState(() => _selectedSuit = Suit.club),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('숫자:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final rank in Rank.values.reversed)
              ChoiceChip(
                label: Text(_rankToString(rank)),
                selected: _selectedRank == rank,
                onSelected: (_) => setState(() => _selectedRank = rank),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '선택한 카드: ${_getSuitSymbol(_selectedSuit)}${_rankToString(_selectedRank)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrickSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('트릭 번호:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 1; i <= 10; i++)
              ChoiceChip(
                label: Text('$i'),
                selected: _selectedTrick == i,
                onSelected: (_) => setState(() => _selectedTrick = i),
              ),
          ],
        ),
      ],
    );
  }

  String _rankToString(Rank rank) {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.king:
        return 'K';
      case Rank.queen:
        return 'Q';
      case Rank.jack:
        return 'J';
      case Rank.ten:
        return '10';
      case Rank.nine:
        return '9';
      case Rank.eight:
        return '8';
      case Rank.seven:
        return '7';
      case Rank.six:
        return '6';
      case Rank.five:
        return '5';
      case Rank.four:
        return '4';
      case Rank.three:
        return '3';
      case Rank.two:
        return '2';
    }
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
}
