enum TimeControlCategory {
  bullet('Bullet', '⚡'),
  blitz('Blitz', '🔥'),
  rapid('Rapid', '⏱️'),
  classical('Classical', '⏳'),
  custom('Custom', '⚙️');

  final String label;
  final String icon;

  const TimeControlCategory(this.label, this.icon);
}

class TimeControl {
  final String id;
  final String name;
  final int initialSeconds;
  final int incrementSeconds;
  final TimeControlCategory category;

  const TimeControl({
    required this.id,
    required this.name,
    required this.initialSeconds,
    this.incrementSeconds = 0,
    required this.category,
  });

  String get displayName => incrementSeconds > 0
      ? '${initialSeconds ~/ 60} + $incrementSeconds'
      : '${initialSeconds ~/ 60} min';

  // Standard FIDE/Online Presets
  static const TimeControl bullet1_0 = TimeControl(
    id: 'bullet_1_0',
    name: '1 min',
    initialSeconds: 60,
    incrementSeconds: 0,
    category: TimeControlCategory.bullet,
  );

  static const TimeControl bullet2_1 = TimeControl(
    id: 'bullet_2_1',
    name: '2 | 1',
    initialSeconds: 120,
    incrementSeconds: 1,
    category: TimeControlCategory.bullet,
  );

  static const TimeControl blitz3_0 = TimeControl(
    id: 'blitz_3_0',
    name: '3 min',
    initialSeconds: 180,
    incrementSeconds: 0,
    category: TimeControlCategory.blitz,
  );

  static const TimeControl blitz3_2 = TimeControl(
    id: 'blitz_3_2',
    name: '3 | 2',
    initialSeconds: 180,
    incrementSeconds: 2,
    category: TimeControlCategory.blitz,
  );

  static const TimeControl blitz5_0 = TimeControl(
    id: 'blitz_5_0',
    name: '5 min',
    initialSeconds: 300,
    incrementSeconds: 0,
    category: TimeControlCategory.blitz,
  );

  static const TimeControl blitz5_3 = TimeControl(
    id: 'blitz_5_3',
    name: '5 | 3',
    initialSeconds: 300,
    incrementSeconds: 3,
    category: TimeControlCategory.blitz,
  );

  static const TimeControl rapid10_0 = TimeControl(
    id: 'rapid_10_0',
    name: '10 min',
    initialSeconds: 600,
    incrementSeconds: 0,
    category: TimeControlCategory.rapid,
  );

  static const TimeControl rapid15_10 = TimeControl(
    id: 'rapid_15_10',
    name: '15 | 10',
    initialSeconds: 900,
    incrementSeconds: 10,
    category: TimeControlCategory.rapid,
  );

  static const TimeControl classical30_0 = TimeControl(
    id: 'classical_30_0',
    name: '30 min',
    initialSeconds: 1800,
    incrementSeconds: 0,
    category: TimeControlCategory.classical,
  );

  static const List<TimeControl> presets = [
    bullet1_0,
    bullet2_1,
    blitz3_0,
    blitz3_2,
    blitz5_0,
    blitz5_3,
    rapid10_0,
    rapid15_10,
    classical30_0,
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initialSeconds': initialSeconds,
        'incrementSeconds': incrementSeconds,
        'category': category.name,
      };

  factory TimeControl.fromJson(Map<String, dynamic> json) {
    return TimeControl(
      id: json['id'] as String,
      name: json['name'] as String,
      initialSeconds: json['initialSeconds'] as int,
      incrementSeconds: json['incrementSeconds'] as int? ?? 0,
      category: TimeControlCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TimeControlCategory.rapid,
      ),
    );
  }
}
