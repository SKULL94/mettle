import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mettle/core/di/injection.dart';
import 'package:mettle/core/storage/app_preferences.dart';
import 'package:mettle/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:mettle/features/splash/presentation/cubit/splash_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await resetDependencies();
  });

  tearDown(resetDependencies);

  group('SplashCubit', () {
    blocTest<SplashCubit, SplashState>(
      'emits ready once bootstrap completes',
      build: SplashCubit.new,
      act: (cubit) => cubit.bootstrap(),
      expect: () => const <SplashState>[SplashReady()],
    );

    blocTest<SplashCubit, SplashState>(
      'registers the container so dependencies resolve afterwards',
      build: SplashCubit.new,
      act: (cubit) => cubit.bootstrap(),
      verify: (_) {
        // Bootstrap's actual job. If this regresses, every screen that resolves
        // from sl() fails at runtime instead of here.
        expect(sl.isRegistered<SharedPreferences>(), isTrue);
        expect(sl.isRegistered<AppPreferences>(), isTrue);
      },
    );

    test('generates a device id on first launch and then reuses it', () async {
      final cubit = SplashCubit();
      await cubit.bootstrap();

      final prefs = sl<AppPreferences>();
      final first = await prefs.deviceId();
      final second = await prefs.deviceId();

      expect(first, isNotEmpty);
      // Stability matters: a regenerated id orphans the backend's conversation
      // thread and silently loses the user's history.
      expect(second, first);
      expect(
        first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
            r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
        reason: 'must be a well-formed RFC 4122 v4 UUID',
      );

      await cubit.close();
    });

    test('retry recovers after a failure', () async {
      final cubit = SplashCubit();
      await cubit.bootstrap();
      expect(cubit.state, isA<SplashReady>());

      // Retry resets the container; without that, re-registering the same
      // singleton would throw and leave the app stuck on the error screen.
      await cubit.retry();
      expect(cubit.state, isA<SplashReady>());

      await cubit.close();
    });
  });
}
