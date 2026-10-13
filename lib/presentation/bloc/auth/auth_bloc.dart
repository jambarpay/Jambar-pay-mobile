import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_service.dart';
import '../../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'auth_message_provider.dart';
import '../../../domain/value_objects/phone_number.dart';
import '../../../domain/use_cases/auth/send_otp.dart';
import '../../../domain/use_cases/auth/start_employee_onboarding.dart';
import '../../../domain/use_cases/auth/verify_otp.dart';
import '../../../domain/use_cases/auth/check_employee_otp.dart';
import '../../../domain/use_cases/auth/login_with_pin.dart';
import '../../../domain/use_cases/auth/logout.dart';
import '../../../domain/use_cases/auth/reset_pin.dart';
import '../../../domain/use_cases/auth/delete_account.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const int _maxPinAttempts = 5;
  static const Duration _pinLockDuration = Duration(minutes: 2);

  final SendOtp _sendOtp;
  final StartEmployeeOnboarding? _startEmployeeOnboarding;
  final VerifyOtp _verifyOtp;
  final CheckEmployeeOtp _checkEmployeeOtp;
  final LoginWithPin _loginWithPin;
  final Logout _logout;
  final ResetPin _resetPin;
  final DeleteAccount? _deleteAccount;
  final AuthMessageProvider _messages;

  String _currentPhone = '';
  String _currentPin = '';
  String _currentOtp = '';
  String _otpCode = '';
  String _setupPin = '';
  bool _settingUpPin = false;
  bool _confirmingSetupPin = false;
  int _otpCheckGeneration = 0;
  int _failedPinAttempts = 0;
  DateTime? _pinLockedUntil;

  AuthBloc({
    required SendOtp sendOtp,
    StartEmployeeOnboarding? startEmployeeOnboarding,
    required VerifyOtp verifyOtp,
    required CheckEmployeeOtp checkEmployeeOtp,
    required LoginWithPin loginWithPin,
    required Logout logout,
    required ResetPin resetPin,
    DeleteAccount? deleteAccount,
    required AuthMessageProvider messages,
    String? initialPhone,
    User? initialUser,
  }) : _sendOtp = sendOtp,
       _startEmployeeOnboarding = startEmployeeOnboarding,
       _verifyOtp = verifyOtp,
       _checkEmployeeOtp = checkEmployeeOtp,
       _loginWithPin = loginWithPin,
       _logout = logout,
       _resetPin = resetPin,
       _deleteAccount = deleteAccount,
       _messages = messages,
       _currentPhone = PhoneNumber(
         initialPhone ?? initialUser?.phone.value ?? '',
       ).digits,
       super(_initialState(initialPhone, initialUser)) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PhoneNumberBackspace>(_onPhoneNumberBackspace);
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<OtpChanged>(_onOtpChanged);
    on<OtpBackspace>(_onOtpBackspace);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<PinChanged>(_onPinChanged);
    on<PinBackspace>(_onPinBackspace);
    on<PinSubmitted>(_onPinSubmitted);
    on<PinResetRequested>(_onPinResetRequested);
    on<BackToPhoneRequested>(_onBackToPhoneRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AppLockRequested>(_onAppLockRequested);
    on<AccountDeletionRequested>(_onAccountDeletionRequested);
  }

  static AuthState _initialState(String? phone, User? user) {
    if (user != null) {
      // A persisted session identifies the employee but never unlocks the
      // interface by itself. The PIN must be entered again after relaunch.
      return AuthPinEntry(user.phone.formatted);
    }
    final rememberedPhone = PhoneNumber(phone ?? '');
    if (rememberedPhone.isValid) {
      return AuthPinEntry(rememberedPhone.formatted);
    }
    return const AuthPhoneInitial();
  }

  Future<void> deleteAccount() {
    final completer = Completer<void>();
    add(AccountDeletionRequested(completer));
    return completer.future;
  }

  Future<void> _onAccountDeletionRequested(
    AccountDeletionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final deleteAccount = _deleteAccount;
    if (deleteAccount == null) {
      event.completer.completeError(
        StateError('La suppression de compte n’est pas configurée.'),
      );
      return;
    }

    try {
      await deleteAccount();
      _resetSensitiveState();
      emit(const AuthPhoneInitial());
      event.completer.complete();
    } catch (error, stackTrace) {
      event.completer.completeError(error, stackTrace);
    }
  }

  void _onAppLockRequested(AppLockRequested event, Emitter<AuthState> emit) {
    final authenticated = state;
    if (authenticated is! AuthAuthenticated) return;

    _currentPhone = authenticated.user.phone.digits;
    _currentPin = '';
    emit(AuthPinEntry(authenticated.user.phone.formatted));
  }

  void _onPhoneNumberChanged(
    PhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    final payload = event.phoneNumber;

    // If a single digit is provided, append it to the current phone
    if (payload.length == 1 && RegExp(r'^\d$').hasMatch(payload)) {
      if (_currentPhone.length < 9) {
        _currentPhone = '$_currentPhone$payload';
      }
    } else if (payload.isEmpty) {
      // reset
      _currentPhone = '';
    } else {
      // full string provided (legacy callers/tests) — replace
      _currentPhone = payload;
    }

    final phone = PhoneNumber(_currentPhone);

    if (phone.digits.length == 9) {
      if (phone.isValid) {
        emit(AuthPhoneValid(phone.formatted));
      } else {
        emit(AuthPhoneInvalid(_messages.invalidPhoneNumber, _currentPhone));
      }
    } else if (phone.digits.length >= 9) {
      emit(AuthPhoneInvalid(_messages.phoneTooLong, _currentPhone));
    } else {
      emit(AuthPhoneInitial(_currentPhone));
    }
  }

  void _onPhoneNumberBackspace(
    PhoneNumberBackspace event,
    Emitter<AuthState> emit,
  ) {
    if (_currentPhone.isNotEmpty) {
      _currentPhone = _currentPhone.substring(0, _currentPhone.length - 1);
      final phone = PhoneNumber(_currentPhone);

      if (phone.digits.length == 9) {
        emit(AuthPhoneValid(phone.formatted));
      } else if (phone.digits.isNotEmpty) {
        emit(AuthPhoneInitial(_currentPhone));
      } else {
        emit(const AuthPhoneInitial());
      }
    }
  }

  Future<void> _onPhoneNumberSubmitted(
    PhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final phone = PhoneNumber(_currentPhone);
    if (!phone.isValid) {
      emit(AuthPhoneInvalid(_messages.invalidPhoneNumber, _currentPhone));
      return;
    }

    _clearPinLockIfExpired();
    if (_isPinLocked) {
      emit(AuthFailure(_pinLockMessage(), phone.formatted, _pinLockedUntil));
      return;
    }

    // A pending employee must verify an OTP before creating the first PIN.
    // Active employees continue directly to normal PIN authentication.
    final startEmployeeOnboarding = _startEmployeeOnboarding;
    if (startEmployeeOnboarding == null) {
      _currentPin = '';
      emit(AuthPinEntry(phone.formatted));
      return;
    }

    emit(AuthPhoneLoading(phone.formatted));
    try {
      final onboardingRequired = await startEmployeeOnboarding(phone);
      if (onboardingRequired) {
        _otpCheckGeneration++;
        _currentOtp = '';
        _otpCode = '';
        _currentPin = '';
        _settingUpPin = false;
        _confirmingSetupPin = false;
        emit(AuthOtpEntry(phone.formatted));
      } else {
        _currentPin = '';
        emit(AuthPinEntry(phone.formatted));
      }
    } on ApiException catch (error) {
      emit(AuthFailure(error.message, phone.formatted));
    } catch (_) {
      emit(AuthFailure(_messages.loginServiceUnavailable, phone.formatted));
    }
  }

  void _onOtpChanged(OtpChanged event, Emitter<AuthState> emit) {
    if (state is! AuthOtpEntry || (state as AuthOtpEntry).isSubmitting) return;
    if (event.otp.isEmpty) return;
    if (!RegExp(r'^\d$').hasMatch(event.otp)) return;
    if (_currentOtp.length >= 6) return;
    _currentOtp += event.otp;
    emit(AuthOtpEntry(_formattedCurrentPhone, _currentOtp));
  }

  void _onOtpBackspace(OtpBackspace event, Emitter<AuthState> emit) {
    if (state is! AuthOtpEntry || (state as AuthOtpEntry).isSubmitting) return;
    if (_currentOtp.isEmpty) return;
    _currentOtp = _currentOtp.substring(0, _currentOtp.length - 1);
    emit(AuthOtpEntry(_formattedCurrentPhone, _currentOtp));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthOtpEntry || (state as AuthOtpEntry).isSubmitting) return;
    if (_currentOtp.length != 6) {
      emit(
        AuthOtpEntry(_formattedCurrentPhone, _currentOtp, 'Code OTP invalide.'),
      );
      return;
    }
    final phone = PhoneNumber(_currentPhone);
    final code = _currentOtp;
    final generation = ++_otpCheckGeneration;
    emit(AuthOtpEntry.checking(phone.formatted, code));
    try {
      await _checkEmployeeOtp(phone: phone, otp: code);
      if (generation != _otpCheckGeneration || state is! AuthOtpEntry) return;
      _otpCode = code;
      _currentPin = '';
      _setupPin = '';
      _settingUpPin = true;
      _confirmingSetupPin = false;
      emit(AuthPinSetupEntry(phone.formatted, code));
    } catch (error) {
      if (generation != _otpCheckGeneration || state is! AuthOtpEntry) return;
      _otpCode = '';
      _currentPin = '';
      _setupPin = '';
      _settingUpPin = false;
      _confirmingSetupPin = false;
      emit(AuthOtpEntry(phone.formatted, code, _otpErrorMessage(error)));
    }
  }

  Future<void> _onPinChanged(PinChanged event, Emitter<AuthState> emit) async {
    if (state is AuthOtpEntry) return;
    _clearPinLockIfExpired();
    if (_isPinLocked) {
      _currentPin = '';
      emit(
        AuthFailure(_pinLockMessage(), _formattedCurrentPhone, _pinLockedUntil),
      );
      return;
    }

    final maxLength = 4;
    final incoming = event.pin;
    if (incoming.isEmpty) return;

    final combined = _currentPin + incoming;
    _currentPin = combined.length > maxLength
        ? combined.substring(0, maxLength)
        : combined;

    if (!_settingUpPin && !_confirmingSetupPin && _currentPin.length == 4) {
      await _completePinLogin(emit);
      return;
    }

    if (_settingUpPin && !_confirmingSetupPin && _currentPin.length == 4) {
      _setupPin = _currentPin;
      _currentPin = '';
      _settingUpPin = false;
      _confirmingSetupPin = true;
      emit(
        AuthPinSetupConfirmation(
          PhoneNumber(_currentPhone).formatted,
          _otpCode,
          _setupPin,
        ),
      );
      return;
    }

    if (_confirmingSetupPin && _currentPin.length == 4) {
      await _completeEmployeeOnboarding(emit);
      return;
    }

    // update state to reflect entered digits
    if (_settingUpPin) {
      emit(
        AuthPinSetupEntry(
          PhoneNumber(_currentPhone).formatted,
          _otpCode,
          _currentPin,
        ),
      );
    } else if (_confirmingSetupPin) {
      emit(
        AuthPinSetupConfirmation(
          PhoneNumber(_currentPhone).formatted,
          _otpCode,
          _setupPin,
          confirmation: _currentPin,
        ),
      );
    } else {
      emit(AuthPinEntry(PhoneNumber(_currentPhone).formatted, _currentPin));
    }
  }

  void _onPinBackspace(PinBackspace event, Emitter<AuthState> emit) {
    if (state is AuthOtpEntry) return;
    _clearPinLockIfExpired();
    if (_isPinLocked) {
      emit(
        AuthFailure(_pinLockMessage(), _formattedCurrentPhone, _pinLockedUntil),
      );
      return;
    }

    if (_currentPin.isNotEmpty) {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      if (_settingUpPin) {
        emit(
          AuthPinSetupEntry(
            PhoneNumber(_currentPhone).formatted,
            _otpCode,
            _currentPin,
          ),
        );
      } else if (_confirmingSetupPin) {
        emit(
          AuthPinSetupConfirmation(
            PhoneNumber(_currentPhone).formatted,
            _otpCode,
            _setupPin,
            confirmation: _currentPin,
          ),
        );
      } else {
        emit(AuthPinEntry(PhoneNumber(_currentPhone).formatted, _currentPin));
      }
    }
  }

  Future<void> _onPinSubmitted(
    PinSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthOtpEntry) return;
    _clearPinLockIfExpired();
    if (_isPinLocked) {
      _currentPin = '';
      emit(
        AuthFailure(_pinLockMessage(), _formattedCurrentPhone, _pinLockedUntil),
      );
      return;
    }

    emit(AuthPinLoading(PhoneNumber(_currentPhone).formatted));
    try {
      await _completePinLogin(emit);
    } catch (e) {
      _registerPinFailure(emit);
    }
  }

  Future<void> _completePinLogin(Emitter<AuthState> emit) async {
    emit(AuthPinLoading(_formattedCurrentPhone));
    try {
      final user = await _loginWithPin(
        phone: PhoneNumber(_currentPhone),
        pin: _currentPin,
      );
      emit(AuthAuthenticated(user));
      _failedPinAttempts = 0;
      _pinLockedUntil = null;
      _currentPin = '';
      _currentPhone = '';
    } catch (error) {
      _handlePinLoginFailure(error, emit);
    }
  }

  Future<void> requestOtpForPinReset(String phoneNumber) {
    return _sendOtp(PhoneNumber(phoneNumber));
  }

  Future<void> _completeEmployeeOnboarding(Emitter<AuthState> emit) async {
    emit(AuthPinLoading(PhoneNumber(_currentPhone).formatted));
    try {
      final user = await _verifyOtp(
        phone: PhoneNumber(_currentPhone),
        otp: _otpCode,
        pin: _setupPin,
        pinConfirmation: _currentPin,
      );
      emit(AuthAuthenticated(user));
      _resetSensitiveState();
    } catch (e) {
      if (e is ApiException &&
          (e.statusCode == 410 ||
              e.statusCode == 429 ||
              (e.statusCode == 401 &&
                  e.message.toLowerCase().contains('otp')))) {
        _currentPin = '';
        _setupPin = '';
        _otpCode = '';
        _settingUpPin = false;
        _confirmingSetupPin = false;
        emit(
          AuthOtpEntry(
            _formattedCurrentPhone,
            _currentOtp,
            _otpErrorMessage(e),
          ),
        );
        return;
      }
      _currentPin = '';
      _confirmingSetupPin = true;
      emit(
        AuthPinSetupConfirmation(
          _formattedCurrentPhone,
          _otpCode,
          _setupPin,
          confirmation: '',
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _resetSensitiveState() {
    _otpCheckGeneration++;
    _failedPinAttempts = 0;
    _pinLockedUntil = null;
    _currentPin = '';
    _currentOtp = '';
    _otpCode = '';
    _setupPin = '';
    _settingUpPin = false;
    _confirmingSetupPin = false;
    _currentPhone = '';
  }

  Future<void> _onPinResetRequested(
    PinResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final phone = PhoneNumber(event.phoneNumber);
    emit(AuthPinResetInProgress(phone.formatted));
    try {
      await _resetPin(
        phone: phone,
        verificationCode: event.verificationCode,
        newPin: event.newPin,
      );
      _currentPin = '';
      _failedPinAttempts = 0;
      _pinLockedUntil = null;
      emit(AuthPinResetSuccess(phone.formatted));
    } catch (error) {
      emit(AuthFailure(error.toString(), phone.formatted));
    }
  }

  void _onBackToPhoneRequested(
    BackToPhoneRequested event,
    Emitter<AuthState> emit,
  ) {
    _otpCheckGeneration++;
    _currentPhone = '';
    _currentPin = '';
    _currentOtp = '';
    _otpCode = '';
    _setupPin = '';
    _settingUpPin = false;
    _confirmingSetupPin = false;
    emit(const AuthPhoneInitial());
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _otpCheckGeneration++;
    await _logout();
    _failedPinAttempts = 0;
    _pinLockedUntil = null;
    _currentPhone = '';
    _currentPin = '';
    emit(const AuthPhoneInitial());
  }

  String _otpErrorMessage(Object error) {
    if (error is ApiException) {
      return switch (error.statusCode) {
        401 => 'Code OTP incorrect. Vérifiez le code reçu.',
        410 =>
          'Ce code OTP a expiré. Recommencez l’activation pour en recevoir un nouveau.',
        429 =>
          'Trop de tentatives. Recommencez l’activation pour recevoir un nouveau code.',
        _ => error.message,
      };
    }
    return 'Impossible de vérifier le code pour le moment. Réessayez.';
  }

  bool get _isPinLocked =>
      _pinLockedUntil != null && DateTime.now().isBefore(_pinLockedUntil!);

  String get _formattedCurrentPhone => PhoneNumber(_currentPhone).formatted;

  void _clearPinLockIfExpired() {
    if (_pinLockedUntil == null) {
      return;
    }

    if (!DateTime.now().isBefore(_pinLockedUntil!)) {
      _pinLockedUntil = null;
      _failedPinAttempts = 0;
    }
  }

  void _registerPinFailure(Emitter<AuthState> emit) {
    _failedPinAttempts += 1;
    _currentPin = '';

    if (_failedPinAttempts >= _maxPinAttempts) {
      _pinLockedUntil = DateTime.now().add(_pinLockDuration);
      emit(
        AuthFailure(_pinLockMessage(), _formattedCurrentPhone, _pinLockedUntil),
      );
      return;
    }

    final remainingAttempts = _maxPinAttempts - _failedPinAttempts;
    emit(
      AuthFailure(
        _messages.incorrectSecretCode(remainingAttempts),
        _formattedCurrentPhone,
      ),
    );
  }

  void _handlePinLoginFailure(Object error, Emitter<AuthState> emit) {
    if (_isInvalidPinError(error)) {
      _registerPinFailure(emit);
      return;
    }

    _currentPin = '';
    emit(
      AuthFailure(_messages.loginServiceUnavailable, _formattedCurrentPhone),
    );
  }

  bool _isInvalidPinError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('code pin incorrect') ||
        message.contains('code secret incorrect') ||
        message.contains('phone or pin') ||
        message.contains('unauthorized') ||
        message.contains('401');
  }

  String _pinLockMessage() {
    final lockedUntil = _pinLockedUntil;
    if (lockedUntil == null) {
      return _messages.retryInDuration(_pinLockDuration);
    }

    final remaining = lockedUntil.difference(DateTime.now());
    if (remaining.inMilliseconds <= 0) {
      return _messages.youCanRetryNow;
    }

    return _messages.retryInDuration(
      Duration(seconds: (remaining.inMilliseconds / 1000).ceil()),
    );
  }
}
