import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:forge/core/navigation/workout_plans_reload_notifier.dart';
import 'package:forge/core/services/exercise_seed_service.dart';
import 'package:forge/features/auth/application/cubit/app_lock_cubit.dart';
import 'package:forge/core/services/theme_persistence_service.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_bloc.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/repositories/exercise_repository_impl.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/exercise/domain/usecases/get_exercises_usecase.dart';
import 'package:forge/features/home/application/bloc/home_bloc.dart';
import 'package:forge/features/home/application/usecases/get_dashboard_snapshot_usecase.dart';
import 'package:forge/features/home/data/datasources/home_local_data_source.dart';
import 'package:forge/features/home/data/repositories/home_repository_impl.dart';
import 'package:forge/features/home/domain/repositories/home_repository.dart';
import 'package:forge/features/profile/application/bloc/logout_bloc.dart';
import 'package:forge/features/profile/application/use_cases/clear_user_data_use_case.dart';
import 'package:forge/features/profile/data/datasources/account_data_local_data_source.dart';
import 'package:forge/features/profile/data/repositories/account_data_repository_impl.dart';
import 'package:forge/features/profile/domain/repositories/account_data_repository.dart';
import 'package:forge/features/profile/application/bloc/profile_bloc.dart';
import 'package:forge/features/profile/application/use_cases/get_profile_use_case.dart';
import 'package:forge/features/profile/application/use_cases/save_profile_use_case.dart';
import 'package:forge/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:forge/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:forge/features/profile/domain/repositories/profile_repository.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/pre_start_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/workout_plans_bloc.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/repositories/workout_plan_repository_impl.dart';
import 'package:forge/features/workout_plan/domain/repositories/workout_plan_repository.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_bloc.dart';
import 'package:forge/features/workout_plan/domain/usecases/delete_workout_plan_usecase.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plan_by_id_usecase.dart';
import 'package:forge/features/workout_plan/domain/usecases/get_workout_plans_usecase.dart';
import 'package:forge/features/workout_plan/domain/usecases/save_workout_plan_usecase.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_bloc.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_use_case.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';
import 'package:forge/core/navigation/progress_reload_notifier.dart';
import 'package:forge/core/navigation/stats_reload_notifier.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_bloc.dart';
import 'package:forge/features/personal_bests/application/use_cases/get_personal_bests_use_case.dart';
import 'package:forge/features/stats/application/bloc/stats_bloc.dart';
import 'package:forge/features/stats/application/use_cases/get_statistics_use_case.dart';
import 'package:forge/core/navigation/workout_history_reload_notifier.dart';
import 'package:forge/features/progress/application/bloc/progress_bloc.dart';
import 'package:forge/features/progress/application/use_cases/get_exercise_progress_data_use_case.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_bloc.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/repositories/workout_session_repository_impl.dart';
import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_bloc.dart';
import 'package:forge/features/workout_session/domain/usecases/delete_workout_session_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/has_completed_workout_today_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/update_workout_session_usecase.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_bloc.dart';
import 'package:forge/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/get_weekly_schedule_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/load_assignment_context_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/remove_schedule_entry_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/save_schedule_assignment_usecase.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Register all dependencies.
/// Called from [bootstrap] once configuration is initialised.
Future<void> setupGetIt() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  _registerCoreServices();
  _registerAuth();
  _registerProfile();
  _registerLocalDataSources();
  _registerWorkoutSession();
  _registerWorkoutHistory();
  _registerWorkoutStatistics();
  _registerExerciseSeedService();
  _registerHome();
  _registerExercise();
  _registerWorkoutPlan();
  _registerSchedule();
}

void _registerCoreServices() {
  getIt.registerSingleton<AppDatabase>(
    AppDatabase(),
    dispose: (database) => database.close(),
  );

  getIt.registerLazySingleton<ThemePersistenceService>(
    () => ThemePersistenceService(preferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<AppLogger>(() => AppLogger());
}

void _registerAuth() {
  getIt.registerLazySingleton<AppLockCubit>(() => AppLockCubit());
}

void _registerProfile() {
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: getIt<ProfileLocalDataSource>()),
  );

  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(repository: getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<SaveProfileUseCase>(
    () => SaveProfileUseCase(repository: getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<AccountDataLocalDataSource>(
    () => AccountDataLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<AccountDataRepository>(
    () => AccountDataRepositoryImpl(
      dataSource: getIt<AccountDataLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ClearUserDataUseCase>(
    () => ClearUserDataUseCase(repository: getIt<AccountDataRepository>()),
  );

  getIt.registerFactory<LogoutBloc>(
    () => LogoutBloc(clearUserData: getIt<ClearUserDataUseCase>()),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfile: getIt<GetProfileUseCase>(),
      saveProfile: getIt<SaveProfileUseCase>(),
    ),
  );
}

void _registerLocalDataSources() {
  getIt.registerLazySingleton<ExerciseLocalDataSource>(
    () => ExerciseLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<WorkoutPlanLocalDataSource>(
    () => WorkoutPlanLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ScheduleLocalDataSource>(
    () => ScheduleLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<WorkoutSessionLocalDataSource>(
    () => WorkoutSessionLocalDataSourceImpl(getIt<AppDatabase>()),
  );
}

void _registerWorkoutSession() {
  getIt.registerLazySingleton<WorkoutSessionRepository>(
    () => WorkoutSessionRepositoryImpl(
      dataSource: getIt<WorkoutSessionLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<SaveWorkoutSessionUseCase>(
    () => SaveWorkoutSessionUseCase(
      repository: getIt<WorkoutSessionRepository>(),
      exerciseRepository: getIt<ExerciseRepository>(),
    ),
  );

  getIt.registerFactory<ActiveWorkoutBloc>(ActiveWorkoutBloc.new);

  getIt.registerFactory<WorkoutSummaryBloc>(
    () => WorkoutSummaryBloc(
      repository: getIt<WorkoutSessionRepository>(),
      saveSession: getIt<SaveWorkoutSessionUseCase>(),
    ),
  );

  getIt.registerFactory<RestTimerBloc>(RestTimerBloc.new);
}

void _registerWorkoutHistory() {
  getIt.registerLazySingleton<GetWorkoutHistoryUseCase>(
    () => GetWorkoutHistoryUseCase(getIt<WorkoutSessionRepository>()),
  );

  getIt.registerFactory<WorkoutHistoryBloc>(
    () => WorkoutHistoryBloc(
      getWorkoutHistory: getIt<GetWorkoutHistoryUseCase>(),
    ),
  );

  getIt.registerLazySingleton<GetWorkoutHistoryDetailUseCase>(
    () => GetWorkoutHistoryDetailUseCase(getIt<WorkoutSessionRepository>()),
  );

  getIt.registerFactory<WorkoutHistoryDetailBloc>(
    () => WorkoutHistoryDetailBloc(
      getDetail: getIt<GetWorkoutHistoryDetailUseCase>(),
    ),
  );

  getIt.registerLazySingleton<HasCompletedWorkoutTodayUseCase>(
    () => HasCompletedWorkoutTodayUseCase(getIt<WorkoutSessionRepository>()),
  );

  getIt.registerLazySingleton<DeleteWorkoutSessionUseCase>(
    () => DeleteWorkoutSessionUseCase(getIt<WorkoutSessionRepository>()),
  );

  getIt.registerLazySingleton<UpdateWorkoutSessionUseCase>(
    () => UpdateWorkoutSessionUseCase(
      repository: getIt<WorkoutSessionRepository>(),
      saveSession: getIt<SaveWorkoutSessionUseCase>(),
    ),
  );

  getIt.registerFactory<DeleteWorkoutSessionBloc>(
    () => DeleteWorkoutSessionBloc(
      deleteWorkoutSession: getIt<DeleteWorkoutSessionUseCase>(),
    ),
  );

  getIt.registerFactory<EditWorkoutSessionBloc>(
    () => EditWorkoutSessionBloc(
      getDetail: getIt<GetWorkoutHistoryDetailUseCase>(),
      updateSession: getIt<UpdateWorkoutSessionUseCase>(),
    ),
  );
}

void _registerWorkoutStatistics() {
  getIt.registerLazySingleton<GetExerciseProgressDataUseCase>(
    () => GetExerciseProgressDataUseCase(
      repository: getIt<WorkoutSessionRepository>(),
    ),
  );

  getIt.registerFactory<ProgressBloc>(
    () =>
        ProgressBloc(getProgressData: getIt<GetExerciseProgressDataUseCase>()),
  );

  getIt.registerLazySingleton<GetStatisticsUseCase>(
    () => GetStatisticsUseCase(getIt<WorkoutSessionRepository>()),
  );

  getIt.registerFactory<StatsBloc>(
    () => StatsBloc(getStatistics: getIt<GetStatisticsUseCase>()),
  );

  getIt.registerLazySingleton<GetPersonalBestsUseCase>(
    () => GetPersonalBestsUseCase(getIt<WorkoutSessionRepository>()),
  );

  getIt.registerFactory<PbBloc>(
    () => PbBloc(getPersonalBests: getIt<GetPersonalBestsUseCase>()),
  );

  getIt.registerLazySingleton<StatsReloadNotifier>(StatsReloadNotifier.new);

  getIt.registerLazySingleton<WorkoutDataRefresher>(
    () => WorkoutDataRefresher(
      stats: getIt<StatsReloadNotifier>(),
      progress: getIt<ProgressReloadNotifier>(),
      history: getIt<WorkoutHistoryReloadNotifier>(),
      home: getIt<HomeReloadNotifier>(),
    ),
  );

  getIt.registerLazySingleton<HomeReloadNotifier>(HomeReloadNotifier.new);

  getIt.registerLazySingleton<ScheduleReloadNotifier>(
    ScheduleReloadNotifier.new,
  );

  getIt.registerLazySingleton<ProgressReloadNotifier>(
    ProgressReloadNotifier.new,
  );

  getIt.registerLazySingleton<WorkoutHistoryReloadNotifier>(
    WorkoutHistoryReloadNotifier.new,
  );
}

void _registerExerciseSeedService() {
  getIt.registerLazySingleton<ExerciseSeedService>(
    () => ExerciseSeedService(dataSource: getIt<ExerciseLocalDataSource>()),
  );
}

void _registerHome() {
  getIt.registerLazySingleton<HomeDashboardLocalDataSource>(
    () => HomeDashboardLocalDataSourceImpl(
      planDataSource: getIt<WorkoutPlanLocalDataSource>(),
      scheduleDataSource: getIt<ScheduleLocalDataSource>(),
      sessionDataSource: getIt<WorkoutSessionLocalDataSource>(),
      exerciseDataSource: getIt<ExerciseLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      localDataSource: getIt<HomeDashboardLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetDashboardSnapshotUseCase>(
    () => GetDashboardSnapshotUseCase(repository: getIt<HomeRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getDashboardSnapshot: getIt<GetDashboardSnapshotUseCase>()),
  );
}

void _registerExercise() {
  getIt.registerLazySingleton<ExerciseRepository>(
    () => ExerciseRepositoryImpl(dataSource: getIt<ExerciseLocalDataSource>()),
  );

  getIt.registerLazySingleton<GetExercisesUseCase>(
    () => GetExercisesUseCase(repository: getIt<ExerciseRepository>()),
  );

  getIt.registerFactory<ExerciseCatalogueBloc>(
    () => ExerciseCatalogueBloc(getExercises: getIt<GetExercisesUseCase>()),
  );
}

void _registerWorkoutPlan() {
  getIt.registerLazySingleton<WorkoutPlansReloadNotifier>(
    () => WorkoutPlansReloadNotifier(),
  );

  getIt.registerLazySingleton<WorkoutPlanRepository>(
    () => WorkoutPlanRepositoryImpl(
      dataSource: getIt<WorkoutPlanLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetWorkoutPlansUseCase>(
    () => GetWorkoutPlansUseCase(repository: getIt<WorkoutPlanRepository>()),
  );

  getIt.registerFactory<WorkoutPlansBloc>(
    () => WorkoutPlansBloc(getWorkoutPlans: getIt<GetWorkoutPlansUseCase>()),
  );

  getIt.registerLazySingleton<GetWorkoutPlanByIdUseCase>(
    () => GetWorkoutPlanByIdUseCase(getIt<WorkoutPlanRepository>()),
  );

  getIt.registerLazySingleton<SaveWorkoutPlanUseCase>(
    () => SaveWorkoutPlanUseCase(
      repository: getIt<WorkoutPlanRepository>(),
      exerciseRepository: getIt<ExerciseRepository>(),
    ),
  );

  getIt.registerFactory<CreateEditWorkoutPlanBloc>(
    () => CreateEditWorkoutPlanBloc(
      getWorkoutPlanById: getIt<GetWorkoutPlanByIdUseCase>(),
      saveWorkoutPlan: getIt<SaveWorkoutPlanUseCase>(),
    ),
  );

  getIt.registerFactory<PlanDetailBloc>(
    () =>
        PlanDetailBloc(getWorkoutPlanById: getIt<GetWorkoutPlanByIdUseCase>()),
  );

  getIt.registerLazySingleton<DeleteWorkoutPlanUseCase>(
    () => DeleteWorkoutPlanUseCase(getIt<WorkoutPlanRepository>()),
  );

  getIt.registerFactory<DeletePlanBloc>(
    () => DeletePlanBloc(deleteWorkoutPlan: getIt<DeleteWorkoutPlanUseCase>()),
  );

  getIt.registerFactory<PreStartBloc>(
    () => PreStartBloc(
      getWorkoutPlanById: getIt<GetWorkoutPlanByIdUseCase>(),
      hasCompletedWorkoutToday: getIt<HasCompletedWorkoutTodayUseCase>(),
    ),
  );
}

void _registerSchedule() {
  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      scheduleDataSource: getIt<ScheduleLocalDataSource>(),
      planDataSource: getIt<WorkoutPlanLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetWeeklyScheduleUseCase>(
    () => GetWeeklyScheduleUseCase(repository: getIt<ScheduleRepository>()),
  );

  getIt.registerFactory<WeekScheduleBloc>(
    () =>
        WeekScheduleBloc(getWeeklySchedule: getIt<GetWeeklyScheduleUseCase>()),
  );

  getIt.registerLazySingleton<LoadAssignmentContextUseCase>(
    () => LoadAssignmentContextUseCase(repository: getIt<ScheduleRepository>()),
  );

  getIt.registerLazySingleton<SaveScheduleAssignmentUseCase>(
    () =>
        SaveScheduleAssignmentUseCase(repository: getIt<ScheduleRepository>()),
  );

  getIt.registerFactory<AssignScheduleBloc>(
    () => AssignScheduleBloc(
      loadAssignmentContext: getIt<LoadAssignmentContextUseCase>(),
      saveScheduleAssignment: getIt<SaveScheduleAssignmentUseCase>(),
    ),
  );

  getIt.registerLazySingleton<RemoveScheduleEntryUseCase>(
    () => RemoveScheduleEntryUseCase(repository: getIt<ScheduleRepository>()),
  );

  getIt.registerFactory<RemoveScheduleEntryBloc>(
    () => RemoveScheduleEntryBloc(
      removeScheduleEntry: getIt<RemoveScheduleEntryUseCase>(),
    ),
  );
}
