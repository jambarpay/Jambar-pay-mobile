import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/wallet.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}
class ProfileLoaded extends ProfileState {
  final User user;
  final Wallet? wallet;
  final bool isDarkMode;

  const ProfileLoaded({
    required this.user,
    this.wallet,
    this.isDarkMode = false,
  });

  ProfileLoaded copyWith({
    User? user,
    Wallet? wallet,
    bool? isDarkMode,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      wallet: wallet ?? this.wallet,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [user, wallet, isDarkMode];
}

class PinChangeInProgress extends ProfileState {
  const PinChangeInProgress();
}

class PinChangeSuccess extends ProfileState {
  const PinChangeSuccess();
}

class PinChangeFailure extends ProfileState {
  final String errorMessage;

  const PinChangeFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class LogoutInProgress extends ProfileState {
  const LogoutInProgress();
}

class LogoutComplete extends ProfileState {
  const LogoutComplete();
}
