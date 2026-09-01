# Chess Elite — Grandmaster Edition ♟️

**Chess Elite** is a production-grade, commercial-quality mobile chess application built with **Flutter & Dart**, engineered for store deployment on the **Google Play Store** and **Apple App Store**.

---

## 🌟 Key Features

* **Deterministic Chess Engine**: 100% pure Dart legal move generator & validator supporting all FIDE rules (Castling, En Passant, Promotions, Pins, Checks, Checkmates, Stalemates, 50-move rule, Threefold Repetition, Insufficient Material).
* **Intelligent AI Engine**: Minimax with Alpha-Beta pruning, Quiescence search, Piece-Square Tables (PSTs), and 6 distinct difficulty tiers (Beginner, Easy, Medium, Hard, Expert, Master) executed on background **Dart Isolates** to preserve 60 FPS UI fluidity.
* **Responsive Vector Chessboard**: Precision custom-canvas vector piece rendering (zero missing asset risk, crisp across Retina/4K screens), drag-and-drop, tap-to-move, legal move indicators, check glows, board flipping, and 5 tournament-grade themes.
* **Precision Time Controls**: Bullet (1+0, 2+1), Blitz (3+0, 3+2, 5+0, 5+3), Rapid (10+0, 15+10), Classical (30+0), and Custom clocks with tenth-of-a-second countdowns and increment handling.
* **Authoritative Multiplayer Architecture**: Typed WebSocket client protocol (`RealtimeMessage`), auto-reconnection, sequence numbering, server-authoritative move validation, clock synchronization, draw negotiations, and rematch handling.
* **Social & Player Ecosystem**: Standard FIDE-compliant ELO calculation engine with dynamic K-factors, player statistics, career charts, global & friends leaderboards with podium, user search, and game invitations.
* **Analysis & Game Archive**: Step-through interactive move replay (First, Previous, Next, Last), dynamic evaluation bar, captured pieces differential, PGN parser/exporter, and clipboard copy.
* **Design System & Polish**: Dark & Light luxury obsidian/gold palettes, tactile haptics, customizable audio cues, accessibility semantic descriptions on all 64 squares, and secure account deletion.

---

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.24.0 or newer)
- Dart SDK 3.5.0+
- Android Studio / Xcode

### Installation & Run

```bash
# 1. Clone repository
git clone https://github.com/your-org/chess_elite.git
cd chess_elite

# 2. Install dependencies
flutter pub get

# 3. Verify static analysis
flutter analyze

# 4. Run full test suite
flutter test

# 5. Run application
flutter run
```

---

## 📚 Project Documentation

For comprehensive technical documentation, refer to:
* [Architecture Guide](ARCHITECTURE.md) — Clean Architecture layers, state management, and design patterns.
* [Chess Engine Specification](CHESS_ENGINE.md) — FEN/PGN algorithms, move generator, and evaluation heuristics.
* [Environment Configuration](ENVIRONMENT.md) — Dev, Staging, and Production environment secrets.
* [API & Real-time Protocols](API.md) — REST contracts and WebSocket realtime event specifications.
* [Setup & Local Development](SETUP.md) — Development workflow and tooling.
* [Testing Guide](TESTING.md) — Unit, Widget, and Engine test suites.
* [Security & Anti-Cheat](SECURITY.md) — Token security, authoritative server validation, and privacy controls.
* [Deployment & Store Release](DEPLOYMENT.md) — Google Play Store and Apple App Store release instructions.

---

## 🛡️ License

Proprietary commercial license. All rights reserved.
