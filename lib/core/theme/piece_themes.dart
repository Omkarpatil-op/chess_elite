enum PieceStyle {
  stauntonClassic('Staunton Tournament', 'Championship standard pieces with weighted curves & regal detail'),
  neoModern('Neo Modern', 'Clean geometric vector aesthetic for rapid recognition'),
  woodCarved('Artisan Woodcraft', 'Hand-carved organic silhouettes with detailed knight mane'),
  minimalAlpha('Minimalist Studio', 'High-contrast minimalist vector outlines for pro readability');

  final String label;
  final String description;

  const PieceStyle(this.label, this.description);
}
