import 'package:jambar_pay_mobile/ApiService/ApiService.dart';
import 'package:jambar_pay_mobile/TransactionService/TransactionService.dart';
import 'package:jambar_pay_mobile/CompteService/CompteService.dart';
import 'package:jambar_pay_mobile/UserService/UserService.dart';

/// Simple application injector. Keeps singletons of services using the same
/// ApiService instance so that `setToken` is effective globally.
class Injector {
  Injector._();

  static final ApiService apiService = ApiService();

  static final UserService userService = UserService(apiService: apiService);
  static final TransactionService transactionService =
      TransactionService(apiService: apiService);
  static final CompteService compteService =
      CompteService(apiService: apiService);
}

// Convenience getters
ApiService get apiService => Injector.apiService;
UserService get userService => Injector.userService;
TransactionService get transactionService => Injector.transactionService;
CompteService get compteService => Injector.compteService;
