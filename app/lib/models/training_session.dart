import 'exercise.dart';

class SessionExerciseLog {
  final int? id;
  final int setNumber;
  final int? repsDone;
  final double? weightUsed;
  final bool completed;
  final String? effort;

  SessionExerciseLog({
    this.id,
    required this.setNumber,
    this.repsDone,
    this.weightUsed,
    this.completed = false,
    this.effort,
  });

  factory SessionExerciseLog.fromJson(Map<String, dynamic> json) => SessionExerciseLog(
        id: json['id'],
        setNumber: json['set_number'],
        repsDone: json['reps_done'],
        weightUsed: json['weight_used'] != null ? double.tryParse(json['weight_used'].toString()) : null,
        completed: json['completed'] ?? false,
        effort: json['effort'],
      );
}

class SessionExercise {
  final int id;
  final Exercise exercise;
  final int? plannedSets;
  final int? plannedReps;
  final double? plannedWeight;
  final List<SessionExerciseLog> logs;

  SessionExercise({
    required this.id,
    required this.exercise,
    this.plannedSets,
    this.plannedReps,
    this.plannedWeight,
    this.logs = const [],
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) => SessionExercise(
        id: json['id'],
        exercise: Exercise.fromJson(json['exercise']),
        plannedSets: json['planned_sets'],
        plannedReps: json['planned_reps'],
        plannedWeight: json['planned_weight'] != null
            ? double.tryParse(json['planned_weight'].toString())
            : null,
        logs: json['logs'] != null
            ? (json['logs'] as List).map((e) => SessionExerciseLog.fromJson(e)).toList()
            : [],
      );
}

class TrainingSession {
  final int id;
  final int? studentId;
  final String type;
  final DateTime scheduledAt;
  final int? durationMinutes;
  final String status;
  final String? notes;
  final List<SessionExercise> exercises;
  final Map<String, dynamic>? student;

  TrainingSession({
    required this.id,
    this.studentId,
    required this.type,
    required this.scheduledAt,
    this.durationMinutes,
    required this.status,
    this.notes,
    this.exercises = const [],
    this.student,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) => TrainingSession(
        id: json['id'],
        studentId: json['student_id'],
        type: json['type'] ?? 'fuerza',
        scheduledAt: DateTime.parse(json['scheduled_at']),
        durationMinutes: json['duration_minutes'],
        status: json['status'] ?? 'planned',
        notes: json['notes'],
        exercises: json['exercises'] != null
            ? (json['exercises'] as List).map((e) => SessionExercise.fromJson(e)).toList()
            : [],
        student: json['student'],
      );
}
