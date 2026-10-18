import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_overview.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../storage/app_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<SharedPreferences>()) return;

  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

  sl.registerLazySingleton<HomeLocalDataSource>(HomeLocalDataSourceSeeded.new);

  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetHomeOverview(sl()));

  sl.registerFactory(() => HomeBloc(sl()));
}

Future<void> resetDependencies() => sl.reset();
