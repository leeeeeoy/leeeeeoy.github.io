import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leeeeeoy_portfolio/data/repository/app_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    required bool isDark,
    required this.appRepository,
  }) : super(
          isDark ? const ThemeDarkChecked() : const ThemeLightChecked(),
        ) {
    on<ThemeChanged>(_onThemeChanged);
  }

  final AppRepository appRepository;

  FutureOr<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await appRepository.setThmeMode(event.isDark);
    if (event.isDark) {
      emit(const ThemeDarkChecked());
    } else {
      emit(const ThemeLightChecked());
    }
  }
}
