import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/utils/responsive_app.dart';

void main() {
  testWidgets('ResponsiveApp init sets scale factors', (WidgetTester tester) async {
    final testKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Container(key: testKey),
    ));
    ResponsiveApp.init(testKey.currentContext!, 400, 800);
    expect(ResponsiveApp.dWidthScreen(), greaterThan(0));
    expect(ResponsiveApp.dHeightScreen(), greaterThan(0));
    expect(ResponsiveApp.dAspectRatio(), greaterThan(0));
    expect(ResponsiveApp.dLongDim(), greaterThan(0));
    expect(ResponsiveApp.dShortDim(), greaterThan(0));
  });

  test('dSize returns scaled value', () {
    ResponsiveApp.nScaleFactor = 2;
    expect(ResponsiveApp.dSize(10), 20);
  });

  test('dHeight and dWidth return scaled values', () {
  ResponsiveApp.nHeightScaleFactor = 2;
  ResponsiveApp.nWidthScaleFactor = 3;
  ResponsiveApp.nAspectRatio = 1;
  ResponsiveApp.nWidthScreen = 400; // Forzar bTablet a false
  ResponsiveApp.nHeightScreen = 800;
  expect(ResponsiveApp.dHeight(10), 20);
  expect(ResponsiveApp.dWidth(10), 30);
  });

  test('bTablet returns true for tablet-like dimensions', () {
    ResponsiveApp.nWidthScreen = 800;
    ResponsiveApp.nHeightScreen = 600;
    ResponsiveApp.nAspectRatio = 0.7;
    expect(ResponsiveApp.bTablet(), isTrue);
  });

  test('bTablet returns false for non-tablet', () {
    ResponsiveApp.nWidthScreen = 400;
    ResponsiveApp.nHeightScreen = 800;
    ResponsiveApp.nAspectRatio = 0.5;
    expect(ResponsiveApp.bTablet(), isFalse);
  });
}
