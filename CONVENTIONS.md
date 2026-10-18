# Flutter Conventions

Architecture and code conventions for this project. These are binding — new code follows them, and
code review rejects what doesn't.

**Stack:** Clean Architecture · `get_it` (DI) · `go_router` (navigation) · `flutter_bloc` (state)

---

## 1. Core principles

1. **The dependency rule.** `presentation → domain ← data`. The `domain` layer imports nothing from
   `data` or `presentation`, and nothing from Flutter. If domain code needs `package:flutter`, the
   design is wrong.
2. **Simple over clever.** Every abstraction must pay for itself today, not hypothetically. See §3.
3. **One obvious place for everything.** A reader should be able to guess the file path of any piece of code from its name alone.
4. **No magic values in widgets.** Strings, colors, sizes, and endpoints come from `core/constants/`.

---

## 2. Folder structure

```
lib/
├── core/
│   ├── constants/        app_strings.dart · app_colors.dart · app_dimens.dart · api_constants.dart
│   ├── theme/            app_theme.dart
│   ├── error/            failures.dart · exceptions.dart
│   ├── network/          dio_client.dart · network_info.dart
│   ├── router/           app_router.dart · app_routes.dart
│   ├── usecase/          usecase.dart
│   ├── result/           result.dart
│   └── di/               injection.dart
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── models/           <name>_model.dart          DTOs — fromJson / toJson live here
│       │   ├── datasources/      <name>_remote_data_source.dart · <name>_local_data_source.dart
│       │   └── repositories/     <name>_repository_impl.dart
│       ├── domain/
│       │   ├── entities/         <name>.dart                plain Dart, no serialization
│       │   ├── repositories/     <name>_repository.dart     abstract contract only
│       │   └── usecases/         <verb>_<name>.dart         one class, one `call()`
│       └── presentation/
│           ├── bloc/             <name>_bloc.dart · <name>_event.dart · <name>_state.dart
│           ├── pages/            <name>_page.dart
│           └── widgets/          feature-local widgets only
└── main.dart
```

**File naming:** `snake_case.dart`, suffixed by role (`_bloc`, `_page`, `_model`, `_repository_impl`).
Shared widgets used by two or more features move to `core/widgets/`.

---

## 3. Rules that keep it simple

Clean Architecture goes bad when every feature becomes twelve files of ceremony. These rules exist
specifically to prevent that.

**Don't:**

- ❌ Add a `Service`, `Manager`, `Controller`, or `Helper` layer. The layers are data / domain /
  presentation. There is no fourth.
- ❌ Create an abstract interface with exactly one implementation — *except* repositories, where the
  contract is what keeps domain testable and data swappable.
- ❌ Use `freezed`, `injectable`, `json_serializable`, or any other `build_runner` codegen while the
  app is small. Dart 3 sealed classes and hand-written `fromJson` cover it without a build step.
  Revisit only past ~8 models.
- ❌ Write barrel files (`<feature>.dart` re-exporting everything). They hide dependencies and invite
  import cycles.
- ❌ Abstract on first use. Extract on the **second** real usage, not in anticipation of one.
- ❌ Keep mutable global state. `get_it` is the only container.
- ❌ Write comments — neither `///` doc comments nor `//` inline notes. Code carries its meaning in
  naming and structure; rationale belongs in the commit message, where it is attached to the change
  that needed explaining. A line that can't be understood without a comment is a line to rename or
  restructure.

**Do:**

- ✅ Let a use case be a thin pass-through to its repository. That's normal and correct — it's the
  seam the bloc depends on. A one-line use case is cheap; a parallel service layer is not.
- ✅ Use `Cubit` instead of `Bloc` when there are no meaningful event names to declare (a toggle, a
  tab index, a filter). Events are documentation; don't invent them where there's nothing to say.
- ✅ Keep files under ~200 lines and `build()` methods under ~60. Past that, extract a widget.
- ✅ Prefer `const` constructors and `const` widgets everywhere they're possible.

---

## 4. Error handling

No `dartz` / `fpdart`. A sealed `Result<T>` plus Dart 3 pattern matching does the job with no
dependency and better readability.

```dart
// core/result/result.dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
```

```dart
// core/error/failures.dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = AppStrings.serverError]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = AppStrings.noConnection]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = AppStrings.cacheError]);
}
```

**Where errors convert:** data sources `throw` typed exceptions (`ServerException`,
`CacheException`). Repository implementations catch them and return `Failed(...)`. Nothing above the
repository layer uses `try/catch` for domain errors — a bloc reads a `Result` and never catches.

---

## 5. Domain layer

Entities are plain, immutable, and serialization-free. Models in `data/` extend or map to them.

```dart
// core/usecase/usecase.dart
abstract interface class UseCase<Out, In> {
  Future<Result<Out>> call(In params);
}

final class NoParams {
  const NoParams();
}
```

```dart
class GetSession implements UseCase<Session, String> {
  const GetSession(this._repository);
  final SessionRepository _repository;

  @override
  Future<Result<Session>> call(String id) => _repository.getSession(id);
}
```

One use case per file, named `<Verb><Noun>`. Parameters beyond a single primitive go in a small
`record` or a dedicated `*Params` class in the same file.

---

## 6. State management — BLoC

**Scope:** one bloc per feature, provided at the page level. Not one per widget.

**Events** are named as requests: `SessionRequested`, `AnswerSubmitted`, `SessionRetried`.
**States** are a sealed hierarchy, so impossible states don't compile:

```dart
sealed class SessionState {
  const SessionState();
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionLoaded extends SessionState {
  const SessionLoaded(this.session);
  final Session session;
}

final class SessionError extends SessionState {
  const SessionError(this.message);
  final String message;
}
```

> Exception: for a form with many independent fields, use a single state class with a `status` enum
> and a hand-written `copyWith`. Sealed subclasses are the default everywhere else.

```dart
final class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._getSession) : super(const SessionInitial()) {
    on<SessionRequested>(_onRequested);
  }

  final GetSession _getSession;

  Future<void> _onRequested(
    SessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    final result = await _getSession(event.id);
    emit(switch (result) {
      Success(:final data) => SessionLoaded(data),
      Failed(:final failure) => SessionError(failure.message),
    });
  }
}
```

**Rules:**

- A bloc depends only on use cases — never on a repository, data source, or `Dio` directly.
- No `BuildContext`, no `Navigator`, no `SnackBar` inside a bloc. Blocs emit state; widgets react.
- One handler method per event, named `_on<Event>`. No logic inline in the constructor.
- `BlocBuilder` with `buildWhen` for rendering; `BlocListener` for one-shot effects (navigation,
  snackbars, dialogs); `BlocConsumer` only when genuinely both are needed.
- `context.read<T>()` to dispatch, `context.watch<T>()` never inside a callback.
- No `setState` in feature pages. It's acceptable only for purely local UI mechanics such as an
  `AnimationController` or a `TextEditingController`.

---

## 7. Dependency injection — get_it

Manual registration in one file. Explicit, greppable, no build step.

```dart
// core/di/injection.dart
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ─────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(DioClient.create);
  sl.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());

  // ── Data sources ─────────────────────────────────────────
  sl.registerLazySingleton<SessionRemoteDataSource>(
    () => SessionRemoteDataSourceImpl(sl()),
  );

  // ── Repositories ─────────────────────────────────────────
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl(), sl()),
  );

  // ── Use cases ────────────────────────────────────────────
  sl.registerLazySingleton(() => GetSession(sl()));

  // ── Blocs ────────────────────────────────────────────────
  sl.registerFactory(() => SessionBloc(sl()));
}
```

**Rules:**

- Registration order is fixed: external → data sources → repositories → use cases → blocs.
- `registerFactory` for blocs (fresh instance per page), `registerLazySingleton` for everything
  stateless, `registerSingleton` only for already-initialized externals.
- Register against the **abstract type** (`<SessionRepository>`), never the implementation.
- `sl<T>()` is called in exactly one kind of place: a `BlocProvider.create`. Never inside a widget's
  `build`, and never inside domain or data code — those receive dependencies via constructor.
- As features grow, split into per-feature `_initSession()` functions called from
  `configureDependencies()`. Still one file until it exceeds ~150 lines.

---

## 8. Navigation — go_router

Route paths and names are constants. No string literals at call sites.

```dart
// core/router/app_routes.dart
abstract final class AppRoutes {
  static const home = '/';
  static const homeName = 'home';

  static const session = '/session/:id';
  static const sessionName = 'session';
}
```

```dart
// core/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.session,
      name: AppRoutes.sessionName,
      builder: (context, state) => SessionPage(id: state.pathParameters['id']!),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
```

**Rules:**

- Navigate **by name**: `context.pushNamed(AppRoutes.sessionName, pathParameters: {'id': id})`.
- Pass **identifiers**, not objects. The destination's bloc fetches what it needs. This keeps deep
  links and browser refresh working for free.
- `extra` is only for data that cannot be refetched, and never for an entity.
- Bottom navigation uses `StatefulShellRoute.indexedStack` so each tab keeps its own stack.
- **This app has no authentication and no gated routes.** `/splash` is the `initialLocation`; it
  performs async bootstrap then calls `context.go(AppRoutes.home)` — `go`, not `push`, so it leaves
  the stack. Don't introduce `redirect` guards or auth state without a decision to add accounts.

**Page vs. View.** `*Page` is the route boundary: it reads DI and provides the bloc, nothing else.
`*View` is pure UI and takes no dependencies — which is what makes it widget-testable.

```dart
class SessionPage extends StatelessWidget {
  const SessionPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SessionBloc>()..add(SessionRequested(id)),
      child: const SessionView(),
    );
  }
}
```

---

## 9. Constants and theming

All constants use `abstract final class` — not instantiable, not extendable, no `const` constructor
boilerplate.

```dart
// core/constants/app_strings.dart
abstract final class AppStrings {
  static const appName = 'Mettle';
  static const serverError = 'Something went wrong. Please try again.';
  static const noConnection = 'No internet connection.';
  static const cacheError = 'Could not read local data.';
}
```

```dart
// core/constants/app_colors.dart
abstract final class AppColors {
  static const seed = Color(0xFF4F46E5);
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
}
```

```dart
// core/constants/app_dimens.dart
abstract final class AppDimens {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const radius = 12.0;
}
```

**Rules:**

- No raw user-facing string in a widget. It goes in `AppStrings`.
- `AppColors` feeds `ThemeData` only. **Widgets read `Theme.of(context).colorScheme`**, not
  `AppColors` directly — that's what makes dark mode work without touching a single widget.
- Spacing and radii come from `AppDimens`. No bare `EdgeInsets.all(16)`.
- `api_constants.dart` holds the base URL and paths. No URL strings in data sources.
- Material 3 only (`useMaterial3: true`), with `light()` and `dark()` built from the same seed.

---

## 10. Testing

Mirror `lib/` under `test/`. `mocktail` for mocks — no codegen.

| Layer | Tool | What's asserted |
|---|---|---|
| Use cases | `test` + mocktail | repository called with right args, `Result` forwarded |
| Repositories | `test` + mocktail | exception → `Failure` mapping, cache fallback |
| Blocs | `bloc_test` | exact emitted state sequence |
| Widgets | `flutter_test` | `*View` renders each state correctly |
| Key screens | golden tests | visual regression, light + dark |

A feature is not done until its bloc has a `bloc_test` covering success and failure paths.

---

## 11. Lints and CI

`analysis_options.yaml` enables `flutter_lints` plus:

```yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - require_trailing_commas
    - sort_pub_dependencies
    - unawaited_futures
    - use_super_parameters
```

CI must pass `flutter analyze --fatal-infos`, `dart format --set-exit-if-changed .`, and
`flutter test`. CI also guards the dependency rule by failing if anything under
`lib/features/*/domain/` imports `package:flutter`, `../data/`, or `../presentation/`.

---

## 12. Adding a feature — checklist

1. `domain/entities/` — the entity.
2. `domain/repositories/` — the abstract contract, returning `Future<Result<T>>`.
3. `domain/usecases/` — one use case per operation.
4. `data/models/` — DTO with `fromJson` / `toJson` and a mapper to the entity.
5. `data/datasources/` — remote and/or local, throwing typed exceptions.
6. `data/repositories/` — the impl, mapping exceptions to `Failure`.
7. `presentation/bloc/` — event, sealed state, bloc.
8. `presentation/pages/` — `*Page` (DI + `BlocProvider`) and `*View` (pure UI).
9. `core/router/` — add path + name to `AppRoutes`, register the `GoRoute`.
10. `core/di/injection.dart` — register data source → repository → use cases → bloc.
11. `core/constants/app_strings.dart` — add any new copy.
12. `test/` — use case, repository, and bloc tests at minimum.

---

## 13. Commits

- Conventional commits: `feat(session): stream answers over SSE`, `fix(di): register bloc as factory`.
- One logical change per commit. Formatting and refactors stay separate from behavior changes.
- Work on a branch, open a PR into `main` with a short description — even working solo.
