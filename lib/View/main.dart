import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'screens/login_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/home_screen.dart';
import 'models/mobile_employee_space.dart';

class JambarPayApp extends StatelessWidget {
  const JambarPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandDark = Color(0xFF1C1A33);
    const brandOrange = Color(0xFFF57C21);
    const brandGreen = Color(0xFF11B777);
    const softBackground = Color(0xFFF6F5FB);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jambar Pay Mobile',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: softBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandOrange,
          brightness: Brightness.light,
        ).copyWith(
          primary: brandOrange,
          secondary: brandGreen,
          surface: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: brandDark,
          displayColor: brandDark,
        ),
      ),
      home: const JambarPayFlow(),
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
          return _buildLoginScreen(context, state.phoneNumber);
        } else if (state is AuthPhoneValid) {
          return _buildLoginScreen(context, state.formattedPhone);
        } else if (state is AuthPhoneLoading) {
          return _buildPinScreen(context, state.phoneNumber);
        } else if (state is AuthPinEntry) {
          return _buildPinScreen(context, state.phoneNumber, state.currentPin);
        } else if (state is AuthPinLoading) {
          return _buildPinScreen(context, state.phoneNumber, '');
        } else if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
          return _buildHomeScreen(context, state.user);
        } else if (state is AuthFailure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
            if (state.phoneNumber.isEmpty) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }
          });
          if (state.phoneNumber.isNotEmpty) {
            return _buildPinScreen(context, state.phoneNumber);
          }
          return _buildLoginScreen(context, '');
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildLoginScreen(BuildContext context, String phoneNumber) {
    return LoginScreen(
      phoneNumber: phoneNumber,
      onContinue: () {
        context.read<AuthBloc>().add(const PhoneNumberSubmitted());
      },
      onBackspace: () {
        context.read<AuthBloc>().add(const PhoneNumberBackspace());
      },
      onDigitTap: (digit) {
        context.read<AuthBloc>().add(PhoneNumberChanged(digit));
      },
      canContinue: phoneNumber.replaceAll(RegExp(r'\s+'), '').length == 9,
    );
  }

  Widget _buildPinScreen(BuildContext context, String phoneNumber, [String pin = '']) {
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
      onResetPin: (newPin) {},
      errorText: null,
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
  bool _isDarkMode = false;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState.employeeDemo().copyWith(
      auth: AppState.employeeDemo().auth.copyWith(
            isAuthenticated: true,
            userId: widget.user.id,
          ),
      userProfile: UserProfileModel(
        id: widget.user.id,
        name: widget.user.name,
        phone: widget.user.phone.value,
        avatarUrl: widget.user.avatarUrl,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<TransactionBloc>().add(const TransactionsLoadRequested());
      } catch (_) {}
    });
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _onDarkModeChanged(bool value) {
    setState(() => _isDarkMode = value);
  }

  String? _onChangeSecretCode(String currentPin, String newPin) {
    return null;
  }

  void _onPaymentCompleted(QRScanResultModel scanResult, PaymentResultModel result) {
    setState(() {
      _appState = _appState.copyWith(
        payment: _appState.payment.copyWith(
          scanResult: scanResult,
          currentPayment: result,
        ),
        transactions: [
          TransactionItemModel(
            id: result.paymentId,
            type: 'DEBIT',
            amount: result.amount,
            label: scanResult.merchantName,
            date: result.date,
            status: 'Valide',
          ),
          ..._appState.transactions,
        ],
      );
      _currentIndex = 0;
    });
  }

  void _onLogout() {
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      currentIndex: _currentIndex,
      onTabSelected: _onTabSelected,
      isDarkMode: _isDarkMode,
      onDarkModeChanged: _onDarkModeChanged,
      appState: _appState,
      onChangeSecretCode: _onChangeSecretCode,
      onPaymentCompleted: _onPaymentCompleted,
      onLogout: _onLogout,
    );
  }
}
