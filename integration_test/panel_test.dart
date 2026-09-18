import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:e2_l1_alan_reyes/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('recorrido real Android y seis capturas', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    Future<void> tocar(String clave) async {
      final f = find.byKey(Key(clave));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> captura(String nombre, {bool arriba = true}) async {
      if (arriba) {
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(seconds: 1));
      await binding.takeScreenshot(nombre);
    }

    await captura('01-inicio');
    await tocar('habito_0');
    await tocar('habito_1');
    expect(find.text('40% · Buen inicio'), findsOneWidget);
    await captura('02-parcial');
    await tocar('enfoqueSwitch');
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    await captura('03-enfoque');
    await tocar('enfoqueSwitch');
    expect(find.byType(CheckboxListTile), findsNWidgets(5));
    await tocar('habito_2');
    await tocar('habito_3');
    await tocar('habito_4');
    expect(find.text('100% · ¡Día completado! 🎉'), findsOneWidget);
    await captura('04-completo');
    await tocar('habito_4');
    expect(find.text('80% · ¡Vas muy bien!'), findsOneWidget);
    final campo = find.byKey(const Key('notaCampo'));
    await tester.ensureVisible(campo);
    await tester.enterText(campo, '  Día productivo  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('notaGuardada'))).data,
      'Día productivo',
    );
    await tester.ensureVisible(find.byKey(const Key('reiniciar')));
    await tester.pumpAndSettle();
    await captura('05-nota', arriba: false);
    await tester.ensureVisible(campo);
    await tester.tap(campo);
    await tester.pumpAndSettle();
    await tester.enterText(campo, ' ');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(campo).controller!.text.trim(), isEmpty);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tocar('guardarNota');
    expect(find.text('Sin nota'), findsOneWidget);
    await tocar('reiniciar');
    expect(find.text('0% · ¡Empecemos!'), findsOneWidget);
    expect(find.text('Meta: 3 hábitos'), findsOneWidget);
    await captura('06-reinicio');
  });
}
