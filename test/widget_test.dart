import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2_l1_alan_reyes/main.dart';

void main() {
  Future<void> iniciar(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PanelHabitos()));
  }

  Future<void> tocar(WidgetTester tester, String clave) async {
    final elemento = find.byKey(Key(clave));
    await tester.ensureVisible(elemento);
    await tester.tap(elemento);
    await tester.pumpAndSettle();
  }

  testWidgets('progreso, mensajes, meta e índices conservados en enfoque', (
    tester,
  ) async {
    await iniciar(tester);
    expect(find.text('0% · ¡Empecemos!'), findsOneWidget);
    await tocar(tester, 'habito_0');
    await tocar(tester, 'habito_1');
    expect(find.text('Cumplidos: 2 / 5'), findsOneWidget);
    expect(find.text('40% · Buen inicio'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .4,
    );
    final slider = tester.widget<Slider>(find.byKey(const Key('metaSlider')));
    slider.onChanged!(2);
    await tester.pumpAndSettle();
    expect(find.text('Meta alcanzada'), findsOneWidget);
    slider.onChanged!(5);
    await tester.pumpAndSettle();
    expect(find.text('Meta alcanzada'), findsNothing);
    await tocar(tester, 'enfoqueSwitch');
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    expect(find.byKey(const Key('habito_0')), findsNothing);
    await tocar(tester, 'habito_3');
    await tocar(tester, 'enfoqueSwitch');
    expect(find.byType(CheckboxListTile), findsNWidgets(5));
    expect(
      tester.widget<CheckboxListTile>(find.byKey(const Key('habito_3'))).value,
      true,
    );
    await tocar(tester, 'habito_2');
    await tocar(tester, 'habito_4');
    expect(find.text('100% · ¡Día completado! 🎉'), findsOneWidget);
    await tocar(tester, 'habito_0');
    expect(find.text('80% · ¡Vas muy bien!'), findsOneWidget);
  });
  testWidgets('nota por botón y teclado, trim y reinicio completo', (
    tester,
  ) async {
    await iniciar(tester);
    await tocar(tester, 'habito_1');
    await tocar(tester, 'enfoqueSwitch');
    final campo = find.byKey(const Key('notaCampo'));
    await tester.ensureVisible(campo);
    await tester.enterText(campo, '  Día productivo  ');
    await tocar(tester, 'guardarNota');
    expect(
      tester.widget<Text>(find.byKey(const Key('notaGuardada'))).data,
      'Día productivo',
    );
    await tester.enterText(campo, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Sin nota'), findsOneWidget);
    await tester.enterText(campo, 'Otra nota');
    await tocar(tester, 'guardarNota');
    await tocar(tester, 'reiniciar');
    expect(find.text('0% · ¡Empecemos!'), findsOneWidget);
    expect(find.text('Meta: 3 hábitos'), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('enfoqueSwitch')))
          .value,
      false,
    );
    expect(find.byType(CheckboxListTile), findsNWidgets(5));
    expect(find.text('Sin nota'), findsOneWidget);
    expect(tester.widget<TextField>(campo).controller!.text, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('sin overflow en vertical, horizontal, teclado y texto grande', (
    tester,
  ) async {
    for (final tamano in [const Size(320, 640), const Size(800, 360)]) {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: tamano,
              viewInsets: const EdgeInsets.only(bottom: 220),
              textScaler: TextScaler.linear(1.5),
            ),
            child: const PanelHabitos(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('notaCampo')));
      await tester.enterText(
        find.byKey(const Key('notaCampo')),
        'Texto de prueba',
      );
      await tester.ensureVisible(find.byKey(const Key('reiniciar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
