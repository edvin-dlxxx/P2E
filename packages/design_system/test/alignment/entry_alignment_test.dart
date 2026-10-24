import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import '../navigation/navigation_bar_test.dart' as navigation;

/// Diagnostic measurement suite, not a golden or a claim of 200% compliance.
void main() {
  final records = <Map<String, Object?>>[];
  tearDownAll(() {
    final file = File('../../build/entry-foundation/component-alignment.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(records));
  });
  for (final language in ['en', 'fa']) {
    for (final brightness in Brightness.values) {
      testWidgets('all component families requested 2.0 $language $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(402, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        final label = language == 'fa' ? 'ادامه' : 'Continue';
        final input = TextEditingController(
          text: language == 'fa' ? '۱۲۳۴۵۶' : '123456',
        );
        addTearDown(input.dispose);
        final cases = <String, Widget>{
          for (final spec in ButtonSpec.all.where(
            (s) => s.brightness == brightness,
          ))
            for (final mode in ButtonIconMode.values.where(
              (mode) =>
                  spec.family != AppButtonFamily.icon ||
                  mode != ButtonIconMode.none,
            ))
              'Button/${spec.family.name}/${spec.size.name}/${spec.type.name}/${mode.name}':
                  AppButton(
                    elementId: 'audit.button',
                    label: label,
                    onPressed: () {},
                    family: spec.family,
                    size: spec.size,
                    type: spec.type,
                    iconMode: mode,
                    icon: mode != ButtonIconMode.none
                        ? const AssetAppIcon(AppIconId.home)
                        : null,
                  ),
          for (final spec in BadgeSpec.all.where(
            (s) => s.brightness == brightness,
          ))
            for (final mode in BadgeIconMode.values)
              'Badge/${spec.size.name}/${spec.appearance.name}/${mode.name}':
                  AppBadge(
                    elementId: 'audit.badge',
                    label: label,
                    size: spec.size,
                    appearance: spec.appearance,
                    iconMode: mode,
                  ),
          'TextField': AppTextField(
            elementId: 'audit.field',
            label: label,
            options: FieldInputOptions(
              controller: input,
              supportingText: label,
            ),
          ),
          'Password': AppPasswordField(
            elementId: 'audit.password',
            label: label,
            showPasswordLabel: label,
            hidePasswordLabel: label,
            options: FieldInputOptions(
              controller: input,
              supportingText: label,
            ),
          ),
          'OTP': AppOtpField(
            elementId: 'audit.otp',
            label: label,
            controller: input,
            supportingText: label,
          ),
          'Radio': AppRadioGroup<int>(
            value: 1,
            onChanged: (_) {},
            child: AppRadio<int>(
              elementId: 'audit.radio',
              value: 1,
              label: label,
            ),
          ),
          'Icon': const AssetAppIcon(AppIconId.home),
          for (final configuration in <AppBarConfiguration>[
            HomeAppBar(
              avatar: AppBarAvatar(text: label),
              wallet: AppBarWallet(
                points: '150',
                unit: label,
                coins: '25',
                pointsSemanticLabel: label,
                coinsSemanticLabel: label,
              ),
              profile: AppBarAction(label: label, onPressed: () {}),
              help: AppBarAction(label: label, onPressed: () {}),
              addCoins: AppBarAction(label: label, onPressed: () {}),
            ),
            DownloadableGameAppBar(
              avatar: AppBarAvatar(text: label),
              back: AppBarAction(label: label, onPressed: () {}),
              downloads: AppBarAction(label: label, onPressed: () {}),
              bookmark: AppBarAction(label: label, onPressed: () {}),
              profile: AppBarAction(label: label, onPressed: () {}),
            ),
            if (brightness == Brightness.dark)
              BackAppBar(
                back: AppBarAction(label: label, onPressed: () {}),
                help: AppBarAction(label: label, onPressed: () {}),
              ),
          ])
            'AppBar/${configuration.category.name}': AppBarScaffoldAdapter(
              content: AppBarContent(
                elementId: 'audit.app-bar',
                configuration: configuration,
              ),
            ),
          for (final selected in [
            'home',
            'mission',
            'games',
            'leaderboard',
            'shop',
          ])
            'Navigation/$selected': AppNavigationBarHost(
              bar: AppNavigationBar(
                elementId: 'audit.navigation',
                destinations: navigation.destinations(
                  brightness: brightness,
                  persian: language == 'fa',
                ),
                selectedDestinationId: selected,
                onDestinationSelected: (_) {},
              ),
            ),
          for (final state in AppNavigationItemState.values)
            'NavigationItem/${state.name}': AppNavigationItem(
              elementId: 'audit.item',
              destination: navigation
                  .destinations(
                    brightness: brightness,
                    persian: language == 'fa',
                  )
                  .first,
              state: state,
              onPressed: () {},
            ),
        };
        for (final entry in cases.entries) {
          final errors = <String>[];
          final previous = FlutterError.onError;
          FlutterError.onError = (details) =>
              errors.add(details.exceptionAsString());
          try {
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(language),
                supportedLocales: const [Locale('en'), Locale('fa')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                theme: AppThemeFactory.build(brightness: brightness),
                builder: (context, child) => Localizations.override(
                  context: context,
                  locale: Locale(language),
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(2)),
                    child: Directionality(
                      textDirection: language == 'fa'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: child!,
                    ),
                  ),
                ),
                home: UiIdentityScope(
                  key: ValueKey(entry.key),
                  routeName: 'alignment',
                  child: Scaffold(
                    body: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: SizedBox(width: 402, child: entry.value),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
          } finally {
            FlutterError.onError = previous;
          }
          expect(find.byWidget(entry.value), findsOneWidget);
          final paragraphs = tester
              .renderObjectList<RenderParagraph>(find.byType(RichText))
              .toList();
          final clipped = <String>[];
          final overlaps = <String>[];
          final scales = <double>{};
          final rects = <(String, Rect)>[];
          for (final paragraph in paragraphs) {
            if (paragraph.text.toPlainText().isEmpty) continue;
            scales.add(paragraph.textScaler.scale(10) / 10);
            final text = paragraph.text.toPlainText();
            final painter = TextPainter(
              text: paragraph.text,
              textDirection: paragraph.textDirection,
              textScaler: paragraph.textScaler,
              maxLines: paragraph.maxLines,
              ellipsis: paragraph.overflow == TextOverflow.ellipsis
                  ? '…'
                  : null,
            )..layout(maxWidth: paragraph.size.width);
            if (painter.height > paragraph.size.height + .5 ||
                paragraph.didExceedMaxLines) {
              clipped.add(text);
            }
            painter.dispose();
            rects.add((
              text,
              paragraph.localToGlobal(Offset.zero) & paragraph.size,
            ));
          }
          for (var a = 0; a < rects.length; a++) {
            for (var b = a + 1; b < rects.length; b++) {
              final intersection = rects[a].$2.intersect(rects[b].$2);
              if (intersection.width > 1 && intersection.height > 1) {
                overlaps.add('${rects[a].$1} / ${rects[b].$1}');
              }
            }
          }
          final targets = <Map<String, Object?>>[];
          void visit(SemanticsNode node) {
            final data = node.getSemanticsData();
            if (!node.isMergedIntoParent &&
                data.hasAction(SemanticsAction.tap)) {
              targets.add({
                'label': data.label,
                'width': node.rect.width,
                'height': node.rect.height,
                'minimum48': node.rect.width >= 48 && node.rect.height >= 48,
              });
            }
            node.visitChildren((child) {
              visit(child);
              return true;
            });
          }

          visit(
            tester
                .renderObject(find.byType(Scaffold))
                .owner!
                .semanticsOwner!
                .rootSemanticsNode!,
          );
          records.add({
            'case': entry.key,
            'locale': language,
            'brightness': brightness.name,
            'requestedScale': 2,
            'paragraphScales': scales.toList(),
            'layoutErrors': errors,
            'clippedParagraphs': clipped,
            'overlappingParagraphs': overlaps,
            'tapTargets': targets,
          });
          expect(errors, isEmpty, reason: entry.key);
          final chrome =
              entry.key.startsWith('AppBar/') ||
              entry.key.startsWith('Navigation/') ||
              entry.key.startsWith('NavigationItem/');
          for (final scale in scales) {
            if (chrome) {
              expect(
                scale,
                lessThanOrEqualTo(chromeTextScaleCap),
                reason: entry.key,
              );
            } else {
              expect(
                scale,
                2,
                reason: '${entry.key} must retain content scaling',
              );
            }
          }
          expect(clipped, isEmpty, reason: '${entry.key} paragraph clipping');
          expect(overlaps, isEmpty, reason: '${entry.key} label overlap');
          expect(
            targets.where((t) => t['minimum48'] != true),
            isEmpty,
            reason: '${entry.key} undersized semantic tap target',
          );
        }
        semantics.dispose();
      });
    }
  }
}
