import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leeeeeoy_portfolio/util/logger/default_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    Log.i('[AppBlocObserver][onCreate] ${bloc.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    Log.i(
        '[AppBlocObserver][onTrans] ${bloc.runtimeType} event: ${transition.event.runtimeType} state: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onClose(BlocBase bloc) {
    Log.i('[AppBlocObserver][onClose] ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
