import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'auth_message_provider.dart';
import '../../../domain/value_objects/phone_number.dart';
import '../../../domain/use_cases/auth/send_otp.dart';
import '../../../domain/use_cases/auth/verify_otp.dart';
import '../../../domain/use_cases/auth/logout.dart';
import '../../../domain/use_cases/auth/reset_pin.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const int _otpLength = 6;
  static const int _maxPinAttempts = 5;
  static const Duration _pinLockDuration = Duration(minutes: 2);

  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final Logout _logout;
  final ResetPin _resetPin;
  final AuthMessageProvider _messages;

  String _currentPhone = '';
  String _currentPin = '';
  String _otpCode = '';
  String _setupPin = '';
  bool _settingUpPin = false;
  bool _confirmingSetupPin = false;
  int _failedPinAttempts = 0;
  DateTime? _pinLockedUntil;

  AuthBloc({
    required SendOtp sendOtp,
    required VerifyOtp verifyOtp,
    required Logout logout,
    required ResetPin resetPin,
    required AuthMessageProvider messages,
  }) : _sendOtp = sendOtp,
       _verifyOtp = verifyOtp,
       _logout = logout,
       _resetPin = resetPin,
       _messages = messages,
       super(const AuthPhoneInitial()) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PhoneNumberBackspace>(_onPhoneNumberBackspace);
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<PinChanged>(_onPinChanged);
    on<PinBackspace>(_onPinBackspace);
    on<PinSubmitted>(_onPinSubmitted);
    on<PinResetRequested>(_onPinResetRequested);
    on<BackToPhoneRequested>(_onBackToPhoneRequested);
    on<LogoutRequested>(_onLogoutRequested);
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

    emit(AuthPhoneLoading(_currentPhone));
    try {
      await _sendOtp(phone);
      emit(AuthPinEntry(phone.formatted));
    } catch (e) {
      emit(AuthPhoneInvalid(e.toString(), _currentPhone));
    }
  }

  Future<void> _onPinChanged(PinChanged event, Emitter<AuthState> emit) async {
    _clearPinLockIfExpired();
    if (_isPinLocked) {
      _currentPin = '';
      emit(
        AuthFailure(_pinLockMessage(), _formattedCurrentPhone, _pinLockedUntil),
      );
      return;
    }

    final maxLength = _settingUpPin || _confirmingSetupPin ? 4 : _otpLength;
    final incoming = event.pin;
    if (incoming.isEmpty) return;

    final combined = _currentPin + incoming;
    _currentPin = combined.length > maxLength
        ? combined.substring(0, maxLength)
        : combined;

    if (!_settingUpPin && !_confirmingSetupPin && _currentPin.length == _otpLength) {
      _otpCode = _currentPin;
      _currentPin = '';
      _settingUpPin = true;
      emit(AuthPinSetupEntry(PhoneNumber(_currentPhone).formatted, _otpCode));
      return;
    }

    if (_settingUpPin && !_confirmingSetupPin && _currentPin.length == 4) {
      _setupPin = _currentPin;
      _currentPin = '';
      _settingUpPin = false;
      _confirmingSetupPin = true;
      emit(AuthPinSetupConfirmation(
        PhoneNumber(_currentPhone).formatted,
        _otpCode,
        _setupPin,
      ));
      return;
    }

    if (_confirmingSetupPin && _currentPin.length == 4) {
      await _completeEmployeeOnboarding(emit);
      return;
    }

    // update state to reflect entered digits
    if (_settingUpPin) {
      emit(AuthPinSetupEntry(PhoneNumber(_currentPhone).formatted, _otpCode, _currentPin));
    } else if (_confirmingSetupPin) {
      emit(AuthPinSetupConfirmation(
        PhoneNumber(_currentPhone).formatted,
        _otpCode,
        _setupPin,
        confirmation: _currentPin,
      ));
    } else {
      emit(AuthPinEntry(PhoneNumber(_currentPhone).formatted, _currentPin));
    }
  }

  void _onPinBackspace(PinBackspace event, Emitter<AuthState> emit) {
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
        emit(AuthPinSetupEntry(
          PhoneNumber(_currentPhone).formatted,
          _otpCode,
          _currentPin,
        ));
      } else if (_confirmingSetupPin) {
        emit(AuthPinSetupConfirmation(
          PhoneNumber(_currentPhone).formatted,
          _otpCode,
          _setupPin,
          confirmation: _currentPin,
        ));
      } else {
        emit(AuthPinEntry(PhoneNumber(_currentPhone).formatted, _currentPin));
      }
    }
  }

  Future<void> _onPinSubmitted(
    PinSubmitted event,
    Emitter<AuthState> emit,
  ) async {
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
      final phone = PhoneNumber(_currentPhone);

      final user = await _verifyOtp(phone: phone, otp: _currentPin);
      emit(AuthAuthenticated(user));

      // clear sensitive data after success
      _failedPinAttempts = 0;
      _pinLockedUntil = null;
      _currentPin = '';
      _currentPhone = '';
    } catch (e) {
      _registerPinFailure(emit);
    }
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
      _currentPin = '';
      _confirmingSetupPin = true;
      emit(AuthPinSetupConfirmation(
        _formattedCurrentPhone,
        _otpCode,
        _setupPin,
        confirmation: '',
        errorMessage: e.toString(),
      ));
    }
  }

  void _resetSensitiveState() {
    _failedPinAttempts = 0;
    _pinLockedUntil = null;
    _currentPin = '';
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
    _currentPhone = '';
    _currentPin = '';
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
    await _logout();
    _failedPinAttempts = 0;
    _pinLockedUntil = null;
    _currentPhone = '';
    _currentPin = '';
    emit(const AuthPhoneInitial());
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
