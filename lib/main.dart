import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'injection.dart' as di;
import 'presentation/jambar_pay_app.dart' as app;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const JambarPayApp());
}

class JambarPayApp extends StatelessWidget {
  const JambarPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<TransactionBloc>(
          create: (context) => di.sl<TransactionBloc>(),
        ),
        BlocProvider<PaymentBloc>(create: (context) => di.sl<PaymentBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => di.sl<ProfileBloc>()),
        BlocProvider<WalletBloc>(create: (context) => di.sl<WalletBloc>()),
        BlocProvider<RestaurantBloc>(
          create: (context) => di.sl<RestaurantBloc>(),
        ),
      ],
      child: const app.JambarPayApp(),
    );
  }
}
