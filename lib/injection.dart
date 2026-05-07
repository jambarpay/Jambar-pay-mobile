import 'package:get_it/get_it.dart';
import '../ApiService/ApiService.dart';
import '../di.dart' as di;
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/remote/transaction_remote_datasource.dart';
import 'data/datasources/remote/wallet_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/wallet_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/use_cases/auth/send_otp.dart';
import 'domain/use_cases/auth/verify_otp.dart';
import 'domain/use_cases/auth/change_pin.dart';
import 'domain/use_cases/transactions/get_transactions.dart';
import 'domain/use_cases/transactions/filter_transactions.dart';
import 'domain/use_cases/transactions/get_transaction_by_id.dart';
import 'domain/use_cases/payment/initiate_payment.dart';
import 'domain/use_cases/payment/confirm_payment.dart';
import 'domain/use_cases/wallet/get_wallet.dart';
import 'domain/use_cases/wallet/refresh_wallet.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/transactions/transaction_bloc.dart';
import 'presentation/bloc/payment/payment_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';

final GetIt sl = GetIt.instance;

void init() {
  if (sl.isRegistered<ApiService>()) {
    return;
  }
  
  // Detect local auth mode from dart-define
  const useLocalAuth = String.fromEnvironment('USE_LOCAL_AUTH') == 'true';
  print('🔧 [Injection] Initializing with useLocalAuth=$useLocalAuth');
  
  sl.registerLazySingleton<ApiService>(
    () => di.apiService,
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiService>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(),
  );
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSource(sl<ApiService>()),
  );
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSource(sl<ApiService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
      useLocalAuth: useLocalAuth,
    ),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<TransactionRemoteDataSource>()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<WalletRemoteDataSource>()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(),
  );

  sl.registerFactory(() => SendOtp(sl<AuthRepository>()));
  sl.registerFactory(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerFactory(() => ChangePin());

  sl.registerLazySingleton(() => GetTransactions(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => FilterTransactions(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => GetTransactionById(sl<TransactionRepository>()));

  sl.registerLazySingleton(() => InitiatePayment(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => ConfirmPayment(sl<PaymentRepository>()));

  sl.registerLazySingleton(() => GetWallet(sl<WalletRepository>()));
  sl.registerLazySingleton(() => RefreshWallet(sl<WalletRepository>()));

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sendOtp: sl<SendOtp>(),
      verifyOtp: sl<VerifyOtp>(),
      changePin: sl<ChangePin>(),
    ),
  );
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      getTransactions: sl<GetTransactions>(),
      filterTransactions: sl<FilterTransactions>(),
    ),
  );
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      confirmPayment: sl<ConfirmPayment>(),
    ),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      changePin: sl<ChangePin>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
}
