import 'package:flutter_test/flutter_test.dart';
import 'package:chess_elite/domain/rating_calculator.dart';

void main() {
  group('Rating Calculator - ELO', () {
    test('Equal rating win produces expected delta', () {
      final res = RatingCalculator.calculateElo(
        whiteRating: 1500,
        blackRating: 1500,
        whiteScore: 1.0, // White wins
        whiteGamesPlayed: 50,
        blackGamesPlayed: 50,
      );

      expect(res.whiteRatingDelta, 10);
      expect(res.blackRatingDelta, -10);
      expect(res.whiteNewRating, 1510);
      expect(res.blackNewRating, 1490);
    });

    test('Equal rating draw produces zero delta', () {
      final res = RatingCalculator.calculateElo(
        whiteRating: 1500,
        blackRating: 1500,
        whiteScore: 0.5, // Draw
        whiteGamesPlayed: 50,
        blackGamesPlayed: 50,
      );

      expect(res.whiteRatingDelta, 0);
      expect(res.blackRatingDelta, 0);
    });

    test('Underdog win produces larger delta', () {
      final res = RatingCalculator.calculateElo(
        whiteRating: 1200,
        blackRating: 1600,
        whiteScore: 1.0, // White 1200 beats Black 1600
        whiteGamesPlayed: 50,
        blackGamesPlayed: 50,
      );

      expect(res.whiteRatingDelta > 15, true);
      expect(res.blackRatingDelta < -15, true);
    });

    test('Provisional player uses K=40', () {
      final res = RatingCalculator.calculateElo(
        whiteRating: 1200,
        blackRating: 1200,
        whiteScore: 1.0,
        whiteGamesPlayed: 5, // provisional
        blackGamesPlayed: 50, // established
      );

      expect(res.whiteRatingDelta, 20); // K=40 * 0.5 = 20
      expect(res.blackRatingDelta, -10); // K=20 * -0.5 = -10
    });
  });
}
