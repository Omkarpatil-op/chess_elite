# Chess Engine Specification

Chess Elite incorporates an independent, deterministic, high-performance pure Dart chess engine and evaluation system.

---

## 🎯 Supported Chess Rules

### 1. Pieces & Movement
* **Pawns**: Single advance, initial 2-square advance, diagonal captures, En Passant captures on the immediate following turn, and promotion to Queen, Rook, Bishop, or Knight.
* **Knights**: Standard 8-directional L-jumps (`(±1, ±2)`, `(±2, ±1)`).
* **Bishops**: Diagonal rays (`(-1, -1)`, `(-1, +1)`, `(+1, -1)`, `(+1, +1)`).
* **Rooks**: Orthogonal rays (`(-1, 0)`, `(+1, 0)`, `(0, -1)`, `(0, +1)`).
* **Queens**: Combined 8-directional diagonal and orthogonal ray tracing.
* **Kings**: 8 adjacent squares and Kingside (`O-O`) / Queenside (`O-O-O`) Castling.

### 2. Castling Legality Checks
Castling is permitted only when:
1. Neither the King nor the target Rook has moved since the game began.
2. The squares between the King and the Rook are vacant.
3. The King is not currently in check.
4. The squares traversed and occupied by the King during the castle are not under attack by any enemy piece.

### 3. Game Termination Detection
* **Checkmate**: Active King is in check and no legal move resolves the check.
* **Stalemate**: Active King is not in check, but the player has zero legal moves.
* **50-Move Rule**: 50 consecutive full moves (100 half-moves) occur without any pawn movement or piece capture.
* **Threefold Repetition**: Identical position (same piece layout, active turn, castling rights, and en passant availability) occurs 3 times.
* **Insufficient Material**:
  - King vs King
  - King + Bishop vs King
  - King + Knight vs King
  - King + Bishop vs King + Bishop (where both bishops occupy squares of the same color).

---

## 🤖 AI Search & Evaluation

### Search Architecture
* **Algorithm**: Minimax search with Alpha-Beta pruning.
* **Move Ordering**: Evaluates high-impact moves first to maximize alpha-beta cutoffs:
  1. Checks and Mate threats
  2. MVV-LVA (Most Valuable Victim - Least Valuable Attacker) captures
  3. Pawn promotions
  4. Castling moves
* **Quiescence Search**: Extends search depth on tactical capture sequences to eliminate the "horizon effect".
* **Isolate Execution**: `AiIsolateRunner.computeBestMoveAsync()` runs in a separate background Dart thread.

### AI Difficulty Tiers

| Level | Tier | ELO | Search Depth | Characteristics |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Beginner | ~600 | 1 | 35% random variance, simple non-blunder moves |
| **2** | Easy | ~1000 | 2 | Basic material checks, low blunder rate |
| **3** | Medium | ~1400 | 3 | Full Piece-Square Tables (PST), positional play |
| **4** | Hard | ~1800 | 4 | Quiescence search, sharp tactics |
| **5** | Expert | ~2200 | 5 | Quiescence + Alpha-Beta pruning, endgame strategy |
| **6** | Master | ~2500 | 6+ | Deep positional evaluation, center control, king safety |
