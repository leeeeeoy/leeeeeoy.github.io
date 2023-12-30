import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leeeeeoy_portfolio/util/logger/default_logger.dart';

class ProviderLogger implements ProviderObserver {
  @override
  void didAddProvider(ProviderBase provider, Object? value, ProviderContainer container) =>
      Log.i('didAddProvider: ${provider.name ?? provider.runtimeType} $value');

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) =>
      Log.i('didDisposeProvider: ${provider.name ?? provider.runtimeType}');

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) =>
      Log.i('didUpdateProvider: ${provider.name ?? provider.runtimeType} $previousValue --> $newValue');

  @override
  void providerDidFail(
          ProviderBase<Object?> provider, Object error, StackTrace stackTrace, ProviderContainer container) =>
      Log.i('providerDidFail: ${provider.name ?? provider.runtimeType} --> $error');
}
