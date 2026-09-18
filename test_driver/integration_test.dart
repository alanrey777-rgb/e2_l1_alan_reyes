import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      final capturas = data?['screenshots'] as List<dynamic>? ?? [];
      await Directory('docs/capturas').create(recursive: true);
      for (final captura in capturas) {
        final nombre = captura['screenshotName'] as String;
        await File('docs/capturas/$nombre.png')
            .writeAsBytes(List<int>.from(captura['bytes'] as List));
      }
    },
  );
}
