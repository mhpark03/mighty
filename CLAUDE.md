# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter card game application featuring multiple Korean card games: Mighty (마이티), Seven Card (세븐카드), Hi-Lo (하이로우), Hula (훌라), and One Card (원카드). Cross-platform support for Android, iOS, Web, and Windows.

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

**State Management:** Provider pattern with ChangeNotifier

**Directory Structure:**
- `lib/models/` - Data classes (Card, Player, GameState, PlayerStats)
- `lib/services/` - Business logic and controllers
- `lib/screens/` - UI screens
- `lib/widgets/` - Reusable UI components
- `lib/l10n/` - Localization (.arb files and generated code)

**Key Services:**
- `GameController` - Orchestrates Mighty game flow (bidding, tricks, scoring)
- `AIPlayer` (2700+ lines) - AI decision engine for all games
- `StatsService` - Player statistics persistence via SharedPreferences
- `AdService` - AdMob rewarded/banner ads
- Game-specific controllers in subdirectories (hi_lo/, seven_card/, hula/, onecard/)

**Game State Flow (Mighty):**
GamePhase: waiting → dealing → bidding → selectingKitty → declaringFriend → playing → roundEnd → gameEnd

## Localization

Template language: Korean (`app_ko.arb`)
Supported: Korean, English, Japanese, Chinese

Edit `.arb` files in `lib/l10n/`, then run `flutter gen-l10n` to regenerate `lib/l10n/generated/`.

## Key Patterns

- Each game has its own subdirectory in models/, services/, and screens/
- Player 0 is human, players 1-4 are AI opponents
- Stats services use SharedPreferences for persistence
- Screens use ChangeNotifierProvider to consume controller state
- Theme: Material 3 with green color scheme, fullscreen immersive mode

## Package ID

Android: `com.mhpark.mighty`
