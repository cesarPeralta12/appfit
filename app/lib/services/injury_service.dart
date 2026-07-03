import 'api_client.dart';

class InjuryService {
  final _dio = ApiClient().dio;

  Future<List<Map<String, dynamic>>> listByStudent(int studentId) async {
    final res = await _dio.get('/injuries', queryParameters: {'student_id': studentId});
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(int studentId, Map<String, dynamic> data) async {
    final res = await _dio.post('/injuries', data: {'student_id': studentId, ...data});
    return res.data;
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/injuries/$id', data: data);
    return res.data;
  }

  Future<void> delete(int id) => _dio.delete('/injuries/$id');
}
