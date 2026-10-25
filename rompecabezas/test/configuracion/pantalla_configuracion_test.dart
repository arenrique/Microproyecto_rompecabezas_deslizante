import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/aplicacion.dart';
import 'package:rompecabezas/funcionalidades/configuracion/pantalla_configuracion.dart';
import 'package:rompecabezas/nucleo/ajustes/ajustes_aplicacion.dart';
import 'package:rompecabezas/nucleo/ajustes/estilo_ficha.dart';
import 'package:rompecabezas/nucleo/ajustes/proveedor_ajustes.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';

void main() {
  void usarPantallaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('los controles modifican los ajustes', (tester) async {
    usarPantallaAlta(tester);
    final ajustes = AjustesAplicacion();
    await tester.pumpWidget(
      ProveedorAjustes(
        ajustes: ajustes,
        child: const MaterialApp(home: PantallaConfiguracion()),
      ),
    );

    await tester.tap(find.text('Difícil'));
    await tester.pumpAndSettle();
    expect(ajustes.dificultad, Dificultad.dificil);
    expect(find.textContaining('5×5 · 24 fichas'), findsOneWidget);

    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(ajustes.modoTema, ThemeMode.dark);

    await tester.tap(find.text('Retro'));
    await tester.pumpAndSettle();
    expect(ajustes.estiloFichas, EstiloFicha.retro);

    await tester.tap(find.byKey(const Key('interruptor_animaciones')));
    await tester.pumpAndSettle();
    expect(ajustes.animacionesActivas, isFalse);

    await tester.tap(find.byKey(const Key('interruptor_sonido')));
    await tester.pumpAndSettle();
    expect(ajustes.sonidoActivo, isTrue);
  });

  testWidgets('cambiar el tema en Configuración se aplica a la app entera',
      (tester) async {
    usarPantallaAlta(tester);
    await tester.pumpWidget(const AplicacionRompecabezas());
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
