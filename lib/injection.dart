import 'package:get_it/get_it.dart';
import 'core/network/api_service.dart';
import 'core/network/base_url.dart';
import 'core/network/mock_api_service.dart';
import 'core/config/app_environment.dart';
import 'core/storage/secure_session_storage.dart';
import 'core/session/current_user_session.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/remote/transaction_remote_datasource.dart';
import 'data/datasources/remote/wallet_remote_datasource.dart';
import 'data/datasources/remote/restaurant_remote_datasource.dart';
import 'data/datasources/remote/qr_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'data/services/kkiapay_checkout_service.dart';
import 'data/repositories/restaurant_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/wallet_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/repositories/restaurant_repository.dart';
import 'domain/use_cases/auth/send_otp.dart';
import 'domain/use_cases/auth/verify_otp.dart';
import 'domain/use_cases/auth/login_with_pin.dart';
import 'domain/use_cases/auth/change_pin.dart';
import 'domain/use_cases/auth/logout.dart';
import 'domain/use_cases/auth/reset_pin.dart';
import 'domain/use_cases/transactions/get_transactions.dart';
import 'domain/use_cases/transactions/filter_transactions.dart';
import 'domain/use_cases/transactions/get_transaction_by_id.dart';
import 'domain/use_cases/payment/initiate_payment.dart';
import 'domain/use_cases/payment/confirm_payment.dart';
import 'domain/use_cases/wallet/get_wallet.dart';
import 'domain/use_cases/wallet/refresh_wallet.dart';
import 'domain/use_cases/restaurants/get_restaurants.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_message_provider.dart';
import 'presentation/bloc/auth/localized_auth_message_provider.dart';
import 'presentation/bloc/transactions/transaction_bloc.dart';
import 'presentation/bloc/payment/payment_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';
import 'presentation/bloc/restaurants/restaurant_bloc.dart';

final GetIt sl = GetIt.instance;

const _userApi = 'user-api';
const _restaurantApi = 'restaurant-api';
const _paymentApi = 'payment-api';
const _walletApi = 'wallet-api';
const _qrApi = 'qr-api';

Future<void> init({bool? useMockApi, bool? useLocalAuth}) async {
  await sl.reset();

  const configuredMockApi = AppEnvironment.useMockApi;
  const configuredLocalAuth = AppEnvironment.useLocalAuth;
  final shouldUseMockApi = useMockApi ?? configuredMockApi;
  final shouldUseLocalAuth =
      useLocalAuth ?? (shouldUseMockApi || configuredLocalAuth);
  final sessionStorage = SecureSessionStorage();
  final persistedAccessToken = shouldUseMockApi
      ? null
      : await sessionStorage.readAccessToken();
  final rememberedPhone = shouldUseMockApi
      ? null
      : await sessionStorage.readRememberedPhone();

  sl.registerSingleton<SecureSessionStorage>(sessionStorage);
  sl.registerSingleton<CurrentUserSession>(CurrentUserSession());

  sl.registerLazySingleton<ApiService>(
    () => shouldUseMockApi
        ? MockApiService()
        : ApiService(
            baseUrl: BaseUrl.userServiceBase,
            token: persistedAccessToken,
          ),
    instanceName: _userApi,
    dispose: (service) => service.dispose(),
  );
  sl.registerLazySingleton<ApiService>(
    () => shouldUseMockApi
        ? MockApiService()
        : ApiService(
            baseUrl: BaseUrl.restaurantServiceBase,
            token: persistedAccessToken,
          ),
    instanceName: _restaurantApi,
    dispose: (service) => service.dispose(),
  );
  sl.registerLazySingleton<ApiService>(
    () => shouldUseMockApi
        ? MockApiService()
        : ApiService(
            baseUrl: BaseUrl.paymentServiceBase,
            token: persistedAccessToken,
          ),
    instanceName: _paymentApi,
    dispose: (service) => service.dispose(),
  );
  sl.registerLazySingleton<ApiService>(
    () => shouldUseMockApi
        ? MockApiService()
        : ApiService(
            baseUrl: BaseUrl.walletServiceBase,
            token: persistedAccessToken,
          ),
    instanceName: _walletApi,
    dispose: (service) => service.dispose(),
  );
  sl.registerLazySingleton<ApiService>(
    () => shouldUseMockApi
        ? MockApiService()
        : ApiService(
            baseUrl: BaseUrl.qrServiceBase,
            token: persistedAccessToken,
          ),
    instanceName: _qrApi,
    dispose: (service) => service.dispose(),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      sl<ApiService>(instanceName: _userApi),
      sl<SecureSessionStorage>(),
      authenticatedClients: [
        sl<ApiService>(instanceName: _restaurantApi),
        sl<ApiService>(instanceName: _paymentApi),
        sl<ApiService>(instanceName: _walletApi),
        sl<ApiService>(instanceName: _qrApi),
      ],
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSource());
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () =>
        TransactionRemoteDataSource(sl<ApiService>(instanceName: _paymentApi)),
  );
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSource(
      sl<ApiService>(instanceName: _walletApi),
      sl<CurrentUserSession>(),
    ),
  );
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSource(
      sl<ApiService>(instanceName: _restaurantApi),
    ),
  );
  sl.registerLazySingleton<QrRemoteDataSource>(
    () => QrRemoteDataSource(sl<ApiService>(instanceName: _qrApi)),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
      useLocalAuth: shouldUseLocalAuth,
      currentUserSession: sl<CurrentUserSession>(),
      sessionStorage: shouldUseMockApi ? null : sl<SecureSessionStorage>(),
    ),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<TransactionRemoteDataSource>()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<WalletRemoteDataSource>()),
  );
  sl.registerLazySingleton<KkiapayCheckoutService>(
    () => KkiapayCheckoutService(sl<ApiService>(instanceName: _paymentApi)),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      sl<ApiService>(instanceName: _paymentApi),
      currentUserSession: sl<CurrentUserSession>(),
    ),
  );
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(sl<RestaurantRemoteDataSource>()),
  );

  sl.registerFactory(() => SendOtp(sl<AuthRepository>()));
  sl.registerFactory(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerFactory(() => LoginWithPin(sl<AuthRepository>()));
  sl.registerFactory(() => ChangePin(sl<AuthRepository>()));
  sl.registerFactory(() => ResetPin(sl<AuthRepository>()));
  sl.registerFactory(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton<AuthMessageProvider>(
    () => LocalizedAuthMessageProvider(),
  );

  sl.registerLazySingleton(() => GetTransactions(sl<TransactionRepository>()));
  sl.registerLazySingleton(() => const FilterTransactions());
  sl.registerLazySingleton(
    () => GetTransactionById(sl<TransactionRepository>()),
  );

  sl.registerLazySingleton(() => InitiatePayment(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => ConfirmPayment(sl<PaymentRepository>()));

  sl.registerLazySingleton(() => GetWallet(sl<WalletRepository>()));
  sl.registerLazySingleton(() => RefreshWallet(sl<WalletRepository>()));
  sl.registerLazySingleton(() => GetRestaurants(sl<RestaurantRepository>()));

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sendOtp: sl<SendOtp>(),
      verifyOtp: sl<VerifyOtp>(),
      loginWithPin: sl<LoginWithPin>(),
      logout: sl<Logout>(),
      resetPin: sl<ResetPin>(),
      messages: sl<AuthMessageProvider>(),
      initialPhone: rememberedPhone,
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
      initiatePayment: sl<InitiatePayment>(),
      confirmPayment: sl<ConfirmPayment>(),
    ),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(changePin: sl<ChangePin>(), logout: sl<Logout>()),
  );
  sl.registerFactory<WalletBloc>(
    () => WalletBloc(
      getWallet: sl<GetWallet>(),
      refreshWallet: sl<RefreshWallet>(),
    ),
  );
  sl.registerFactory<RestaurantBloc>(
    () => RestaurantBloc(getRestaurants: sl<GetRestaurants>()),
  );
}
