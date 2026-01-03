import 'package:flutter/material.dart';
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isPlayable;
  final bool faceDown;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.faceDown = false,
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
        child: Card(
          elevation: isSelected ? 8 : 2,
          color: faceDown ? Colors.blue[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? Colors.yellow
                  : (isPlayable ? Colors.grey[300]! : Colors.grey[500]!),
              width: isSelected ? 3 : 1,
            ),
          ),
          child: faceDown ? _buildCardBack() : _buildCardFront(),
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

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Text(
                  card.rankSymbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  card.suitSymbol,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            card.suitSymbol,
            style: TextStyle(
              fontSize: 28,
              color: color,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RotatedBox(
              quarterTurns: 2,
              child: Column(
                children: [
                  Text(
                    card.rankSymbol,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    card.suitSymbol,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokerCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🃏',
              style: TextStyle(fontSize: 32),
            ),
            Text(
              'JOKER',
              style: TextStyle(
                fontSize: 10,
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
