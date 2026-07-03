import '../models/progress_metric.dart';
import 'api_client.dart';

class ProgressMetricService {
  final _dio = ApiClient().dio;

  Future<List<ProgressMetric>> listByStudent(int studentId) async {
    final res = await _dio.get('/progress-metrics', queryParameters: {'student_id': studentId});
    return (res.data as List).map((e) => ProgressMetric.fromJson(e)).toList();
  }

  Future<ProgressMetric> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/progress-metrics', data: data);
    return ProgressMetric.fromJson(res.data);
  }

  Future<void> delete(int id) => _dio.delete('/progress-metrics/$id');
}
