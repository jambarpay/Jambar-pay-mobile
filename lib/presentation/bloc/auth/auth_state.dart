import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthPhoneInitial extends AuthState {
  final String phoneNumber;

  const AuthPhoneInitial([this.phoneNumber = '']);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthPhoneLoading extends AuthState {
  final String phoneNumber;

  const AuthPhoneLoading([this.phoneNumber = '']);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthPhoneValid extends AuthState {
  final String formattedPhone;

  const AuthPhoneValid(this.formattedPhone);

  @override
  List<Object?> get props => [formattedPhone];
}

class AuthPhoneInvalid extends AuthState {
  final String errorMessage;
  final String phoneNumber;

  const AuthPhoneInvalid(this.errorMessage, [this.phoneNumber = '']);

  @override
  List<Object?> get props => [errorMessage, phoneNumber];
}

class AuthPinEntry extends AuthState {
  final String phoneNumber;
  final String currentPin;

  const AuthPinEntry(this.phoneNumber, [this.currentPin = '']);

  @override
  List<Object?> get props => [phoneNumber, currentPin];
}

class AuthPinLoading extends AuthState {
  final String phoneNumber;

  const AuthPinLoading([this.phoneNumber = '']);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthPinSetupEntry extends AuthState {
  final String phoneNumber;
  final String otp;
  final String pin;

  const AuthPinSetupEntry(this.phoneNumber, this.otp, [this.pin = '']);

  @override
  List<Object?> get props => [phoneNumber, otp, pin];
}

class AuthPinSetupConfirmation extends AuthState {
  final String phoneNumber;
  final String otp;
  final String pin;
  final String confirmation;
  final String? errorMessage;

  const AuthPinSetupConfirmation(
    this.phoneNumber,
    this.otp,
    this.pin, {
    String confirmation = '',
    String? errorMessage,
  }) : confirmation = confirmation,
      errorMessage = errorMessage;

  @override
  List<Object?> get props => [phoneNumber, otp, pin, confirmation, errorMessage];
}

class AuthPinResetInProgress extends AuthState {
  const AuthPinResetInProgress(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthPinResetSuccess extends AuthState {
  const AuthPinResetSuccess(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String errorMessage;

  final String phoneNumber;
  final DateTime? pinLockedUntil;

  const AuthFailure(
    this.errorMessage, [
    this.phoneNumber = '',
    this.pinLockedUntil,
  ]);

  @override
  List<Object?> get props => [errorMessage, phoneNumber, pinLockedUntil];
}
