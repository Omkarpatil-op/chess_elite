# Chess Elite — Architecture Specification

Chess Elite follows **Clean Architecture** combined with a **Feature-Driven** layout, strictly enforcing Separation of Concerns between Presentation, Domain, Data, and Infrastructure layers.

---

## 🏛️ Layered System Overview

```text
Presentation Layer (UI, Screens, Custom Painters, ViewModels)
       ↓
Domain Layer (Entities, Value Objects, Use Cases, ELO Calculator)
       ↓
Data Layer (Repositories, DTOs, Local Storage, API & WebSocket Clients)
       ↓
Infrastructure & Core (Pure Chess Engine, AI Isolate, Theme Tokens, Audio, Haptics, Logging)
```

---

## 📂 Directory Structure

```text
lib/
├── core/
│   ├── chess_engine/          # Deterministic pure Dart engine & AI
│   │   ├── models/            # Piece, Square, Move, GameState, CastlingRights
│   │   ├── board.dart         # FEN parser & serializer, position hashing
│   │   ├── move_generator.dart# Legal move generation & pin/check validation
│   │   ├── rules_engine.dart  # Checkmate, Stalemate, Draws, En Passant, Castling
│   │   ├── game_evaluator.dart# Static PST evaluation heuristics
│   │   ├── ai_engine.dart     # Minimax, Alpha-Beta, Quiescence, 6 AI Tiers
│   │   ├── ai_isolate.dart    # Background Isolate runner (60 FPS)
│   │   └── pgn_processor.dart # PGN parser and exporter
│   ├── theme/                 # AppColors, AppTypography, BoardThemes, PieceThemes
│   ├── audio/                 # SoundService (move, capture, check, alert cues)
│   ├── haptics/               # HapticService (selection, move, check feedback)
│   ├── storage/               # SharedPreferences abstraction
│   ├── security/              # Secure token management & salted key hashing
│   ├── logging/               # Structured AppLogger with automatic redaction
│   ├── analytics/             # Telemetry & event tracking interface
│   ├── errors/                # Strongly-typed AppException hierarchy
│   └── di/                    # ServiceLocator dependency container
│
├── domain/
│   ├── models/                # UserProfile, ChessMatch, TimeControl, Leaderboard, Friends
│   └── rating_calculator.dart # FIDE-standard Elo calculation with dynamic K-factors
│
├── data/
│   ├── services/
│   │   ├── realtime_game_client.dart       # WebSocket realtime protocol
│   │   └── mock_authoritative_game_server.dart # Server-authoritative validator & clock sync
│   └── repositories/
│       ├── auth_repository.dart
│       ├── game_repository.dart
│       ├── matchmaking_repository.dart
│       ├── social_repository.dart
│       └── settings_repository.dart
│
├── presentation/
│   ├── widgets/
│   │   ├── piece_painter.dart     # Custom vector canvas piece renderer
│   │   ├── chess_board_widget.dart# Responsive 8x8 interactive board
│   │   ├── chess_clock_widget.dart# Dual digital countdown clock
│   │   ├── move_history_widget.dart# Horizontal SAN move sequence
│   │   ├── captured_pieces_widget.dart# Material differential badges
│   │   ├── evaluation_bar_widget.dart# Real-time advantage bar
│   │   ├── promotion_dialog.dart  # Pawn promotion selection
│   │   └── game_result_dialog.dart# Post-match victory/defeat celebration
│   └── screens/
│       ├── splash_screen.dart
│       ├── home_screen.dart
│       ├── game_screen.dart
│       ├── matchmaking_screen.dart
│       ├── analysis_screen.dart
│       ├── profile_screen.dart
│       ├── leaderboard_screen.dart
│       ├── friends_screen.dart
│       ├── history_screen.dart
│       ├── settings_screen.dart
│       └── auth_screen.dart
│
└── main.dart
```

---

## ⚙️ Key Architectural Decisions

1. **Self-Contained Vector Piece Painter**:
   - Rather than relying on external bitmap assets or SVG network assets that risk failing to bundle, all 6 chess pieces are rendered using high-precision Bezier paths directly on Flutter Canvas. This guarantees sub-millisecond drawing and sharpness on 4K, iPad Pro, and Android tablets.

2. **Background Isolate Threading for AI**:
   - AI search (depth 1 to 6) is computed off the UI thread using Dart's `Isolate.run()` worker. The main UI thread never drops a single frame during complex tactical calculations.

3. **Server-Authoritative Multiplayer Design**:
   - The client never decides if a move is valid or updates authoritative clocks. In online mode, moves are sent as UCI tokens (`e2e4`) to the authoritative server, validated server-side, and synchronized via `CLOCK_SYNC` and `MOVE_MADE` events with monotonic sequence numbers.
