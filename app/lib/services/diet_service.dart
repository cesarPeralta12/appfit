import '../models/diet_note.dart';
import 'api_client.dart';

class DietService {
  final _dio = ApiClient().dio;

  Future<List<DietNote>> listByStudent(int studentId) async {
    final res = await _dio.get('/diet-notes', queryParameters: {'student_id': studentId});
    return (res.data as List).map((e) => DietNote.fromJson(e)).toList();
  }

  Future<DietNote> create(int studentId, String type, String note) async {
    final res = await _dio.post('/diet-notes', data: {
      'student_id': studentId,
      'type': type,
      'note': note,
      'date': DateTime.now().toIso8601String().split('T').first,
    });
    return DietNote.fromJson(res.data);
  }

  Future<DietNote> update(int id, String type, String note) async {
    final res = await _dio.put('/diet-notes/$id', data: {'type': type, 'note': note});
    return DietNote.fromJson(res.data);
  }

  Future<void> delete(int id) => _dio.delete('/diet-notes/$id');
}
