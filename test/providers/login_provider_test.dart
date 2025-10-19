import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';

void main() {
  group(
    'LoginProvider', () {
      test(
        'bLoading should toggle correctly', () {
          final provider = LoginProvider();

          expect(provider.bLoading, false);

          provider.bLoading = true;
          expect(provider.bLoading, true);

          provider.bLoading = false;
          expect(provider.bLoading, false);
        }
      );
    }
  );
  
}