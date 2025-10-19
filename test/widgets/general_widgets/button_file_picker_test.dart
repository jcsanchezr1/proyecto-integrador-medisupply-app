import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medisupply_app/src/widgets/general_widgets/button_file_picker.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/poppins_text.dart';

// Mock para FilePicker
class MockFilePicker {
  static FilePickerResult? mockResult;

  static Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    return mockResult;
  }
}

void main() {
  late CreateAccountProvider provider;

  setUp(() {
    provider = CreateAccountProvider();
  });

  tearDown(() {
    MockFilePicker.mockResult = null;
  });

  Widget makeTestableWidget({
    required String label,
    required List<String> allowedExtensions,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CreateAccountProvider>.value(value: provider),
        Provider<TextsUtil>.value(value: TextsUtil(const Locale('es'))..mLocalizedStrings = {
          'transversal': {'upload_button': 'Subir archivo'}
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ButtonFilePicker(
            sLabel: label,
            lAllowedExtensions: allowedExtensions,
            filePickerCallback: MockFilePicker.pickFiles,
          ),
        ),
      ),
    );
  }

  group('ButtonFilePicker Rendering', () {
    testWidgets('renders with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      expect(find.byType(ButtonFilePicker), findsOneWidget);
      expect(find.text('Logo'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.upload_rounded), findsOneWidget);
    });

    testWidgets('displays upload button text', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      expect(find.text('Subir archivo'), findsOneWidget);
    });

    testWidgets('has correct button styling', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      expect(style, isNotNull);
      expect(style!.backgroundColor, isNotNull);
      expect(style.shape, isNotNull);
    });

    testWidgets('has correct initial size', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, isNotNull);
    });
  });

  group('ButtonFilePicker File Selection', () {
    testWidgets('shows image preview when file is selected', (WidgetTester tester) async {
      // Mock successful file selection
      final mockFile = File('test_image.jpg');
      MockFilePicker.mockResult = FilePickerResult([
        PlatformFile(
          name: 'test_image.jpg',
          path: mockFile.path,
          size: 1024,
        )
      ]);

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      // Initially no image should be shown
      expect(find.byType(Image), findsNothing);

      // Tap the upload button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Now image should be shown
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('updates provider when file is selected', (WidgetTester tester) async {
      // Mock successful file selection
      final mockFile = File('test_image.jpg');
      MockFilePicker.mockResult = FilePickerResult([
        PlatformFile(
          name: 'test_image.jpg',
          path: mockFile.path,
          size: 1024,
        )
      ]);

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      // Initially provider should have no logo file
      expect(provider.logoFile, isNull);

      // Tap the upload button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Provider should now have the selected file
      expect(provider.logoFile, isNotNull);
      expect(provider.logoFile!.path, equals(mockFile.path));
    });

    testWidgets('does not show image when file selection is cancelled', (WidgetTester tester) async {
      // Mock cancelled file selection
      MockFilePicker.mockResult = null;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      // Tap the upload button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // No image should be shown
      expect(find.byType(Image), findsNothing);
      expect(provider.logoFile, isNull);
    });

    testWidgets('handles empty file result', (WidgetTester tester) async {
      // Mock empty file result
      MockFilePicker.mockResult = FilePickerResult([]);

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg', 'png'],
      ));

      // Tap the upload button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // No image should be shown
      expect(find.byType(Image), findsNothing);
      expect(provider.logoFile, isNull);
    });
  });

  group('ButtonFilePicker File Types', () {
    testWidgets('accepts different file extensions', (WidgetTester tester) async {
      final extensions = ['jpg', 'png', 'jpeg', 'gif'];

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: extensions,
      ));

      // The widget should render without issues with different extensions
      expect(find.byType(ButtonFilePicker), findsOneWidget);
    });

    testWidgets('works with single extension', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['pdf'],
      ));

      expect(find.byType(ButtonFilePicker), findsOneWidget);
    });

    testWidgets('works with empty extensions list', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: [],
      ));

      expect(find.byType(ButtonFilePicker), findsOneWidget);
    });
  });

  group('ButtonFilePicker Layout', () {
    testWidgets('displays label above button', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Upload Logo',
        allowedExtensions: ['jpg'],
      ));

      // Find the column containing label and button
      final column = tester.widget<Column>(find.byType(Column).first);

      // First child should be the label (PoppinsText)
      expect(column.children[0], isA<PoppinsText>());
      // Second child should be SizedBox
      expect(column.children[1], isA<SizedBox>());
      // Third child should be ElevatedButton
      expect(column.children[2], isA<ElevatedButton>());
    });

    testWidgets('image preview has correct dimensions', (WidgetTester tester) async {
      // Mock successful file selection
      final mockFile = File('test_image.jpg');
      MockFilePicker.mockResult = FilePickerResult([
        PlatformFile(
          name: 'test_image.jpg',
          path: mockFile.path,
          size: 1024,
        )
      ]);

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg'],
      ));

      // Select file
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find the image container
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints!.maxWidth, isNotNull);
      expect(container.constraints!.maxHeight, isNotNull);
    });

    testWidgets('image preview is positioned to the right of button', (WidgetTester tester) async {
      // Mock successful file selection
      final mockFile = File('test_image.jpg');
      MockFilePicker.mockResult = FilePickerResult([
        PlatformFile(
          name: 'test_image.jpg',
          path: mockFile.path,
          size: 1024,
        )
      ]);

      await tester.pumpWidget(makeTestableWidget(
        label: 'Logo',
        allowedExtensions: ['jpg'],
      ));

      // Select file
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find the Row containing button and image (child of SizedBox)
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      final row = sizedBox.child as Row;
      expect(row.children.length, equals(2));
      expect(row.children[0], isA<Expanded>()); // Button column wrapped in Expanded
      expect(row.children[1], isA<Container>()); // Image container
    });
  });
}