import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/ai_player.dart';
import '../widgets/card_widget.dart';

class FriendSelectionScreen extends StatefulWidget {
  final PlayingCard mighty;
  final List<PlayingCard> hand;
  final GameState gameState;
  final Function(FriendDeclaration) onDeclare;

  const FriendSelectionScreen({
    super.key,
    required this.mighty,
    required this.hand,
    required this.gameState,
    required this.onDeclare,
  });

  @override
  State<FriendSelectionScreen> createState() => _FriendSelectionScreenState();
}

class _FriendSelectionScreenState extends State<FriendSelectionScreen> {
  String _selectedType = 'card';
  PlayingCard? _selectedCard;

  // AI 추천
  final AIPlayer _aiPlayer = AIPlayer();
  late FriendDeclaration _recommendedDeclaration;

  // 선택 가능한 모든 카드 목록 (53장 - 내 손패 10장 = 43장)
  late List<PlayingCard> _allSelectableCards;

  @override
  void initState() {
    super.initState();
    _initSelectableCards();
    _calculateRecommendation();
    _applyRecommendation();
  }

  void _initSelectableCards() {
    _allSelectableCards = [];

    // 모든 카드 생성 (조커 포함)
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        _allSelectableCards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    _allSelectableCards.add(PlayingCard.joker());

    // 무늬 순서로 정렬 (스페이드, 다이아, 하트, 클럽, 조커)
    _allSelectableCards.sort((a, b) {
      if (a.isJoker) return 1;
      if (b.isJoker) return -1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });
  }

  void _calculateRecommendation() {
    final tempPlayer = Player(id: 0, name: 'temp', type: PlayerType.human);
    tempPlayer.hand.clear();
    tempPlayer.hand.addAll(widget.hand);

    _recommendedDeclaration = _aiPlayer.declareFriend(tempPlayer, widget.gameState);
  }

  void _applyRecommendation() {
    if (_recommendedDeclaration.isNoFriend) {
      _selectedType = 'none';
      _selectedCard = null;
    } else if (_recommendedDeclaration.isFirstTrickWinner) {
      _selectedType = 'firstTrick';
      _selectedCard = null;
    } else if (_recommendedDeclaration.card != null) {
      final card = _recommendedDeclaration.card!;
      if (card.isJoker) {
        _selectedType = 'joker';
        _selectedCard = card;
      } else if (card.isMighty) {
        _selectedType = 'mighty';
        _selectedCard = card;
      } else {
        _selectedType = 'card';
        _selectedCard = card;
      }
    }
  }

  bool _isCardInHand(PlayingCard card) {
    return widget.hand.any((c) => c == card);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // 카드 크기 계산 (한 줄에 7장)
    final cardWidth = (screenWidth - 48) / 7;
    final cardHeight = cardWidth * 1.4;

    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text(l10n.declareFriend),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 내 카드 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.black26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      l10n.myCards,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildMyHandCards(cardWidth * 0.85, cardHeight * 0.85),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 빠른 선택 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.friendDeclarationType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickButton(
                          'mighty',
                          '${l10n.mighty}\n${_getMightySymbol()}',
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickButton(
                          'joker',
                          '${l10n.joker}\n🃏',
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickButton(
                          'firstTrick',
                          '${l10n.firstTrickFriend}\n🏆',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickButton(
                          'none',
                          '${l10n.noFriend}\n🚫',
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 선택 가능한 카드 목록
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        l10n.byCard,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildSelectableCards(cardWidth * 0.9, cardHeight * 0.9),
                    ),
                  ],
                ),
              ),
            ),

            // 현재 선택 표시 및 확인 버튼
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // 현재 선택 표시
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _getSelectionDescription(l10n),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canConfirm() ? _onConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.declare,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyHandCards(double cardWidth, double cardHeight) {
    // 손패를 정렬
    final sortedHand = List<PlayingCard>.from(widget.hand);
    sortedHand.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sortedHand.map((card) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CardWidget(
              card: card,
              width: cardWidth,
              height: cardHeight,
              isPlayable: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickButton(String type, String label, Color color) {
    final isSelected = _selectedType == type;
    final isDisabled = _isQuickButtonDisabled(type);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedType = type;
                if (type == 'mighty') {
                  _selectedCard = widget.mighty;
                } else if (type == 'joker') {
                  _selectedCard = PlayingCard.joker();
                } else {
                  _selectedCard = null;
                }
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[700]
              : (isSelected ? color : color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDisabled ? Colors.grey[500] : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.3,
              ),
            ),
            if (isDisabled)
              const Text(
                '(보유중)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isQuickButtonDisabled(String type) {
    if (type == 'mighty') {
      return _isCardInHand(widget.mighty);
    } else if (type == 'joker') {
      return _isCardInHand(PlayingCard.joker());
    }
    return false;
  }

  Widget _buildSelectableCards(double cardWidth, double cardHeight) {
    // 무늬별로 그룹화
    final spades = _allSelectableCards.where((c) => c.suit == Suit.spade).toList();
    final diamonds = _allSelectableCards.where((c) => c.suit == Suit.diamond).toList();
    final hearts = _allSelectableCards.where((c) => c.suit == Suit.heart).toList();
    final clubs = _allSelectableCards.where((c) => c.suit == Suit.club).toList();
    final joker = _allSelectableCards.where((c) => c.isJoker).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCardRow(spades, cardWidth, cardHeight, '♠'),
          const SizedBox(height: 4),
          _buildCardRow(diamonds, cardWidth, cardHeight, '♦'),
          const SizedBox(height: 4),
          _buildCardRow(hearts, cardWidth, cardHeight, '♥'),
          const SizedBox(height: 4),
          _buildCardRow(clubs, cardWidth, cardHeight, '♣'),
          const SizedBox(height: 4),
          _buildCardRow(joker, cardWidth, cardHeight, '🃏'),
        ],
      ),
    );
  }

  Widget _buildCardRow(List<PlayingCard> cards, double cardWidth, double cardHeight, String label) {
    return Row(
      children: [
        // 무늬 라벨
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: label == '♦' || label == '♥' ? Colors.red[300] : Colors.white70,
            ),
          ),
        ),
        // 카드들
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cards.map((card) {
                final isInHand = _isCardInHand(card);
                final isSelected = _selectedType == 'card' && _selectedCard == card;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: GestureDetector(
                    onTap: isInHand
                        ? null
                        : () {
                            setState(() {
                              _selectedType = 'card';
                              _selectedCard = card;
                            });
                          },
                    child: Opacity(
                      opacity: isInHand ? 0.3 : 1.0,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: card.isJoker ? Colors.purple : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? Colors.amber : (isInHand ? Colors.grey : Colors.grey[400]!),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 8)]
                              : null,
                        ),
                        child: _buildMiniCard(card),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(PlayingCard card) {
    if (card.isJoker) {
      return const Center(
        child: Text('🃏', style: TextStyle(fontSize: 16)),
      );
    }

    final color = card.isRed ? Colors.red : Colors.black;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.suitSymbol,
            style: TextStyle(fontSize: 10, color: color),
          ),
          Text(
            card.rankSymbol,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getMightySymbol() {
    final mighty = widget.mighty;
    if (mighty.isJoker) return '🃏';
    return '${mighty.suitSymbol}${mighty.rankSymbol}';
  }

  String _getSelectionDescription(AppLocalizations l10n) {
    switch (_selectedType) {
      case 'mighty':
        return '${l10n.mighty} (${_getMightySymbol()})';
      case 'joker':
        return l10n.joker;
      case 'firstTrick':
        return l10n.firstTrickFriend;
      case 'none':
        return l10n.noFriend;
      case 'card':
        if (_selectedCard != null) {
          if (_selectedCard!.isJoker) {
            return l10n.joker;
          }
          return '${_selectedCard!.suitSymbol}${_selectedCard!.rankSymbol}';
        }
        return l10n.byCard;
      default:
        return '';
    }
  }

  bool _canConfirm() {
    if (_selectedType == 'card') {
      return _selectedCard != null;
    }
    return true;
  }

  void _onConfirm() {
    FriendDeclaration declaration;
    switch (_selectedType) {
      case 'mighty':
        declaration = FriendDeclaration.byCard(widget.mighty);
        break;
      case 'joker':
        declaration = FriendDeclaration.byCard(PlayingCard.joker());
        break;
      case 'firstTrick':
        declaration = FriendDeclaration.firstTrickWinner();
        break;
      case 'none':
        declaration = FriendDeclaration.noFriend();
        break;
      case 'card':
      default:
        declaration = FriendDeclaration.byCard(_selectedCard!);
        break;
    }
    widget.onDeclare(declaration);
  }
}
