import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class DarkModeChanged extends ProfileEvent {
  final bool isDarkMode;

  const DarkModeChanged(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class PinChangeRequested extends ProfileEvent {
  final String currentPin;
  final String newPin;

  const PinChangeRequested({
    required this.currentPin,
    required this.newPin,
  });

  @override
  List<Object?> get props => [currentPin, newPin];
}

class PinChanged extends ProfileEvent {
  const PinChanged();
}


class LogoutRequested extends ProfileEvent {
  const LogoutRequested();
}
