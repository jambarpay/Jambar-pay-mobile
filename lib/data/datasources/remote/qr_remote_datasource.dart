import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';

class QrRemoteDataSource {
  const QrRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> generateEmployeeQr(String userId) async {
    final response = await _apiService.post(BaseUrl.employeeQr(), {
      'userId': userId,
    });
    if (response is! Map) {
      throw const ApiException('Format de QR employé invalide.');
    }
    return Map<String, dynamic>.from(response);
  }
}
