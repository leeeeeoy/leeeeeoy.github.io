part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
}

class ThemeLightChecked extends ThemeState {
  const ThemeLightChecked();

  @override
  List<Object?> get props => [];
}

class ThemeDarkChecked extends ThemeState {
  const ThemeDarkChecked();

  @override
  List<Object?> get props => [];
}
