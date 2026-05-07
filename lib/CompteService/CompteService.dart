import '../ApiService/ApiService.dart';
import '../di.dart' as di;
import '../ApiService/BaseUrl.dart';
import '../Entity/CompteEntity.dart';

class CompteService {
  final ApiService apiService;

  CompteService({ApiService? apiService})
    : apiService = apiService ?? di.apiService;

  Future<List<CompteEntity>> getComptes() async {
    final response = await apiService.get(BaseUrl.comptes());
    if (response is! List) {
      return [];
    }

    return response
        .map((item) => CompteEntity.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CompteEntity?> getCompteById(String id) async {
    final response = await apiService.get(BaseUrl.comptes(id));
    if (response is! Map) {
      return null;
    }

    return CompteEntity.fromJson(Map<String, dynamic>.from(response));
  }

  Future<CompteEntity?> getCompteByPhone(String phone) async {
    final response = await apiService.get(BaseUrl.comptesByPhone(phone));
    if (response is! Map) {
      return null;
    }

    return CompteEntity.fromJson(Map<String, dynamic>.from(response));
  }

  Future<dynamic> transfert(Map<String, dynamic> data) {
    return apiService.post(BaseUrl.comptesTransfert(), data);
  }

  Future<dynamic> payer(Map<String, dynamic> data) {
    return apiService.post(BaseUrl.comptesPayer(), data);
  }

  Future<dynamic> getSolde() {
    return apiService.get(BaseUrl.comptesSolde());
  }

  Future<dynamic> getDashboard() {
    return apiService.get(BaseUrl.comptesDashboard());
  }
}
