import '../models/routine.dart';
import 'api_client.dart';

class RoutineService {
  final _dio = ApiClient().dio;

  Future<List<Routine>> listByStudent(int studentId) async {
    final res = await _dio.get('/routines', queryParameters: {'student_id': studentId});
    return (res.data as List).map((e) => Routine.fromJson(e)).toList();
  }

  Future<Routine> create(int studentId, String name, List<RoutineExercise> exercises) async {
    final res = await _dio.post('/routines', data: {
      'student_id': studentId,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    });
    return Routine.fromJson(res.data);
  }

  Future<Routine> update(int id, String name, List<RoutineExercise> exercises) async {
    final res = await _dio.put('/routines/$id', data: {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    });
    return Routine.fromJson(res.data);
  }

  Future<void> delete(int id) => _dio.delete('/routines/$id');
}
