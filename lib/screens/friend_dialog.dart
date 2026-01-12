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
  Suit _selectedSuit = Suit.spade;

  // AI 추천
  final AIPlayer _aiPlayer = AIPlayer();
  late FriendDeclaration _recommendedDeclaration;

  // 선택 가능한 모든 카드 목록
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

    // 모든 카드 생성 (조커 제외)
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        _allSelectableCards.add(PlayingCard(suit: suit, rank: rank));
      }
    }

    // 무늬 순서로 정렬 (스페이드, 다이아, 하트, 클럽)
    _allSelectableCards.sort((a, b) {
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
    } else if (_recommendedDeclaration.card != null) {
      final card = _recommendedDeclaration.card!;
      if (card.isJoker) {
        _selectedType = 'joker';
        _selectedCard = card;
      } else if (card.isMighty) {
        _selectedType = 'mighty';
        _selectedCard = card;
      } else if (card == _getJokerCallCard()) {
        _selectedType = 'jokerCall';
        _selectedCard = card;
      } else {
        _selectedType = 'card';
        _selectedCard = card;
        _selectedSuit = card.suit!;
      }
    }
  }

  // 조커콜 카드 가져오기 (기루다가 클럽이면 ♠3, 아니면 ♣3)
  PlayingCard _getJokerCallCard() {
    final giruda = widget.gameState.giruda;
    if (giruda == Suit.club) {
      return PlayingCard(suit: Suit.spade, rank: Rank.three);
    } else {
      return PlayingCard(suit: Suit.club, rank: Rank.three);
    }
  }

  String _getJokerCallSymbol() {
    final card = _getJokerCallCard();
    return '${card.suitSymbol}${card.rankSymbol}';
  }

  bool _isCardInHand(PlayingCard card) {
    return widget.hand.any((c) => c == card);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 반응형: 너비와 높이 모두 고려하여 카드 크기 계산
    final handCardWidthByWidth = (screenWidth - 32) / 6;
    final handCardWidthByHeight = (screenHeight - 400) / 8; // 높이 기준
    final handCardWidth = handCardWidthByWidth < handCardWidthByHeight
        ? handCardWidthByWidth
        : handCardWidthByHeight;
    final handCardHeight = handCardWidth * 1.3;

    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text(l10n.declareFriend),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
            // 내 카드 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  _buildMyHandCards(handCardWidth, handCardHeight),
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
                          'jokerCall',
                          '${l10n.jokerCallTitle}\n${_getJokerCallSymbol()}',
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

            const SizedBox(height: 8),

            // 카드로 지정 섹션
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
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text(
                        l10n.byCard,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 무늬 선택 버튼들
                    _buildSuitSelector(),
                    const SizedBox(height: 8),
                    // 선택된 무늬의 카드들 (3열)
                    Expanded(
                      child: _buildCardGrid(),
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
          ),
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

    // 2줄로 나누기 (5장씩)
    final firstRow = sortedHand.take(5).toList();
    final secondRow = sortedHand.skip(5).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: firstRow.map((card) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: CardWidget(
                card: card,
                width: cardWidth,
                height: cardHeight,
                isPlayable: false,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: secondRow.map((card) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: CardWidget(
                card: card,
                width: cardWidth,
                height: cardHeight,
                isPlayable: false,
              ),
            );
          }).toList(),
        ),
      ],
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
                } else if (type == 'jokerCall') {
                  _selectedCard = _getJokerCallCard();
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
    } else if (type == 'jokerCall') {
      return _isCardInHand(_getJokerCallCard());
    }
    return false;
  }

  Widget _buildSuitSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSuitButton(Suit.spade, '♠', false),
        _buildSuitButton(Suit.diamond, '♦', true),
        _buildSuitButton(Suit.heart, '♥', true),
        _buildSuitButton(Suit.club, '♣', false),
      ],
    );
  }

  Widget _buildSuitButton(Suit suit, String symbol, bool isRed) {
    final isSelected = _selectedSuit == suit;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSuit = suit;
        });
      },
      child: Container(
        width: 55,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 20,
              color: isSelected
                  ? (isRed ? Colors.red : Colors.black)
                  : (isRed ? Colors.red[300] : Colors.white70),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardGrid() {
    // 선택된 무늬의 카드들만 필터링
    final cards = _allSelectableCards
        .where((c) => c.suit == _selectedSuit)
        .toList();

    // 3열로 나누기 (A-K-Q-J / 10-9-8-7 / 6-5-4-3-2)
    final row1 = cards.where((c) =>
        c.rank == Rank.ace || c.rank == Rank.king ||
        c.rank == Rank.queen || c.rank == Rank.jack).toList();
    final row2 = cards.where((c) =>
        c.rank == Rank.ten || c.rank == Rank.nine ||
        c.rank == Rank.eight || c.rank == Rank.seven).toList();
    final row3 = cards.where((c) =>
        c.rank == Rank.six || c.rank == Rank.five ||
        c.rank == Rank.four || c.rank == Rank.three || c.rank == Rank.two).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 반응형: 너비와 높이 기준 중 작은 값 사용
    final cardWidthByWidth = (screenWidth - 64) / 5.5;
    final cardWidthByHeight = (screenHeight - 450) / 6;
    final cardWidth = cardWidthByWidth < cardWidthByHeight ? cardWidthByWidth : cardWidthByHeight;
    final cardHeight = cardWidth * 1.3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCardGridRow(row1, cardWidth, cardHeight),
        const SizedBox(height: 6),
        _buildCardGridRow(row2, cardWidth, cardHeight),
        const SizedBox(height: 6),
        _buildCardGridRow(row3, cardWidth, cardHeight),
      ],
    );
  }

  Widget _buildCardGridRow(List<PlayingCard> cards, double cardWidth, double cardHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.map((card) {
        final isInHand = _isCardInHand(card);
        final isMighty = card == widget.mighty;
        final isJokerCall = card == _getJokerCallCard();
        final isDisabled = isInHand || isMighty || isJokerCall;
        final isSelected = _selectedType == 'card' && _selectedCard == card;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    setState(() {
                      _selectedType = 'card';
                      _selectedCard = card;
                    });
                  },
            child: Opacity(
              opacity: isDisabled ? 0.3 : 1.0,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.amber : (isDisabled ? Colors.grey : Colors.grey[400]!),
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
    );
  }

  Widget _buildMiniCard(PlayingCard card) {
    final color = card.isRed ? Colors.red : Colors.black;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.suitSymbol,
            style: TextStyle(fontSize: 16, color: color),
          ),
          Text(
            card.rankSymbol,
            style: TextStyle(
              fontSize: 14,
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
      case 'jokerCall':
        return '${l10n.jokerCallTitle} (${_getJokerCallSymbol()})';
      case 'none':
        return l10n.noFriend;
      case 'card':
        if (_selectedCard != null) {
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
      case 'jokerCall':
        declaration = FriendDeclaration.byCard(_getJokerCallCard());
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
