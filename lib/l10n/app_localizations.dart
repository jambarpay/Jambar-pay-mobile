import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'No AppLocalizations found in context');
    return localizations!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'appTitle': 'Jambar Pay Mobile',
      'chooseLanguage': 'Choisir la langue',
      'french': 'Français',
      'english': 'Anglais',
      'languageChangedFrench': 'Langue changée : Français',
      'languageChangedEnglish': 'Langue changée : Anglais',
      'contactSupport': 'Contacter le support',
      'email': 'Email : support@jambarpay.com',
      'phone': 'Téléphone : +221 33 123 45 67',
      'ok': 'OK',
      'secretCodeChanged': 'Code secret modifié avec succès.',
      'logout': 'Déconnexion',
      'logoutConfirm': 'Voulez-vous vraiment vous déconnecter ?',
      'cancel': 'Annuler',
      'logoutButton': 'Déconnexion',
      'darkMode': 'Sombre',
      'lightMode': 'Clair',
      'changeSecretCode': 'Modifiez votre code secret',
      'back': 'Retour',
      'home': 'Accueil',
      'history': 'Historique',
      'restaurants': 'Restaurants',
      'profile': 'Profil',
      'accountPage': 'Page du compte',
      'enterAmountToPay': 'Veuillez entrer le montant à payer',
      'availableBalanceTitle': 'Solde disponible',
      'availableBalance': 'Solde disponible : {amount}',
      'amount': 'Montant',
      'pay': 'Payer',
      'invalidAmount': 'Veuillez saisir un montant valide.',
      'insufficientBalance': 'Solde insuffisant pour ce paiement.',
      'paymentSuccess': 'Paiement réussi',
      'paymentSuccessBody': 'Votre paiement de {amount} chez {merchantName} a été confirmé.',
      'finish': 'Terminer',
      'retry': 'Réessayer',
      'noTransactionsAvailable': 'Aucune transaction disponible.',
      'noTransactionsMatchSearch': 'Aucune transaction ne correspond à votre recherche.',
      'filterAll': 'Tous',
      'filterToday': "Aujourd'hui",
      'filterThisWeek': 'Cette semaine',
      'filterThisMonth': 'Ce mois',
      'searchTransactions': 'Rechercher une transaction ou un commerce',
      'statusPending': 'En attente',
      'statusValidated': 'Validé',
      'statusFailed': 'Échoué',
      'dateToday': 'Aujourd\'hui',
      'dateYesterday': 'Hier',
      'recentTransactions': 'Transaction Récentes',
      'viewAll': 'Voir tout',
      'map': 'Carte',
      'list': 'Liste',
      'restaurantsNearby': '{count} restaurants près de vous',
      'paymentSuccessMessage': 'Paiement réussi chez {merchantName}.',
      'partnerRestaurant': 'Restaurant partenaire',
      'currentSecretCode': 'Code secret actuel',
      'newSecretCode': 'Nouveau code secret',
      'confirmation': 'Confirmation',
      'enterYourCurrentCode': 'Entrez votre code actuel pour continuer.',
      'chooseNewSecretCode': 'Choisissez un code secret à 4 chiffres.',
      'enterNewSecretCodeAgain': 'Saisissez à nouveau le nouveau code secret.',
      'setYourNewSecretCode': 'Choisissez votre nouveau code secret à 4 chiffres.',
      'enterCodeAgain': 'Saisissez à nouveau le code secret pour valider.',
      'codeMismatch': 'Les deux codes ne correspondent pas.',
      'current': 'Actuel',
      'new': 'Nouveau',
      'confirmationShort': 'Confirmation',
      'pinCode': 'Code PIN',
      'enterYourPinCode': 'Entrez votre code PIN',
      'retryIn': 'Nouvel essai dans {duration}',
      'secretCodeResetSuccess': 'Code secret réinitialisé avec succès.',
      'forgotPin': 'Code PIN oublié ?',
      'testQr': 'Tester QR 1234',
      'loginTitle': 'Connexion',
      'continueLabel': 'Continuer',
      'enterPhoneNumber': 'Entrez votre numero de telephone',
      'phoneNumberLabel': 'Numero de telephone',
      'resetSecretCode': 'Reinitialiser le code secret',
      'accountForPhone': 'Compte {phone}',
      'confirmCode': 'Confirmez le code',
      'scan': 'Scanner',
      'myQr': 'Mon QR',
      'invalidQrCode': 'Code QR invalide.',
      'transactionCount': '{count} transaction(s)',
      'progressiveLoadingActive': 'Chargement progressif actif',
      'searchRestaurant': 'rechercher un restaurant',
      'open': 'Ouvert',
      'closed': 'Ferme',
      'walletUnavailable': 'Portefeuille indisponible',
      'scanQrCode': 'Scannez un code QR',
      'qrDetected': 'QR détecté: {value}',
      'employeeQr': 'QR employe',
      'activeEmployeeQr': 'QR employe actif',
      'readyForScan': 'Pret pour le scan et la confirmation du paiement.',
      'phoneAuthorizedOnly': 'Numero autorise uniquement: 77 123 45 67',
      'phoneTooLong': 'Numero trop long',
      'invalidPhoneNumber': 'Numero de telephone invalide',
      'incorrectSecretCode': 'Code secret incorrect. Il vous reste {count} {attemptLabel}.',
      'youCanRetryNow': 'Vous pouvez réessayer maintenant.',
      'validated': 'Valide',
      'active': 'Actif',
      'todayAt': "Aujourd'hui, {time}",
      'yesterdayAt': 'Hier, {time}',
      'dateTime': '{date}, {time}',
      'paymentConfirmed': 'Paiement confirme',
      'paymentConfirmedBody': 'Votre paiement chez {merchant} a ete confirme.',
      'balanceUpdated': 'Solde mis a jour',
      'walletSynced': 'Votre portefeuille a ete synchronise avec succes.',
    },
    'en': {
      'appTitle': 'Jambar Pay Mobile',
      'chooseLanguage': 'Choose language',
      'french': 'French',
      'english': 'English',
      'languageChangedFrench': 'Language changed: French',
      'languageChangedEnglish': 'Language changed: English',
      'contactSupport': 'Contact support',
      'email': 'Email: support@jambarpay.com',
      'phone': 'Phone: +221 33 123 45 67',
      'ok': 'OK',
      'secretCodeChanged': 'Secret code changed successfully.',
      'logout': 'Logout',
      'logoutConfirm': 'Do you really want to log out?',
      'cancel': 'Cancel',
      'logoutButton': 'Logout',
      'darkMode': 'Dark',
      'lightMode': 'Light',
      'changeSecretCode': 'Change your secret code',
      'back': 'Back',
      'home': 'Home',
      'history': 'History',
      'restaurants': 'Restaurants',
      'profile': 'Profile',
      'accountPage': 'Account Page',
      'enterAmountToPay': 'Please enter the amount to pay',
      'availableBalanceTitle': 'Available balance',
      'availableBalance': 'Available balance: {amount}',
      'amount': 'Amount',
      'pay': 'Pay',
      'invalidAmount': 'Please enter a valid amount.',
      'insufficientBalance': 'Insufficient balance for this payment.',
      'paymentSuccess': 'Payment successful',
      'paymentSuccessBody': 'Your payment of {amount} at {merchantName} has been confirmed.',
      'finish': 'Finish',
      'retry': 'Retry',
      'noTransactionsAvailable': 'No transactions available.',
      'noTransactionsMatchSearch': 'No transactions match your search.',
      'filterAll': 'All',
      'filterToday': 'Today',
      'filterThisWeek': 'This week',
      'filterThisMonth': 'This month',
      'searchTransactions': 'Search for a transaction or merchant',
      'statusPending': 'Pending',
      'statusValidated': 'Validated',
      'statusFailed': 'Failed',
      'dateToday': 'Today',
      'dateYesterday': 'Yesterday',
      'recentTransactions': 'Recent Transactions',
      'viewAll': 'View All',
      'map': 'Map',
      'list': 'List',
      'restaurantsNearby': '{count} restaurants near you',
      'paymentSuccessMessage': 'Payment successful at {merchantName}.',
      'partnerRestaurant': 'Partner Restaurant',
      'currentSecretCode': 'Current secret code',
      'newSecretCode': 'New secret code',
      'confirmation': 'Confirmation',
      'enterYourCurrentCode': 'Enter your current code to continue.',
      'chooseNewSecretCode': 'Choose a 4-digit secret code.',
      'enterNewSecretCodeAgain': 'Re-enter the new secret code.',
      'setYourNewSecretCode': 'Choose your new 4-digit secret code.',
      'enterCodeAgain': 'Re-enter the secret code to confirm.',
      'codeMismatch': 'The two codes do not match.',
      'current': 'Current',
      'new': 'New',
      'confirmationShort': 'Confirmation',
      'pinCode': 'PIN Code',
      'enterYourPinCode': 'Enter your PIN code',
      'retryIn': 'Retry in {duration}',
      'secretCodeResetSuccess': 'Secret code reset successfully.',
      'forgotPin': 'Forgot PIN?',
      'testQr': 'Test QR 1234',
      'loginTitle': 'Login',
      'continueLabel': 'Continue',
      'enterPhoneNumber': 'Enter your phone number',
      'phoneNumberLabel': 'Phone number',
      'resetSecretCode': 'Reset secret code',
      'accountForPhone': 'Account {phone}',
      'confirmCode': 'Confirm code',
      'scan': 'Scan',
      'myQr': 'My QR',
      'invalidQrCode': 'Invalid QR code.',
      'transactionCount': '{count} transaction(s)',
      'progressiveLoadingActive': 'Progressive loading active',
      'searchRestaurant': 'search for a restaurant',
      'open': 'Open',
      'closed': 'Closed',
      'walletUnavailable': 'Wallet unavailable',
      'scanQrCode': 'Scan a QR code',
      'qrDetected': 'QR detected: {value}',
      'employeeQr': 'Employee QR',
      'activeEmployeeQr': 'Active employee QR',
      'readyForScan': 'Ready for scan and payment confirmation.',
      'phoneAuthorizedOnly': 'Only authorized number: 77 123 45 67',
      'phoneTooLong': 'Phone number too long',
      'invalidPhoneNumber': 'Invalid phone number',
      'incorrectSecretCode': 'Incorrect secret code. {count} {attemptLabel} remaining.',
      'youCanRetryNow': 'You can retry now.',
      'validated': 'Validated',
      'active': 'Active',
      'todayAt': 'Today, {time}',
      'yesterdayAt': 'Yesterday, {time}',
      'dateTime': '{date}, {time}',
      'paymentConfirmed': 'Payment confirmed',
      'paymentConfirmedBody': 'Your payment at {merchant} has been confirmed.',
      'balanceUpdated': 'Balance updated',
      'walletSynced': 'Your wallet has been synced successfully.',
    },
  };

  String _translate(String key) {
    final localeMap = _translations[locale.languageCode] ?? _translations['en']!;
    return localeMap[key] ?? _translations['en']![key]!;
  }

  String _translateWithArgs(String key, Map<String, String> args) {
    var value = _translate(key);
    for (final arg in args.entries) {
      value = value.replaceAll('{${arg.key}}', arg.value);
    }
    return value;
  }

  String get appTitle => _translate('appTitle');
  String get chooseLanguage => _translate('chooseLanguage');
  String get french => _translate('french');
  String get english => _translate('english');
  String get languageChangedFrench => _translate('languageChangedFrench');
  String get languageChangedEnglish => _translate('languageChangedEnglish');
  String get contactSupport => _translate('contactSupport');
  String get email => _translate('email');
  String get phone => _translate('phone');
  String get ok => _translate('ok');
  String get secretCodeChanged => _translate('secretCodeChanged');
  String get logout => _translate('logout');
  String get logoutConfirm => _translate('logoutConfirm');
  String get cancel => _translate('cancel');
  String get logoutButton => _translate('logoutButton');
  String get darkMode => _translate('darkMode');
  String get lightMode => _translate('lightMode');
  String get changeSecretCode => _translate('changeSecretCode');
  String get back => _translate('back');
  String get home => _translate('home');
  String get history => _translate('history');
  String get restaurants => _translate('restaurants');
  String get profile => _translate('profile');
  String get accountPage => _translate('accountPage');
  String get enterAmountToPay => _translate('enterAmountToPay');
  String get availableBalanceTitle => _translate('availableBalanceTitle');
  String availableBalance(String amount) => _translateWithArgs('availableBalance', {'amount': amount});
  String get amount => _translate('amount');
  String get pay => _translate('pay');
  String get invalidAmount => _translate('invalidAmount');
  String get insufficientBalance => _translate('insufficientBalance');
  String get paymentSuccess => _translate('paymentSuccess');
  String paymentSuccessBody(String amount, String merchantName) => _translateWithArgs('paymentSuccessBody', {'amount': amount, 'merchantName': merchantName});
  String get finish => _translate('finish');
  String get retry => _translate('retry');
  String get noTransactionsAvailable => _translate('noTransactionsAvailable');
  String get noTransactionsMatchSearch => _translate('noTransactionsMatchSearch');
  String get filterAll => _translate('filterAll');
  String get filterToday => _translate('filterToday');
  String get filterThisWeek => _translate('filterThisWeek');
  String get filterThisMonth => _translate('filterThisMonth');
  String get searchTransactions => _translate('searchTransactions');
  String get statusPending => _translate('statusPending');
  String get statusValidated => _translate('statusValidated');
  String get statusFailed => _translate('statusFailed');
  String get dateToday => _translate('dateToday');
  String get dateYesterday => _translate('dateYesterday');
  String get recentTransactions => _translate('recentTransactions');
  String get viewAll => _translate('viewAll');
  String get map => _translate('map');
  String get list => _translate('list');
  String restaurantsNearby(String count) => _translateWithArgs('restaurantsNearby', {'count': count});
  String paymentSuccessMessage(String merchantName) => _translateWithArgs('paymentSuccessMessage', {'merchantName': merchantName});
  String get partnerRestaurant => _translate('partnerRestaurant');
  String get currentSecretCode => _translate('currentSecretCode');
  String get newSecretCode => _translate('newSecretCode');
  String get confirmation => _translate('confirmation');
  String get enterYourCurrentCode => _translate('enterYourCurrentCode');
  String get chooseNewSecretCode => _translate('chooseNewSecretCode');
  String get enterNewSecretCodeAgain => _translate('enterNewSecretCodeAgain');
  String get setYourNewSecretCode => _translate('setYourNewSecretCode');
  String get enterCodeAgain => _translate('enterCodeAgain');
  String get codeMismatch => _translate('codeMismatch');
  String get current => _translate('current');
  String get newLabel => _translate('new');
  String get confirmationShort => _translate('confirmationShort');
  String get pinCode => _translate('pinCode');
  String get enterYourPinCode => _translate('enterYourPinCode');
  String retryIn(String duration) => _translateWithArgs('retryIn', {'duration': duration});
  String get secretCodeResetSuccess => _translate('secretCodeResetSuccess');
  String get forgotPin => _translate('forgotPin');
  String get testQr => _translate('testQr');
  String get loginTitle => _translate('loginTitle');
  String get continueLabel => _translate('continueLabel');
  String get enterPhoneNumber => _translate('enterPhoneNumber');
  String get phoneNumberLabel => _translate('phoneNumberLabel');
  String get resetSecretCode => _translate('resetSecretCode');
  String accountForPhone(String phone) => _translateWithArgs('accountForPhone', {'phone': phone});
  String get confirmCode => _translate('confirmCode');
  String get scan => _translate('scan');
  String get myQr => _translate('myQr');
  String get invalidQrCode => _translate('invalidQrCode');
  String transactionCount(String count) => _translateWithArgs('transactionCount', {'count': count});
  String get progressiveLoadingActive => _translate('progressiveLoadingActive');
  String get searchRestaurant => _translate('searchRestaurant');
  String get open => _translate('open');
  String get closed => _translate('closed');
  String get walletUnavailable => _translate('walletUnavailable');
  String get scanQrCode => _translate('scanQrCode');
  String qrDetected(String value) => _translateWithArgs('qrDetected', {'value': value});
  String get employeeQr => _translate('employeeQr');
  String get activeEmployeeQr => _translate('activeEmployeeQr');
  String get readyForScan => _translate('readyForScan');
  String get phoneAuthorizedOnly => _translate('phoneAuthorizedOnly');
  String get phoneTooLong => _translate('phoneTooLong');
  String get invalidPhoneNumber => _translate('invalidPhoneNumber');
  String incorrectSecretCode(int count, String attemptLabel) => _translateWithArgs('incorrectSecretCode', {'count': count.toString(), 'attemptLabel': attemptLabel});
  String get youCanRetryNow => _translate('youCanRetryNow');
  String get validated => _translate('validated');
  String get active => _translate('active');
  String todayAt(String time) => _translateWithArgs('todayAt', {'time': time});
  String yesterdayAt(String time) => _translateWithArgs('yesterdayAt', {'time': time});
  String dateTime(String date, String time) => _translateWithArgs('dateTime', {'date': date, 'time': time});
  String get paymentConfirmed => _translate('paymentConfirmed');
  String paymentConfirmedBody(String merchant) => _translateWithArgs('paymentConfirmedBody', {'merchant': merchant});
  String get balanceUpdated => _translate('balanceUpdated');
  String get walletSynced => _translate('walletSynced');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
