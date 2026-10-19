import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/aplicacion.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/logica/tablero.dart';
import 'package:rompecabezas/nucleo/records/almacen_records.dart';

import '../ayudas/resolutor.dart';

/// Reconstruye el tablero que se ve en pantalla a partir de la posición de
/// cada ficha.
Tablero _leerTablero(WidgetTester tester, int n) {
  final posiciones = <int, Offset>{
    for (var v = 1; v < n * n; v++)
      v: tester.getTopLeft(find.byKey(ValueKey('ficha_$v'))),
  };
  final columnas = posiciones.values.map((o) => o.dx).toSet().toList()..sort();
  final filas = posiciones.values.map((o) => o.dy).toSet().toList()..sort();
  expect(columnas.length, n);
  expect(filas.length, n);

  final fichas = List<int>.filled(n * n, Tablero.valorVacio);
  posiciones.forEach((valor, posicion) {
    fichas[filas.indexOf(posicion.dy) * n + columnas.indexOf(posicion.dx)] =
        valor;
  });
  return Tablero.desde(n, fichas);
}

String? _texto(WidgetTester tester, String clave) =>
    tester.widget<Text>(find.byKey(Key(clave))).data;

Finder _enDialogo(String texto) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(texto),
    );

void main() {
  testWidgets(
      'flujo completo: presentación → menú → partida real → victoria → '
      'récord guardado → marcadores → borrar', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final almacen = AlmacenRecordsMemoria();
    await tester.pumpWidget(AplicacionRompecabezas(almacenRecords: almacen));

    // 1. Presentación → menú.
    expect(find.text('15-Puzzle Flutter'), findsOneWidget);
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);

    // 2. Marcadores vacíos y vuelta al menú.
    await tester.tap(find.text('Marcadores'));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no hay récords'), findsOneWidget);
    await tester.tap(find.text('Volver al menú'));
    await tester.pumpAndSettle();

    // 3. Jugar → elegir dificultad → tablero.
    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fácil'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar · Fácil (3×3)'), findsOneWidget);
    expect(_texto(tester, 'movimientos'), '0');

    // 4. Resolver la partida con movimientos reales.
    var tablero = _leerTablero(tester, 3);
    expect(tablero.esResoluble, isTrue);
    final pasos = resolver(tablero);
    for (final indice in pasos) {
      final valor = tablero.fichas[indice];
      await tester.tap(find.byKey(ValueKey('ficha_$valor')));
      await tester.pumpAndSettle();
      tablero = tablero.mover(indice)!;
    }
    expect(tablero.estaResuelto, isTrue);
    expect(_texto(tester, 'movimientos'), '${pasos.length}');

    // 5. Diálogo de victoria con nuevo récord.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('¡Nuevo récord!'), findsOneWidget);
    expect(_texto(tester, 'resumen_movimientos'), '${pasos.length}');
    expect(_texto(tester, 'resumen_dificultad'), 'Fácil (3×3)');
    expect(
      almacen.datos[Dificultad.facil]?.menosMovimientos,
      pasos.length,
    );

    // 6. Volver al menú y ver el récord en Marcadores.
    await tester.tap(_enDialogo('Menú principal'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);

    await tester.tap(find.text('Marcadores'));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos_facil'), '${pasos.length}');
    expect(find.text('Aún sin récord'), findsNWidgets(2));

    // 7. Borrar con confirmación.
    await tester.tap(find.byKey(const Key('borrar_marcadores')));
    await tester.pumpAndSettle();
    await tester.tap(_enDialogo('Borrar'));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no hay récords'), findsOneWidget);
    expect(almacen.datos, isEmpty);
  });

  testWidgets('la dificultad elegida en Configuración llega a la partida',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AplicacionRompecabezas(almacenRecords: AlmacenRecordsMemoria()),
    );
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Difícil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retro'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // El selector de Jugar llega con la dificultad de Configuración marcada.
    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    final opcion = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Difícil'),
    );
    expect(opcion.selected, isTrue);

    await tester.tap(find.text('Difícil'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar · Difícil (5×5)'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey &&
            '${(w.key as ValueKey).value}'.startsWith('ficha_'),
      ),
      findsNWidgets(24),
    );
  });
}
