import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/utils/web_saver.dart';

void main() {
  test('saveFileWeb should not throw on non-web platform', () async {
    // On non-web platform, this calls the stub which is a no-op Future.
    // This provides coverage for the stub and the entry point.
    await expectLater(saveFileWeb([1, 2, 3], 'test.txt'), completes);
  });
}
