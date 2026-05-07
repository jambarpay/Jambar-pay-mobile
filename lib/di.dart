import 'package:jambar_pay_mobile/ApiService/ApiService.dart';
import 'package:jambar_pay_mobile/ApiService/MockApiService.dart';

const bool USE_MOCK_API = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

class Injector {
  Injector._();

  static final ApiService apiService = USE_MOCK_API ? MockApiService() : ApiService();
}

ApiService get apiService => Injector.apiService;
