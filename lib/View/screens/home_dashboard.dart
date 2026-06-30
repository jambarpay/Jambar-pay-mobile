import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_state.dart';
import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_widgets.dart';
import '../widgets/transaction_widgets.dart';
import '../screens/qr_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.onTabSelected,
    required this.isDarkMode,
    required this.appState,
    required this.onPaymentCompleted,
  });

  final ValueChanged<int> onTabSelected;
  final bool isDarkMode;
  final AppState appState;
  final void Function(QRScanResultModel, PaymentResultModel) onPaymentCompleted;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 58, 22, 18),
          decoration: BoxDecoration(color: palette.headerBackground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.userProfile.name,
                style: TextStyle(
                  color: palette.primaryText,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              BalanceCard(
                isDarkMode: isDarkMode,
                wallet: appState.wallet,
                onQrTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => QrScreen(
                        onTabSelected: onTabSelected,
                        isDarkMode: isDarkMode,
                        userProfile: appState.userProfile,
                        paymentState: appState.payment,
                        wallet: appState.wallet,
                        onPaymentCompleted: onPaymentCompleted,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: palette.pageBackground,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isDarkMode ? 12 : 0,
                isDarkMode ? 14 : 0,
                isDarkMode ? 12 : 0,
                0,
              ),
              child: Container(
                color: isDarkMode
                    ? palette.sectionContainer
                    : Colors.transparent,
                child: Column(
                  children: [
                    SectionHeader(
                      title: loc.recentTransactions,
                      actionLabel: loc.viewAll,
                      onActionTap: () {
                        final transactionBloc = context.read<TransactionBloc>();
                        final transactionState = transactionBloc.state;

                        if (transactionState is TransactionLoaded) {
                          transactionBloc.add(const SearchCleared());
                          transactionBloc.add(
                            const TransactionsFilterChanged('all'),
                          );
                        } else {
                          transactionBloc.add(
                            const TransactionsLoadRequested(),
                          );
                        }

                        onTabSelected(1);
                      },
                      isDarkMode: isDarkMode,
                    ),
                    Expanded(
                      child: TransactionsList(
                        transactions: appState.transactions.take(6).toList(),
                        showAmount: true,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
