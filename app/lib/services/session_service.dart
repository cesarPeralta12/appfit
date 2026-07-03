import '../models/training_session.dart';
import 'api_client.dart';

class SessionService {
  final _dio = ApiClient().dio;

  Future<List<TrainingSession>> list({int? studentId, String? status}) async {
    final res = await _dio.get('/training-sessions', queryParameters: {
      if (studentId != null) 'student_id': studentId,
      if (status != null) 'status': status,
    });
    return (res.data as List).map((e) => TrainingSession.fromJson(e)).toList();
  }

  Future<TrainingSession> show(int id) async {
    final res = await _dio.get('/training-sessions/$id');
    return TrainingSession.fromJson(res.data);
  }

  Future<TrainingSession> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/training-sessions', data: data);
    return TrainingSession.fromJson(res.data);
  }

  Future<void> start(int id) => _dio.post('/training-sessions/$id/start');

  Future<void> finish(int id) => _dio.post('/training-sessions/$id/finish');

  Future<Map<String, dynamic>> logSet(int sessionExerciseId, Map<String, dynamic> data) async {
    final res = await _dio.post('/session-exercises/$sessionExerciseId/logs', data: data);
    return res.data;
  }
}
