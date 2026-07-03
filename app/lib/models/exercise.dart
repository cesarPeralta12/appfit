class Exercise {
  final int id;
  final String name;
  final String category;
  final String? description;
  final String? technique;
  final List<dynamic> muscleGroups;
  final int difficulty;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.technique,
    this.muscleGroups = const [],
    this.difficulty = 1,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        name: json['name'],
        category: json['category'] ?? 'pesas',
        description: json['description'],
        technique: json['technique'],
        muscleGroups: json['muscle_groups'] ?? [],
        difficulty: json['difficulty'] ?? 1,
      );
}
