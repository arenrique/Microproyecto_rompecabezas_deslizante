import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/funcionalidades/marcadores/pantalla_marcadores.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/records/almacen_records.dart';
import 'package:rompecabezas/nucleo/records/proveedor_records.dart';
import 'package:rompecabezas/nucleo/records/records_dificultad.dart';
import 'package:rompecabezas/nucleo/records/servicio_records.dart';

Widget _app(ServicioRecords servicio) {
  return ProveedorRecords(
    servicio: servicio,
    child: const MaterialApp(home: PantallaMarcadores()),
  );
}

String? _texto(WidgetTester tester, String clave) =>
    tester.widget<Text>(find.byKey(Key(clave))).data;

void main() {
  void usarPantallaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('sin récords muestra un mensaje amable y no deja borrar',
      (tester) async {
    usarPantallaAlta(tester);
    await tester.pumpWidget(_app(ServicioRecords(AlmacenRecordsMemoria())));

    expect(find.text('Todavía no hay récords'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('borrar_marcadores')))
          .onPressed,
      isNull,
    );
    expect(find.text('Volver al menú'), findsOneWidget);
  });

  testWidgets('con récords muestra tiempo, movimientos y fecha por dificultad',
      (tester) async {
    usarPantallaAlta(tester);
    final servicio = ServicioRecords(AlmacenRecordsMemoria());
    servicio.registrar(ResultadoPartida(
      dificultad: Dificultad.facil,
      tiempo: const Duration(seconds: 75),
      movimientos: 42,
      fecha: DateTime(2026, 10, 5),
    ));
    await tester.pumpWidget(_app(servicio));

    expect(find.text('Todavía no hay récords'), findsNothing);
    expect(_texto(tester, 'tiempo_facil'), '01:15');
    expect(_texto(tester, 'movimientos_facil'), '42');
    expect(find.text('05/10/2026'), findsNWidgets(2));
    // Las demás dificultades indican que aún no tienen récord.
    expect(find.text('Aún sin récord'), findsNWidgets(2));
  });

  testWidgets('borrar pide confirmación y se puede cancelar', (tester) async {
    usarPantallaAlta(tester);
    final servicio = ServicioRecords(AlmacenRecordsMemoria());
    servicio.registrar(ResultadoPartida(
      dificultad: Dificultad.medio,
      tiempo: const Duration(seconds: 30),
      movimientos: 50,
      fecha: DateTime(2026, 10, 5),
    ));
    await tester.pumpWidget(_app(servicio));

    await tester.tap(find.byKey(const Key('borrar_marcadores')));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar todos los marcadores?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(servicio.hayRecords, isTrue);
    expect(_texto(tester, 'movimientos_medio'), '50');
  });

  testWidgets('confirmar el borrado elimina los récords y vuelve el aviso',
      (tester) async {
    usarPantallaAlta(tester);
    final almacen = AlmacenRecordsMemoria();
    final servicio = ServicioRecords(almacen);
    servicio.registrar(ResultadoPartida(
      dificultad: Dificultad.medio,
      tiempo: const Duration(seconds: 30),
      movimientos: 50,
      fecha: DateTime(2026, 10, 5),
    ));
    await tester.pumpWidget(_app(servicio));

    await tester.tap(find.byKey(const Key('borrar_marcadores')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();

    expect(servicio.hayRecords, isFalse);
    expect(almacen.datos, isEmpty);
    expect(find.text('Todavía no hay récords'), findsOneWidget);
  });
}
