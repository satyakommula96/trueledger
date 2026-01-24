import 'web_saver_stub.dart' if (dart.library.html) 'web_saver_web_impl.dart'
    as impl;

Future<void> saveFileWeb(List<int> bytes, String fileName) =>
    impl.saveFile(bytes, fileName);
