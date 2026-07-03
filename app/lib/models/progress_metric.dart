class ProgressMetric {
  final int id;
  final int studentId;
  final int? exerciseId;
  final String? label;
  final String metricType;
  final double value;
  final String? unit;
  final String recordedAt;

  ProgressMetric({
    required this.id,
    required this.studentId,
    this.exerciseId,
    this.label,
    required this.metricType,
    required this.value,
    this.unit,
    required this.recordedAt,
  });

  factory ProgressMetric.fromJson(Map<String, dynamic> json) => ProgressMetric(
        id: json['id'],
        studentId: json['student_id'],
        exerciseId: json['exercise_id'],
        label: json['label'],
        metricType: json['metric_type'],
        value: double.tryParse(json['value'].toString()) ?? 0,
        unit: json['unit'],
        recordedAt: json['recorded_at'],
      );
}
