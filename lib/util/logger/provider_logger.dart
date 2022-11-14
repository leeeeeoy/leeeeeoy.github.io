import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leeeeeoy_portfolio/util/logger/default_logger.dart';

class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    super.didAddProvider(provider, value, container);
    if (value is! StateController) {
      Log.i('didAddProvider: $value');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    super.didDisposeProvider(provider, container);
    Log.i('didDisposeProvider: ${provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    super.didUpdateProvider(provider, previousValue, newValue, container);
    if (newValue is! StateController && previousValue is! StateController) {
      Log.i('didUpdateProvider: $previousValue --> $newValue');
    }
  }
}
