import 'package:dio/dio.dart';
import '../models/student.dart';
import 'api_client.dart';

class StudentService {
  final _dio = ApiClient().dio;

  Future<List<Student>> list({String? search, String? level, String? ageCategory}) async {
    final res = await _dio.get('/students', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (level != null && level.isNotEmpty) 'level': level,
      if (ageCategory != null && ageCategory.isNotEmpty) 'age_category': ageCategory,
    });
    return (res.data as List).map((e) => Student.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> show(int id) async {
    final res = await _dio.get('/students/$id');
    return res.data;
  }

  Future<Student> create(Student s) async {
    final res = await _dio.post('/students', data: s.toJson());
    return Student.fromJson(res.data);
  }

  Future<Student> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/students/$id', data: data);
    return Student.fromJson(res.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/students/$id');
  }

  Future<Student> uploadPhoto(int id, List<int> bytes, String filename) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post('/students/$id/photo', data: formData);
    return Student.fromJson(res.data);
  }
}
