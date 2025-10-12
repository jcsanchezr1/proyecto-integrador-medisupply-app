import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

class TestTextsUtil extends TextsUtil {
  TestTextsUtil(super.locale);
  @override
  Future<void> load() async {
    mLocalizedStrings = {
      'login': {
        'title': 'Título',
        'subtitle': 'Subtítulo',
        'error': 'Error',
      },
      'simple': 'Texto simple',
    };
  }
}

// Helper delegate for widget tests
class _TestDelegate extends LocalizationsDelegate<TextsUtil> {
  final TextsUtil instance;
  const _TestDelegate(this.instance);
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<TextsUtil> load(Locale locale) async => instance;
  @override
  bool shouldReload(covariant LocalizationsDelegate<TextsUtil> old) => false;
}

void main() {
  testWidgets('TextsUtil.of returns instance from context', (WidgetTester tester) async {
    final testUtil = TestTextsUtil(const Locale('es'));
    await testUtil.load();
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('es'),
        delegates: [
          _TestDelegate(testUtil),
          GlobalWidgetsLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            final util = TextsUtil.of(context);
            expect(util, isNotNull);
            expect(util!.getText('login.title'), 'Título');
            return const SizedBox();
          },
        ),
      ),
    );
  });

  test('getText returns null for non-map intermediate', () async {
    final textsUtil = TestTextsUtil(const Locale('es'));
    await textsUtil.load();
    expect(textsUtil.getText('simple.key'), isNull);
  });

  testWidgets('TextsUtilDelegate.load returns loaded instance', (WidgetTester tester) async {
  final testUtil = TestTextsUtil(const Locale('es'));
  await testUtil.load();
  final delegate = _TestDelegate(testUtil);
  final loaded = await delegate.load(const Locale('es'));
  expect(loaded.getText('login.title'), 'Título');
  });

  test('TextsUtil.load sets mLocalizedStrings from mock', () async {
    final textsUtil = TestTextsUtil(const Locale('es'));
    await textsUtil.load();
    expect(textsUtil.mLocalizedStrings, isA<Map<String, dynamic>>());
  });

  test('getText returns nested value', () async {
    final textsUtil = TestTextsUtil(const Locale('es'));
    await textsUtil.load();
    expect(textsUtil.getText('login.title'), 'Título');
    expect(textsUtil.getText('login.subtitle'), 'Subtítulo');
    expect(textsUtil.getText('login.error'), 'Error');
  });

  test('getText returns simple value', () async {
    final textsUtil = TestTextsUtil(const Locale('es'));
    await textsUtil.load();
    expect(textsUtil.getText('simple'), 'Texto simple');
  });

  test('getText returns null for missing key', () async {
    final textsUtil = TestTextsUtil(const Locale('es'));
    await textsUtil.load();
    expect(textsUtil.getText('missing.key'), isNull);
  });

  test('isSupported returns true for supported locales', () {
    expect(TextsUtilDelegate().isSupported(const Locale('es')), isTrue);
    expect(TextsUtilDelegate().isSupported(const Locale('en')), isTrue);
    expect(TextsUtilDelegate().isSupported(const Locale('fr')), isFalse);
  });

  test('shouldReload always returns false', () {
    expect(TextsUtilDelegate().shouldReload(TextsUtilDelegate()), isFalse);
  });
}