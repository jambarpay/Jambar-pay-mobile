import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class PhoneNumberChanged extends AuthEvent {
  final String phoneNumber;

  const PhoneNumberChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneNumberBackspace extends AuthEvent {
  const PhoneNumberBackspace();
}

class PhoneNumberSubmitted extends AuthEvent {
  const PhoneNumberSubmitted();
}

class PinChanged extends AuthEvent {
  final String pin;

  const PinChanged(this.pin);

  @override
  List<Object?> get props => [pin];
}

class PinBackspace extends AuthEvent {
  const PinBackspace();
}

class PinSubmitted extends AuthEvent {
  const PinSubmitted();
}

class BackToPhoneRequested extends AuthEvent {
  const BackToPhoneRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
