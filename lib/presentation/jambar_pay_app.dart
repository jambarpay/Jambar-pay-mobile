import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/design_system/theme/app_theme.dart';
import 'package:jambar_pay_mobile/design_system/theme/theme_controller.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/language_controller.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_state.dart';
import 'screens/login_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/home_screen.dart';
import 'models/mobile_employee_space.dart';

class JambarPayApp extends StatefulWidget {
  const JambarPayApp({super.key});

  @override
  State<JambarPayApp> createState() => _JambarPayAppState();
}

class _JambarPayAppState extends State<JambarPayApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageController.localeNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,
          builder: (context, themeMode, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: AppLocalizations(locale).appTitle,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                if (deviceLocale == null) return supportedLocales.first;
                for (final supported in supportedLocales) {
                  if (supported.languageCode == deviceLocale.languageCode) {
                    return supported;
                  }
                }
                return supportedLocales.first;
              },
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}

class JambarPayFlow extends StatelessWidget {
  const JambarPayFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthPhoneInitial) {
          return _buildLoginScreen(context, state.phoneNumber);
        } else if (state is AuthPhoneInvalid) {
          return _buildLoginScreen(
            context,
            state.phoneNumber,
            errorText: state.errorMessage,
          );
        } else if (state is AuthPhoneValid) {
          return _buildLoginScreen(context, state.formattedPhone);
        } else if (state is AuthPhoneLoading) {
          return _buildPinScreen(
            context,
            state.phoneNumber,
            totalDigits: 6,
            title: 'Code OTP',
            subtitle: 'Saisissez le code OTP à 6 chiffres',
          );
        } else if (state is AuthPinEntry) {
          return _buildPinScreen(
            context,
            state.phoneNumber,
            state.currentPin,
            totalDigits: 6,
            title: 'Code OTP',
            subtitle: 'Saisissez le code OTP à 6 chiffres',
          );
        } else if (state is AuthPinSetupEntry) {
          return _buildPinScreen(
            context,
            state.phoneNumber,
            state.pin,
            totalDigits: 4,
            title: 'Créer votre code PIN',
            subtitle: 'Choisissez un code PIN à 4 chiffres',
          );
        } else if (state is AuthPinSetupConfirmation) {
          return _buildPinScreen(
            context,
            state.phoneNumber,
            state.confirmation,
            state.errorMessage,
            totalDigits: 4,
            title: 'Confirmer votre code PIN',
            subtitle: 'Saisissez à nouveau votre code PIN',
          );
        } else if (state is AuthPinLoading) {
          return _buildPinScreen(context, state.phoneNumber, '', totalDigits: 4);
        } else if (state is AuthPinResetInProgress) {
          return _buildPinScreen(context, state.phoneNumber, '', totalDigits: 4);
        } else if (state is AuthPinResetSuccess) {
          return _buildPinScreen(context, state.phoneNumber, '', totalDigits: 4);
        } else if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
          return _buildHomeScreen(context, state.user);
        } else if (state is AuthFailure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            if (state.phoneNumber.isEmpty) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }
          });
          if (state.phoneNumber.isNotEmpty) {
            return _buildPinScreen(
              context,
              state.phoneNumber,
              '',
              state.errorMessage,
              state.pinLockedUntil,
              totalDigits: 6,
              title: 'Code OTP',
              subtitle: 'Saisissez le code OTP à 6 chiffres',
            );
          }
          return _buildLoginScreen(context, '');
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildLoginScreen(
    BuildContext context,
    String phoneNumber, {
    String? errorText,
  }) {
    return LoginScreen(
      phoneNumber: phoneNumber,
      errorText: errorText,
      onContinue: () {
        context.read<AuthBloc>().add(const PhoneNumberSubmitted());
      },
      onBackspace: () {
        context.read<AuthBloc>().add(const PhoneNumberBackspace());
      },
      onDigitTap: (digit) {
        context.read<AuthBloc>().add(PhoneNumberChanged(digit));
      },
      canContinue: PhoneNumber(phoneNumber).isValid,
    );
  }

  Widget _buildPinScreen(
    BuildContext context,
    String phoneNumber, [
    String pin = '',
    String? errorText,
    DateTime? pinLockedUntil,
  ], {
    int totalDigits = 4,
    String? title,
    String? subtitle,
  }) {
    return PinScreen(
      pin: pin,
      phoneNumber: phoneNumber,
      onBack: () {
        context.read<AuthBloc>().add(const BackToPhoneRequested());
      },
      onBackspace: () {
        context.read<AuthBloc>().add(const PinBackspace());
      },
      onDigitTap: (digit) {
        context.read<AuthBloc>().add(PinChanged(digit));
      },
      errorText: errorText,
      pinLockedUntil: pinLockedUntil,
      totalDigits: totalDigits,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildHomeScreen(BuildContext context, User user) {
    return HomeShell(user: user);
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.user});

  final User user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  late bool _isDarkMode;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _isDarkMode = ThemeController.themeMode.value == ThemeMode.dark;
    _appState = AppState(
      userProfile: UserProfileModel(
        id: widget.user.id,
        name: widget.user.name,
        phone: widget.user.phone.value,
        avatarUrl: widget.user.avatarUrl,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(const TransactionsLoadRequested());
      context.read<WalletBloc>().add(const WalletLoadRequested());
      context.read<RestaurantBloc>().add(const RestaurantsLoadRequested());
    });
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _onDarkModeChanged(bool value) {
    ThemeController.setDarkMode(value);
    setState(() => _isDarkMode = value);
  }

  void _onLogout() {
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        final wallet = walletState is WalletLoaded
            ? WalletSummaryModel(
                walletId: walletState.wallet.walletId,
                balance: MoneyModel(
                  amount: walletState.wallet.balance.amount.toDouble(),
                  currency: walletState.wallet.balance.currency,
                  formatted: walletState.wallet.balance.formatted,
                  symbol: 'F',
                ),
                status: walletState.wallet.status.name,
                lastUpdated: _formatWalletDate(walletState.wallet.lastUpdated),
              )
            : null;

        return HomeScreen(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          isDarkMode: _isDarkMode,
          onDarkModeChanged: _onDarkModeChanged,
          appState: _appState.copyWith(
            wallet: wallet,
            clearWallet: wallet == null,
          ),
          onLogout: _onLogout,
        );
      },
    );
  }

  String _formatWalletDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}, ${hour}h$minute';
  }
}
