import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'injection.dart' as di;
import 'View/main.dart' as app;

void main() {
  di.init();
  runApp(const JambarPayApp());
}

class JambarPayApp extends StatelessWidget {
  const JambarPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => di.sl<TransactionBloc>(),
        ),
        BlocProvider<PaymentBloc>(
          create: (context) => di.sl<PaymentBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => di.sl<ProfileBloc>(),
        ),
      ],
      child: const app.JambarPayApp(),
    );
  }
}
