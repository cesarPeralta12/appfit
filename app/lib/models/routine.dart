import 'exercise.dart';

class RoutineExercise {
  final int? id;
  Exercise exercise;
  int? sets;
  int? reps;
  double? weight;
  int? durationSeconds;
  int? restSeconds;
  String? notes;

  RoutineExercise({
    this.id,
    required this.exercise,
    this.sets,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.restSeconds,
    this.notes,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) => RoutineExercise(
        id: json['id'],
        exercise: Exercise.fromJson(json['exercise']),
        sets: json['sets'],
        reps: json['reps'],
        weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
        durationSeconds: json['duration_seconds'],
        restSeconds: json['rest_seconds'],
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'exercise_id': exercise.id,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'duration_seconds': durationSeconds,
        'rest_seconds': restSeconds,
        'notes': notes,
      };
}

class Routine {
  final int id;
  final int studentId;
  String name;
  String? notes;
  List<RoutineExercise> exercises;

  Routine({
    required this.id,
    required this.studentId,
    required this.name,
    this.notes,
    this.exercises = const [],
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'],
        studentId: json['student_id'],
        name: json['name'],
        notes: json['notes'],
        exercises: json['exercises'] != null
            ? (json['exercises'] as List).map((e) => RoutineExercise.fromJson(e)).toList()
            : [],
      );
}
