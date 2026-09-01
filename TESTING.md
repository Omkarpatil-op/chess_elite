# Testing Strategy & Test Suites

Chess Elite is thoroughly validated across unit, tactical AI, rating calculation, and widget testing layers.

---

## 🧪 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suites
```bash
# 1. Chess Engine Rules & Special Moves
flutter test test/chess_engine_test.dart

# 2. AI Tactical Intelligence & Background Isolates
flutter test test/ai_engine_test.dart

# 3. FIDE Elo Rating Calculator
flutter test test/rating_calculator_test.dart

# 4. Chessboard & Clocks Widget Interactions
flutter test test/chess_board_widget_test.dart

# 5. App Launch & Smoke Tests
flutter test test/widget_test.dart
```

---

## 📊 Test Coverage Summary

1. **Board & FEN**:
   - Initial board setup and FEN serialization round-tripping.
2. **Pawn Rules & Special Moves**:
   - Single step, initial double step, diagonal captures, En Passant (immediate vs expired), Promotions to Queen/Rook/Bishop/Knight.
3. **Castling Legality**:
   - Kingside and Queenside castling, path clearance, king in check restrictions, crossing attacked squares.
4. **Game Termination**:
   - Checkmate (Scholar's Mate, Fool's Mate), Stalemate detection, Threefold Repetition, 50-move rule, Insufficient Material (K vs K, K+B vs K, K+N vs K, same-color bishops).
5. **AI Tactical Competence**:
   - Mate-in-1 discovery, hanging queen captures, and Isolate thread safety.
6. **Elo Calculation**:
   - Equal-rating wins, draws, underdog upsets, and provisional K-factor weighting.
7. **Widget & Interactions**:
   - Responsive board layout, coordinate rendering, tap-to-select, tap-to-move, and millisecond clock countdowns.
