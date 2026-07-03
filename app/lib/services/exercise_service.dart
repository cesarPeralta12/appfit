import '../models/exercise.dart';
import 'api_client.dart';

class ExerciseService {
  final _dio = ApiClient().dio;

  Future<List<Exercise>> list({String? category, String? search}) async {
    final res = await _dio.get('/exercises', queryParameters: {
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (res.data as List).map((e) => Exercise.fromJson(e)).toList();
  }

  Future<Exercise> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/exercises', data: data);
    return Exercise.fromJson(res.data);
  }

  Future<Exercise> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/exercises/$id', data: data);
    return Exercise.fromJson(res.data);
  }

  Future<void> delete(int id) => _dio.delete('/exercises/$id');
}
