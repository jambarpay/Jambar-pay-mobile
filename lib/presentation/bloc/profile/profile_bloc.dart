import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../../domain/use_cases/auth/change_pin.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/phone_number.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ChangePin _changePin;
  final AuthRepository _authRepository;

  ProfileBloc({
    required ChangePin changePin,
    required AuthRepository authRepository,
  })  : _changePin = changePin,
        _authRepository = authRepository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<DarkModeChanged>(_onDarkModeChanged);
    on<PinChangeRequested>(_onPinChangeRequested);
    on<PinChanged>(_onPinChanged);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    emit(const ProfileLoaded(
      user: User(id: '', name: '', phone: PhoneNumber('')),
      wallet: null,
      isDarkMode: false,
    ));
  }

  void _onDarkModeChanged(
    DarkModeChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(current.copyWith(isDarkMode: event.isDarkMode));
  }

  Future<void> _onPinChangeRequested(
    PinChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const PinChangeInProgress());
    try {
      await _changePin(
        currentPin: event.currentPin,
        newPin: event.newPin,
      );
      add(const PinChanged());
    } catch (e) {
      emit(PinChangeFailure(e.toString()));
    }
  }

  void _onPinChanged(
    PinChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(const PinChangeSuccess());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const LogoutInProgress());
    try {
      await _authRepository.logout();
      emit(const LogoutComplete());
    } catch (e) {
      emit(const LogoutComplete()); 
    }
  }
}
