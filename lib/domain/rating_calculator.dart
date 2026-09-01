import 'dart:math';

class RatingCalculationResult {
  final int whiteNewRating;
  final int whiteRatingDelta;
  final int blackNewRating;
  final int blackRatingDelta;

  const RatingCalculationResult({
    required this.whiteNewRating,
    required this.whiteRatingDelta,
    required this.blackNewRating,
    required this.blackRatingDelta,
  });
}

class RatingCalculator {
  /// Calculate dynamic K-factor based on player's rating and games played
  static int getKFactor({required int rating, required int gamesPlayed}) {
    if (gamesPlayed < 30) return 40; // Provisional
    if (rating >= 2400) return 10;   // Master level
    return 20;                      // Standard
  }

  /// Expected score formula: E = 1 / (1 + 10 ^ ((Rb - Ra) / 400))
  static double getExpectedScore(int playerRating, int opponentRating) {
    return 1.0 / (1.0 + pow(10.0, (opponentRating - playerRating) / 400.0));
  }

  /// Calculate rating updates for a match
  /// [whiteScore]: 1.0 (white win), 0.5 (draw), 0.0 (black win)
  static RatingCalculationResult calculateElo({
    required int whiteRating,
    required int blackRating,
    required double whiteScore,
    int whiteGamesPlayed = 30,
    int blackGamesPlayed = 30,
  }) {
    final whiteExpected = getExpectedScore(whiteRating, blackRating);
    final blackExpected = 1.0 - whiteExpected;
    final blackScore = 1.0 - whiteScore;

    final whiteK = getKFactor(rating: whiteRating, gamesPlayed: whiteGamesPlayed);
    final blackK = getKFactor(rating: blackRating, gamesPlayed: blackGamesPlayed);

    final whiteDelta = (whiteK * (whiteScore - whiteExpected)).round();
    final blackDelta = (blackK * (blackScore - blackExpected)).round();

    return RatingCalculationResult(
      whiteNewRating: max(100, whiteRating + whiteDelta),
      whiteRatingDelta: whiteDelta,
      blackNewRating: max(100, blackRating + blackDelta),
      blackRatingDelta: blackDelta,
    );
  }
}
