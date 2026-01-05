import 'package:flutter/material.dart';
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isPlayable;
  final bool faceDown;
  final bool isRecommended;
  final bool compact; // 간소화 모드: 숫자와 무늬만 표시
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.faceDown = false,
    this.isRecommended = false,
    this.compact = false,
    this.onTap,
    this.width = 60,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: isSelected ? 8 : (isRecommended ? 6 : 2),
              color: faceDown ? Colors.blue[800] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Colors.yellow
                      : (isRecommended
                          ? Colors.lightBlueAccent
                          : (isPlayable ? Colors.grey[300]! : Colors.grey[500]!)),
                  width: isSelected ? 3 : (isRecommended ? 3 : 1),
                ),
              ),
              child: faceDown ? _buildCardBack() : _buildCardFront(),
            ),
            // 추천 표시 배지
            if (isRecommended)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.blue[900]!],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.casino,
          color: Colors.white.withOpacity(0.5),
          size: 30,
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    if (card.isJoker) {
      return _buildJokerCard();
    }

    final color = card.isRed ? Colors.red : Colors.black;

    // 간소화 모드: 숫자와 무늬만 중앙에 표시
    if (compact) {
      return Center(
        child: Text(
          '${card.rankSymbol}\n${card.suitSymbol}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: height * 0.22,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.1,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          // 상단 왼쪽: 숫자와 무늬
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${card.rankSymbol}\n${card.suitSymbol}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
          ),
          // 중앙: 큰 무늬
          Expanded(
            child: Center(
              child: Text(
                card.suitSymbol,
                style: TextStyle(
                  fontSize: 26,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokerCard() {
    // 카드 크기에 따라 폰트 크기 조절
    final isSmall = height < 60;
    final emojiSize = isSmall ? 16.0 : 24.0;
    final textSize = isSmall ? 6.0 : 8.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🃏',
              style: TextStyle(fontSize: emojiSize),
            ),
            if (!isSmall)
              Text(
                'JOKER',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MiniCardWidget extends StatelessWidget {
  final PlayingCard card;
  final double size;

  const MiniCardWidget({
    super.key,
    required this.card,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (card.isJoker) {
      return Container(
        width: size,
        height: size * 1.4,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Center(
          child: Text('🃏', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    final color = card.isRed ? Colors.red : Colors.black;

    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.suitSymbol,
              style: TextStyle(fontSize: 14, color: color),
            ),
            Text(
              card.rankSymbol,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
