# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter card game application featuring multiple Korean card games: Mighty (마이티), Seven Card (세븐카드), Hi-Lo (하이로우), Hula (훌라), One Card (원카드), and Hearts (하츠). Cross-platform support for Android, iOS, Web, and Windows.

## Build and Development Commands

```bash
# Run app on connected device
flutter run

# Build for production
flutter build apk          # Android APK
flutter build aab          # Android App Bundle (Play Store)
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows

# Testing and code quality
flutter test               # Run all tests
flutter test test/widget_test.dart  # Run specific test
flutter analyze            # Dart static analysis

# Localization (run after editing .arb files)
flutter gen-l10n

# Dependencies
flutter pub get            # Install dependencies
flutter clean              # Clean build cache
```

## Architecture

**State Management:** Provider pattern with ChangeNotifier, but asymmetric across games.

**Navigation:** Imperative `Navigator.push(MaterialPageRoute(...))` throughout — no named routes or router package. Flow: `GameSelectionScreen` → game-specific `*HomeScreen` → game `*Screen`.

**Directory Structure:**
- `lib/models/` - Shared data classes (PlayingCard, Player, GameState, PlayerStats) used by Mighty, SevenCard, HiLo
- `lib/services/` - Business logic and controllers
- `lib/screens/` - UI screens
- `lib/widgets/` - Two shared widgets: `card_widget.dart`, `banner_ad_widget.dart`
- `lib/l10n/` - Localization (.arb files and generated code)

**Game Architecture Tiers:**

| Game | Controller | AI Logic | Models | In MultiProvider |
|------|-----------|----------|--------|-----------------|
| Mighty | `services/game_controller.dart` | `services/ai_player.dart` (2700+ lines) | `models/*.dart` (shared) | Yes |
| SevenCard | `services/seven_card/seven_card_controller.dart` | Embedded in controller | `models/seven_card/` + shared | Yes |
| HiLo | `services/hi_lo/hi_lo_controller.dart` | Embedded in controller | `models/hi_lo/` + shared | Yes |
| Hula | None (StatefulWidget) | Embedded in screen | None | No |
| OneCard | None (StatefulWidget) | Embedded in screen | None | No |
| Hearts | None (StatefulWidget) | Embedded in screen | Local types in screen file | No |

Mighty, SevenCard, and HiLo have dedicated ChangeNotifier controllers in `MultiProvider`. Hula, OneCard, and Hearts are self-contained `StatefulWidget` screens with all game logic inline.

**Hearts isolation:** Hearts defines its own `PlayingCard`, `Suit`, and `GamePhase` enums locally inside `hearts_screen.dart`, completely separate from the shared `lib/models/card.dart`.

**Cross-game dependency:** HiLo imports `lib/models/seven_card/poker_hand.dart` for poker hand evaluation.

**Key Services:**
- `GameController` - Orchestrates Mighty game flow (bidding, tricks, scoring). Has `_isProcessing` mutex guard for async AI moves.
- `AIPlayer` - AI decision engine for Mighty only (not sub-games). Exposes `BidExplanation`, `KittyExplanation`, `FriendExplanation` for UI display.
- `GameSaveService` - Single-slot save/load via SharedPreferences. Only one game save exists at a time across all games. Uses `game_save_type` key to identify which game owns the save.
- `MightyTrackingService` - Remote telemetry for Mighty games only. POSTs game data (tricks, bids, hands) to configurable server URL (default: `center.kaistory.net`). Fire-and-forget, silently ignores errors.
- `StatsService` / per-game stats services - SharedPreferences persistence with `loadStats()` / `recordGameResult()` / `resetStats()` pattern. All registered in `MultiProvider`.
- `AdService` - Singleton for AdMob rewarded/banner ads. Stats reset requires watching a rewarded ad.

**Mighty Game State Flow:**
GamePhase: waiting → dealing → bidding → selectingKitty → declaringFriend → playing → roundEnd → gameEnd

**Auto-play mode:** `GameScreen(isAutoPlay: true)` runs all 5 players as AI for automated testing/observation. Tracked in telemetry to filter from human gameplay.

## Serialization Contracts

`PlayingCard` serializes via enum index (`suit?.index`, `rank?.index`). **Do not reorder `Suit` or `Rank` enum values** — this would break saved games and telemetry data. Joker is `rankValue` 15 (above Ace at 14).

## Localization

Template language: Korean (`app_ko.arb`) — this is the source of truth.
Supported: Korean, English, Japanese, Chinese.
Config: `l10n.yaml` at project root.

Edit `.arb` files in `lib/l10n/`, then run `flutter gen-l10n` to regenerate `lib/l10n/generated/`.

## Key Patterns

- Player 0 is always human; players 1-4 (Mighty) or 1-3 (4-player games) are AI
- All screens calculate `isSmallScreen` (height < 600) and `isMediumScreen` dynamically for responsive UI sizing
- Theme: Material 3 with green color scheme (`#1B5E20`), fullscreen immersive mode

## Package ID

Android: `com.mhpark.mighty`
