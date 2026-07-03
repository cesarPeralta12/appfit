class DietNote {
  final int id;
  final int studentId;
  final String type;
  final String note;
  final String date;

  DietNote({required this.id, required this.studentId, required this.type, required this.note, required this.date});

  factory DietNote.fromJson(Map<String, dynamic> json) => DietNote(
        id: json['id'],
        studentId: json['student_id'],
        type: json['type'] ?? 'habit',
        note: json['note'] ?? '',
        date: json['date'] ?? '',
      );
}
