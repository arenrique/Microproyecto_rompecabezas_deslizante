import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/funcionalidades/juego/pantalla_juego.dart';
import 'package:rompecabezas/nucleo/ajustes/ajustes_aplicacion.dart';
import 'package:rompecabezas/nucleo/ajustes/estilo_ficha.dart';
import 'package:rompecabezas/nucleo/ajustes/proveedor_ajustes.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/logica/partida.dart';
import 'package:rompecabezas/nucleo/logica/tablero.dart';
import 'package:rompecabezas/nucleo/records/almacen_records.dart';
import 'package:rompecabezas/nucleo/records/proveedor_records.dart';
import 'package:rompecabezas/nucleo/records/records_dificultad.dart';
import 'package:rompecabezas/nucleo/records/servicio_records.dart';

/// Tablero 3×3 a dos movimientos de ganar: [1,2,3,4,0,6,7,5,8].
Partida _partidaADosMovimientos(DateTime Function() reloj) {
  return Partida(
    dificultad: Dificultad.facil,
    tableroInicial: Tablero.resuelto(3).mover(7)!.mover(4)!,
    reloj: reloj,
  );
}

Widget _envolver(
  Widget hijo, {
  AjustesAplicacion? ajustes,
  ServicioRecords? servicio,
}) {
  return ProveedorAjustes(
    ajustes: ajustes ?? AjustesAplicacion(),
    child: ProveedorRecords(
      servicio: servicio ?? ServicioRecords(AlmacenRecordsMemoria()),
      child: MaterialApp(home: hijo),
    ),
  );
}

Widget _app(
  Partida partida, {
  AjustesAplicacion? ajustes,
  ServicioRecords? servicio,
}) {
  return _envolver(
    PantallaJuego(dificultad: Dificultad.facil, partidaInicial: partida),
    ajustes: ajustes,
    servicio: servicio,
  );
}

/// Pantalla de partida abierta desde un botón, para poder volver "al menú".
Widget _appConMenu(Partida partida, {ServicioRecords? servicio}) {
  return _envolver(
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PantallaJuego(
                  dificultad: Dificultad.facil,
                  partidaInicial: partida,
                ),
              ),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
    servicio: servicio,
  );
}

String? _texto(WidgetTester tester, String clave) {
  return tester.widget<Text>(find.byKey(Key(clave))).data;
}

Finder _ficha(int valor) => find.byKey(ValueKey('ficha_$valor'));

Finder _enDialogo(String texto) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(texto),
    );

/// Resuelve la partida de dos movimientos y espera a que salga el diálogo.
Future<void> _ganar(WidgetTester tester) async {
  await tester.tap(_ficha(5));
  await tester.pumpAndSettle();
  await tester.tap(_ficha(8));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('se puede jugar de principio a fin y se detecta la victoria',
      (tester) async {
    final almacen = AlmacenRecordsMemoria();
    final servicio = ServicioRecords(almacen);
    await tester.pumpWidget(
      _app(_partidaADosMovimientos(DateTime.now), servicio: servicio),
    );

    expect(_texto(tester, 'movimientos'), '0');
    expect(_texto(tester, 'tiempo'), '00:00');

    // Una ficha no adyacente al vacío no hace nada.
    await tester.tap(_ficha(1));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos'), '0');

    await tester.tap(_ficha(5));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos'), '1');
    expect(_texto(tester, 'estado_partida'), 'Partida en curso');

    await tester.tap(_ficha(8));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos'), '2');
    expect(_texto(tester, 'estado_partida'), '¡Resuelto! ¡Nuevo récord!');
    expect(servicio.recordsDe(Dificultad.facil).menosMovimientos, 2);
    expect(almacen.datos[Dificultad.facil]?.menosMovimientos, 2);

    // Se deja pasar la espera del diálogo y se cierra.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('¡Ganaste!'), findsOneWidget);
    await tester.tap(_enDialogo('Reiniciar'));
    await tester.pumpAndSettle();
  });

  testWidgets('el diálogo de victoria muestra el resumen y el nuevo récord',
      (tester) async {
    await tester.pumpWidget(_app(_partidaADosMovimientos(DateTime.now)));
    await _ganar(tester);

    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('¡Nuevo récord!'), findsOneWidget);
    expect(_texto(tester, 'resumen_movimientos'), '2');
    expect(_texto(tester, 'resumen_dificultad'), 'Fácil (3×3)');
    expect(find.byKey(const Key('resumen_tiempo')), findsOneWidget);
    expect(_enDialogo('Reiniciar'), findsOneWidget);
    expect(_enDialogo('Menú principal'), findsOneWidget);
  });

  testWidgets('empatar el récord no lo marca como nuevo ni lo reemplaza',
      (tester) async {
    final ahora = DateTime(2026, 1, 1); // reloj fijo: la partida dura 0 s
    final servicio = ServicioRecords(AlmacenRecordsMemoria());
    servicio.registrar(ResultadoPartida(
      dificultad: Dificultad.facil,
      tiempo: Duration.zero,
      movimientos: 1,
      fecha: DateTime(2026, 9, 1),
    ));
    await tester.pumpWidget(
      _app(_partidaADosMovimientos(() => ahora), servicio: servicio),
    );
    await _ganar(tester);

    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('¡Nuevo récord!'), findsNothing);
    final records = servicio.recordsDe(Dificultad.facil);
    expect(records.menosMovimientos, 1);
    expect(records.fechaMejorTiempo, DateTime(2026, 9, 1));
  });

  testWidgets('Reiniciar desde el diálogo empieza una partida nueva',
      (tester) async {
    await tester.pumpWidget(_app(_partidaADosMovimientos(DateTime.now)));
    await _ganar(tester);

    await tester.tap(_enDialogo('Reiniciar'));
    await tester.pumpAndSettle();

    expect(find.text('¡Ganaste!'), findsNothing);
    expect(_texto(tester, 'movimientos'), '0');
    expect(_texto(tester, 'tiempo'), '00:00');
    expect(
      _texto(tester, 'estado_partida'),
      'Toca una ficha junto al espacio vacío para empezar',
    );
  });

  testWidgets('Menú principal en el diálogo vuelve a la pantalla anterior',
      (tester) async {
    await tester.pumpWidget(
      _appConMenu(_partidaADosMovimientos(DateTime.now)),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await _ganar(tester);
    await tester.tap(_enDialogo('Menú principal'));
    await tester.pumpAndSettle();

    expect(find.text('Abrir'), findsOneWidget);
    expect(find.text('¡Ganaste!'), findsNothing);
  });

  testWidgets('salir en plena partida pide confirmación', (tester) async {
    await tester.pumpWidget(
      _appConMenu(_partidaADosMovimientos(DateTime.now)),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.tap(_ficha(5));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('¿Salir de la partida?'), findsOneWidget);

    await tester.tap(find.text('Seguir jugando'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir'), findsNothing); // sigue en la partida

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir'), findsOneWidget);
  });

  testWidgets('salir antes de empezar no pide confirmación', (tester) async {
    await tester.pumpWidget(
      _appConMenu(_partidaADosMovimientos(DateTime.now)),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('¿Salir de la partida?'), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });

  testWidgets('el cronómetro muestra el tiempo desde el primer movimiento',
      (tester) async {
    var ahora = DateTime(2026, 1, 1);
    await tester.pumpWidget(_app(_partidaADosMovimientos(() => ahora)));

    await tester.tap(_ficha(5));
    await tester.pump();
    ahora = ahora.add(const Duration(seconds: 65));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_texto(tester, 'tiempo'), '01:05');

    // Se desmonta la pantalla para cancelar el temporizador.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reiniciar en plena partida pide confirmación', (tester) async {
    await tester.pumpWidget(_app(_partidaADosMovimientos(DateTime.now)));

    await tester.tap(_ficha(5));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos'), '1');

    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Reiniciar la partida?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos'), '1');

    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();
    await tester.tap(_enDialogo('Reiniciar'));
    await tester.pumpAndSettle();
    expect(_texto(tester, 'movimientos'), '0');
    expect(_texto(tester, 'tiempo'), '00:00');
    expect(
      _texto(tester, 'estado_partida'),
      'Toca una ficha junto al espacio vacío para empezar',
    );
  });

  testWidgets('el tablero se dibuja sin desbordes en los tres tamaños '
      'y en pantallas distintas', (tester) async {
    addTearDown(tester.view.reset);
    const pantallas = [Size(360, 640), Size(800, 600), Size(1280, 800)];
    for (final pantalla in pantallas) {
      tester.view.physicalSize = pantalla;
      tester.view.devicePixelRatio = 1;
      for (final dificultad in Dificultad.values) {
        await tester.pumpWidget(_envolver(
          PantallaJuego(key: UniqueKey(), dificultad: dificultad),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey &&
                '${(w.key as ValueKey).value}'.startsWith('ficha_'),
          ),
          findsNWidgets(dificultad.cantidadFichas),
        );
      }
    }
  });

  testWidgets('todos los estilos de ficha se dibujan sin errores',
      (tester) async {
    for (final estilo in EstiloFicha.values) {
      final ajustes = AjustesAplicacion()..establecerEstiloFichas(estilo);
      await tester.pumpWidget(_app(
        _partidaADosMovimientos(DateTime.now),
        ajustes: ajustes,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_ficha(1), findsOneWidget);
    }
  });

  testWidgets('con las animaciones desactivadas la ficha llega al instante',
      (tester) async {
    final ajustes = AjustesAplicacion()..establecerAnimaciones(false);
    await tester.pumpWidget(_app(
      _partidaADosMovimientos(DateTime.now),
      ajustes: ajustes,
    ));
    final antes = tester.getTopLeft(_ficha(5));
    await tester.tap(_ficha(5));
    await tester.pump(); // un solo fotograma, sin esperar animación
    expect(tester.getTopLeft(_ficha(5)), isNot(antes));

    await tester.pumpWidget(const SizedBox());
  });
}
