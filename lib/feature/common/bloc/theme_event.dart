part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

final class ThemeChanged extends ThemeEvent {
  const ThemeChanged({required this.themeMode});

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

final class ThemeRequested extends ThemeEvent {
  const ThemeRequested();
}
