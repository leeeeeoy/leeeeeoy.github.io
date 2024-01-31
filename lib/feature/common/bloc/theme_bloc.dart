import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leeeeeoy_portfolio/data/repository/app_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required this.appRepository}) : super(const ThemeInitial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeRequested>(_onThemeRequested);

    add(const ThemeRequested());
  }

  final AppRepository appRepository;

  FutureOr<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) {
    appRepository.setThemeMode(
      switch (event.themeMode) {
        ThemeMode.system => true,
        ThemeMode.light => false,
        ThemeMode.dark => true,
      },
    );

    emit(ThemeLoaded(themeMode: event.themeMode));
  }

  FutureOr<void> _onThemeRequested(ThemeRequested event, Emitter<ThemeState> emit) {
    final isDark = appRepository.getThemeMode();

    emit(ThemeLoaded(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
