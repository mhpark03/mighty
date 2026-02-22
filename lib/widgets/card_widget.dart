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
      onTap: onTap,
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
              child: faceDown ? _buildCardBack() : _buildCardFront(context),
            ),
            // 낼 수 없는 카드 어둡게 표시
            if (!isPlayable && !faceDown)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
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

  Widget _buildCardFront(BuildContext context) {
    if (card.isJoker) {
      return _buildJokerCard(context);
    }

    final color = card.isRed ? Colors.red : Colors.black;

    // 간소화 모드: 숫자와 무늬만 중앙에 표시
    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                card.rankSymbol,
                style: TextStyle(
                  fontSize: height * 0.28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Text(
              card.suitSymbol,
              style: TextStyle(
                fontSize: height * 0.28,
                color: color,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      );
    }

    // 카드 크기에 비례한 폰트 크기
    final cornerFontSize = height * 0.12;
    final centerFontSize = height * 0.30;

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
                fontSize: cornerFontSize,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          // 중앙: 큰 무늬
          Expanded(
            child: Center(
              child: Text(
                card.suitSymbol,
                style: TextStyle(
                  fontSize: centerFontSize,
                  color: color,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokerCard(BuildContext context) {
    final isSmall = height < 60;
    final iconSize = isSmall ? 18.0 : 28.0;
    final textSize = isSmall ? 7.0 : 11.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: iconSize),
              const SizedBox(height: 2),
              Text(
                isSmall ? 'JK' : 'JOKER',
                softWrap: false,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontFamily: 'Roboto',
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
                ),
              ),
            ],
          ),
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: size * 0.35),
              Text('JK', style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto')),
            ],
          ),
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
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontFamily: 'Roboto',
              ),
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

class SuitSymbolPainter extends CustomPainter {
  final Suit suit;
  final Color color;

  SuitSymbolPainter({required this.suit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (suit) {
      case Suit.spade:
        _drawSpade(canvas, size, paint);
      case Suit.heart:
        _drawHeart(canvas, size, paint);
      case Suit.diamond:
        _drawDiamond(canvas, size, paint);
      case Suit.club:
        _drawClub(canvas, size, paint);
    }
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.2)
      ..cubicTo(w * 0.5, h * 0.05, 0, 0, 0, h * 0.35)
      ..cubicTo(0, h * 0.65, w * 0.5, h * 0.85, w * 0.5, h)
      ..cubicTo(w * 0.5, h * 0.85, w, h * 0.65, w, h * 0.35)
      ..cubicTo(w, 0, w * 0.5, h * 0.05, w * 0.5, h * 0.2)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSpade(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final bodyH = size.height * 0.72;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.5, bodyH * 0.15, 0, bodyH * 0.1, 0, bodyH * 0.5)
      ..cubicTo(0, bodyH * 0.8, w * 0.4, bodyH * 0.9, w * 0.5, bodyH)
      ..cubicTo(w * 0.6, bodyH * 0.9, w, bodyH * 0.8, w, bodyH * 0.5)
      ..cubicTo(w, bodyH * 0.1, w * 0.5, bodyH * 0.15, w * 0.5, 0)
      ..close();
    canvas.drawPath(path, paint);
    final sh = size.height;
    final stem = Path()
      ..moveTo(w * 0.35, sh * 0.62)
      ..cubicTo(w * 0.35, sh * 0.8, w * 0.22, sh * 0.95, w * 0.22, sh)
      ..lineTo(w * 0.78, sh)
      ..cubicTo(w * 0.78, sh * 0.95, w * 0.65, sh * 0.8, w * 0.65, sh * 0.62)
      ..close();
    canvas.drawPath(stem, paint);
  }

  void _drawDiamond(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawClub(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.26;
    canvas.drawCircle(Offset(w * 0.5, r), r, paint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.48), r, paint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.48), r, paint);
    final stem = Path()
      ..moveTo(w * 0.38, h * 0.45)
      ..lineTo(w * 0.28, h)
      ..lineTo(w * 0.72, h)
      ..lineTo(w * 0.62, h * 0.45)
      ..close();
    canvas.drawPath(stem, paint);
  }

  @override
  bool shouldRepaint(covariant SuitSymbolPainter oldDelegate) =>
      suit != oldDelegate.suit || color != oldDelegate.color;
}
