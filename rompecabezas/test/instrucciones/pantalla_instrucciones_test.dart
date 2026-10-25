import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/funcionalidades/instrucciones/pantalla_instrucciones.dart';

void main() {
  testWidgets('explica objetivo, movimientos, victoria y que no se pierde',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PantallaInstrucciones()));

    expect(find.text('Objetivo'), findsOneWidget);
    expect(find.textContaining('espacio vacío para deslizar'), findsOneWidget);
    expect(find.text('Cómo mover las fichas'), findsOneWidget);
    expect(find.textContaining('ni en diagonal'), findsOneWidget);
    expect(find.text('Cómo se gana'), findsOneWidget);
    expect(find.textContaining('de izquierda a derecha'), findsOneWidget);
    expect(find.text('¿Se puede perder?'), findsOneWidget);
    expect(find.textContaining('No hay límite de tiempo'), findsOneWidget);
    expect(find.textContaining('Fácil: 3×3 (8 fichas)'), findsOneWidget);
    expect(find.text('Volver al menú'), findsOneWidget);
  });

  testWidgets('se ve sin desbordes en una pantalla estrecha', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PantallaInstrucciones()));
    expect(tester.takeException(), isNull);
  });
}
