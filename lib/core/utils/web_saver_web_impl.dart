import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> saveFile(List<int> bytes, String fileName) async {
  // Convert List<int> to Uint8List for JS interop
  final uint8List = Uint8List.fromList(bytes);

  // Create a Blob from the bytes
  final blob = web.Blob([uint8List.toJS].toJS);

  // Create an object URL from the blob
  final url = web.URL.createObjectURL(blob);

  // Create an anchor element
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.style.display = 'none';

  // Add to document, click, and remove
  web.document.body?.appendChild(anchor);
  anchor.click();
  web.document.body?.removeChild(anchor);

  // Clean up the object URL
  web.URL.revokeObjectURL(url);
}
