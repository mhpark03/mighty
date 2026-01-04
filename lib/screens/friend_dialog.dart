import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/ai_player.dart';

class FriendDialog extends StatefulWidget {
  final PlayingCard mighty;
  final List<PlayingCard> hand;
  final GameState gameState;
  final Function(FriendDeclaration) onDeclare;

  const FriendDialog({
    super.key,
    required this.mighty,
    required this.hand,
    required this.gameState,
    required this.onDeclare,
  });

  @override
  State<FriendDialog> createState() => _FriendDialogState();
}

class _FriendDialogState extends State<FriendDialog> {
  String _selectedType = 'card';
  Suit _selectedSuit = Suit.spade;
  Rank _selectedRank = Rank.ace;

  // AI 추천
  final AIPlayer _aiPlayer = AIPlayer();
  late FriendDeclaration _recommendedDeclaration;

  @override
  void initState() {
    super.initState();
    _calculateRecommendation();
    _applyRecommendation(); // 초기 선택으로 자동 적용
  }

  void _calculateRecommendation() {
    // 임시 Player 객체 생성
    final tempPlayer = Player(id: 0, name: 'temp', type: PlayerType.human);
    tempPlayer.hand.clear();
    tempPlayer.hand.addAll(widget.hand);

    _recommendedDeclaration = _aiPlayer.declareFriend(tempPlayer, widget.gameState);
  }

  void _applyRecommendation() {
    if (_recommendedDeclaration.isNoFriend) {
      _selectedType = 'none';
    } else if (_recommendedDeclaration.card != null) {
      final card = _recommendedDeclaration.card!;
      if (card.isJoker) {
        _selectedType = 'joker';
      } else if (card.isMighty) {
        _selectedType = 'mighty';
      } else {
        _selectedType = 'card';
        _selectedSuit = card.suit!;
        _selectedRank = card.rank!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: screenWidth * 0.95,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            Center(
              child: Text(
                l10n.declareFriend,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // 프렌드 선언 방식
            Text(l10n.friendDeclarationType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildRadioOption('card', l10n.byCard, null),
            _buildRadioOption('mighty', l10n.mighty, null),
            _buildRadioOption('joker', l10n.joker, null),
            _buildRadioOption('none', l10n.noFriend, l10n.noFriendDesc),
            const SizedBox(height: 12),
            // 카드 선택기 (카드로 지정 선택 시)
            if (_selectedType == 'card') _buildCardSelector(),
            const SizedBox(height: 16),
            // 선언 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  FriendDeclaration declaration;
                  switch (_selectedType) {
                    case 'card':
                      declaration = FriendDeclaration.byCard(
                        PlayingCard(suit: _selectedSuit, rank: _selectedRank),
                      );
                      break;
                    case 'mighty':
                      declaration = FriendDeclaration.byCard(widget.mighty);
                      break;
                    case 'joker':
                      declaration = FriendDeclaration.byCard(PlayingCard.joker());
                      break;
                    case 'none':
                    default:
                      declaration = FriendDeclaration.noFriend();
                      break;
                  }
                  widget.onDeclare(declaration);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  l10n.declare,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value, String title, String? subtitle) {
    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedType,
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelector() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.suit, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        Text(l10n.rank, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.selectedCard('${_getSuitSymbol(_selectedSuit)}${_rankToString(_selectedRank)}'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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
