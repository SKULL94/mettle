import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_overview.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/interview/data/datasources/interview_remote_data_source.dart';
import '../../features/interview/data/repositories/interview_repository_impl.dart';
import '../../features/interview/domain/repositories/interview_repository.dart';
import '../../features/interview/domain/usecases/get_scorecard.dart';
import '../../features/interview/domain/usecases/skip_question.dart';
import '../../features/interview/domain/usecases/start_session.dart';
import '../../features/interview/domain/usecases/submit_answer.dart';
import '../../features/interview/domain/usecases/watch_turns.dart';
import '../storage/app_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<SharedPreferences>()) return;

  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

  sl.registerLazySingleton<HomeLocalDataSource>(HomeLocalDataSourceSeeded.new);
  sl.registerLazySingleton<InterviewRemoteDataSource>(
    InterviewScriptedDataSource.new,
  );

  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetHomeOverview(sl()));
  sl.registerLazySingleton(() => StartSession(sl()));
  sl.registerLazySingleton(() => WatchTurns(sl()));
  sl.registerLazySingleton(() => SubmitAnswer(sl()));
  sl.registerLazySingleton(() => SkipQuestion(sl()));
  sl.registerLazySingleton(() => GetScorecard(sl()));

  sl.registerFactory(() => HomeBloc(sl()));
}

Future<void> resetDependencies() => sl.reset();
