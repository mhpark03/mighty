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
  late String _recommendationReason;

  @override
  void initState() {
    super.initState();
    _calculateRecommendation();
  }

  void _calculateRecommendation() {
    // 임시 Player 객체 생성
    final tempPlayer = Player(id: 0, name: 'temp', type: PlayerType.human);
    tempPlayer.hand.clear();
    tempPlayer.hand.addAll(widget.hand);

    _recommendedDeclaration = _aiPlayer.declareFriend(tempPlayer, widget.gameState);
    _recommendationReason = _getRecommendationReason();
  }

  String _getRecommendationReason() {
    final hand = widget.hand;
    final hasMighty = hand.any((c) => c.isMighty);
    final hasJoker = hand.any((c) => c.isJoker);

    if (_recommendedDeclaration.isNoFriend) {
      return 'reasonStrongHand';
    }

    if (_recommendedDeclaration.card != null) {
      final card = _recommendedDeclaration.card!;
      if (card.isMighty) {
        return 'reasonNeedMighty';
      }
      if (card.isJoker) {
        return 'reasonNeedJoker';
      }
      if (card.suit == widget.gameState.giruda && card.rank == Rank.ace) {
        return 'reasonNeedGirudaAce';
      }
      if (card.suit == widget.gameState.giruda && card.rank == Rank.king) {
        return 'reasonNeedGirudaKing';
      }
    }

    if (hasMighty) return 'reasonHasMighty';
    if (hasJoker) return 'reasonHasJoker';
    return 'reasonNeedMighty';
  }

  void _applyRecommendation() {
    setState(() {
      if (_recommendedDeclaration.isNoFriend) {
        _selectedType = 'none';
      } else if (_recommendedDeclaration.card != null) {
        final card = _recommendedDeclaration.card!;
        if (card.isJoker) {
          _selectedType = 'joker';
        } else {
          _selectedType = 'card';
          _selectedSuit = card.suit!;
          _selectedRank = card.rank!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.declareFriend),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 추천 영역
            _buildRecommendationSection(),
            const SizedBox(height: 16),
            Text(l10n.friendDeclarationType, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildRadioOption('card', l10n.byCard, null),
            _buildRadioOption('joker', l10n.joker, null),
            _buildRadioOption('none', l10n.noFriend, l10n.noFriendDesc),
            const SizedBox(height: 16),
            if (_selectedType == 'card') _buildCardSelector(),
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
          child: Text(l10n.declare),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    final l10n = AppLocalizations.of(context)!;

    String recommendedText;
    if (_recommendedDeclaration.isNoFriend) {
      recommendedText = l10n.noFriend;
    } else if (_recommendedDeclaration.card != null) {
      final card = _recommendedDeclaration.card!;
      if (card.isJoker) {
        recommendedText = l10n.joker;
      } else {
        recommendedText = '${_getSuitSymbol(card.suit!)}${_rankToString(card.rank!)}';
      }
    } else {
      recommendedText = l10n.noFriend;
    }

    String reasonText;
    switch (_recommendationReason) {
      case 'reasonStrongHand':
        reasonText = l10n.reasonStrongHand;
        break;
      case 'reasonHasMighty':
        reasonText = l10n.reasonHasMighty;
        break;
      case 'reasonHasJoker':
        reasonText = l10n.reasonHasJoker;
        break;
      case 'reasonNeedMighty':
        reasonText = l10n.reasonNeedMighty;
        break;
      case 'reasonNeedJoker':
        reasonText = l10n.reasonNeedJoker;
        break;
      case 'reasonNeedGirudaAce':
        reasonText = l10n.reasonNeedGirudaAce;
        break;
      case 'reasonNeedGirudaKing':
        reasonText = l10n.reasonNeedGirudaKing;
        break;
      default:
        reasonText = '';
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
              Text(
                l10n.aiRecommendation,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 추천 프렌드
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.recommendedFriend, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _recommendedDeclaration.isNoFriend
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Colors.amber.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _recommendedDeclaration.isNoFriend ? Colors.grey : Colors.amber,
                  ),
                ),
                child: Text(
                  recommendedText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _recommendedDeclaration.isNoFriend ? Colors.grey[700] : Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
          if (reasonText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '($reasonText)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // 추천 적용 버튼
          ElevatedButton.icon(
            onPressed: _applyRecommendation,
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: Text(l10n.applyRecommendation),
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
