// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:convert';

Future<void> saveFile(List<int> bytes, String fileName) async {
  final base64 = base64Encode(bytes);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = 'data:application/json;base64,$base64';
  anchor.download = fileName;
  anchor.target = '_blank';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
