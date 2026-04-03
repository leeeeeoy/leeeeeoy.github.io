// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../data/local/app_database.dart' as _i276;
import '../data/remote/api_client.dart' as _i117;
import '../data/remote/portfolio_data_source.dart' as _i238;
import '../data/repository/app_repository.dart' as _i385;
import '../data/repository/portfolio_repository.dart' as _i398;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i276.AppDatabase>(() => const _i276.AppDatabase());
    gh.lazySingleton<_i117.ApiClient>(() => _i117.ApiClient());
    gh.lazySingleton<_i238.PortfolioDataSource>(
      () => _i238.PortfolioDataSource(gh<_i117.ApiClient>()),
    );
    gh.lazySingleton<_i398.PortfolioRepository>(
      () => _i398.PortfolioRepository(gh<_i238.PortfolioDataSource>()),
    );
    gh.lazySingleton<_i385.AppRepository>(
      () => _i385.AppRepository(appDatabase: gh<_i276.AppDatabase>()),
    );
    return this;
  }
}
