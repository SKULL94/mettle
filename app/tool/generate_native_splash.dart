import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mettle/core/constants/app_dimens.dart';
import 'package:mettle/core/constants/app_strings.dart';
import 'package:mettle/core/theme/app_theme.dart';
import 'package:mettle/core/widgets/mettle_mark.dart';

const _lockupWidth = 320.0;

const _densities = <String, double>{
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

const _fonts = <String, String>{'Inter': 'assets/fonts/Inter-Variable.ttf'};

Future<void> _loadFonts() async {
  for (final entry in _fonts.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) {
      throw StateError('Missing font ${entry.value}');
    }
    final bytes = file.readAsBytesSync().buffer.asByteData();
    final loader = FontLoader(entry.key)..addFont(Future.value(bytes));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('render native splash lockup', (tester) async {
    final boundary = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(480.0, 480.0));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Center(
              child: RepaintBoundary(
                key: boundary,
                child: SizedBox(
                  width: _lockupWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MettleMark(),
                      const SizedBox(height: AppDimens.lg),
                      const MettleWordmark(),
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        AppStrings.appTagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final renderObject =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    for (final entry in _densities.entries) {
      final bytes = await tester.runAsync(() async {
        final image = await renderObject.toImage(pixelRatio: entry.value);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        return data!.buffer.asUint8List();
      });

      final directory = Directory(
        'android/app/src/main/res/drawable-${entry.key}',
      );
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File('${directory.path}/mettle_splash_lockup.png');
      file.writeAsBytesSync(bytes!);
      stdout.writeln('wrote ${file.path} (${bytes.length} bytes)');
    }
  });
}
