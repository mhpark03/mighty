import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
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
            // 랭크 심볼 (10 등 긴 텍스트도 한 줄에 표시)
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
            // 무늬 심볼
            Text(
              card.suitSymbol,
              style: TextStyle(
                fontSize: height * 0.28,
                color: color,
                fontFamily: 'Roboto',  // 이모지 폰트 대신 텍스트 폰트 사용
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
                fontFamily: 'Roboto',  // 이모지 폰트 대신 텍스트 폰트 사용
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
                  fontFamily: 'Roboto',  // 이모지 폰트 대신 텍스트 폰트 사용
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: iconSize),
            const SizedBox(height: 2),
            Text(
              isSmall ? 'JK' : AppLocalizations.of(context)!.joker.toUpperCase(),
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
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
              Text('JK', style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.bold, color: Colors.white)),
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
                fontFamily: 'Roboto',  // 이모지 폰트 대신 텍스트 폰트 사용
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
