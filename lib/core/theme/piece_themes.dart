enum PieceStyle {
  stauntonClassic('Staunton Classic', 'Standard tournament weighted pieces with distinct curves'),
  neoModern('Neo Modern', 'Sleek minimal geometric aesthetic for fast recognition'),
  woodCarved('Wood Carved', 'Artisanal organic silhouettes with detailed knight styling'),
  minimalAlpha('Minimalist Alpha', 'Clean high-contrast vector outlines for maximum readability');

  final String label;
  final String description;

  const PieceStyle(this.label, this.description);
}
