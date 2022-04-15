part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ThemeChanged extends ThemeEvent {
  const ThemeChanged(this.isDark);

  final bool isDark;

  @override
  List<Object?> get props => [];
}
