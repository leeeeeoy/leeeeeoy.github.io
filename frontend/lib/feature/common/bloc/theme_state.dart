part of 'theme_bloc.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

final class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

final class ThemeLoaded extends ThemeState {
  const ThemeLoaded({required this.themeMode});

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}
