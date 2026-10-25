import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/funcionalidades/configuracion/pantalla_configuracion.dart';
import 'package:rompecabezas/funcionalidades/instrucciones/pantalla_instrucciones.dart';
import 'package:rompecabezas/funcionalidades/juego/pantalla_juego.dart';
import 'package:rompecabezas/funcionalidades/marcadores/pantalla_marcadores.dart';
import 'package:rompecabezas/funcionalidades/menu/pantalla_menu_principal.dart';
import 'package:rompecabezas/funcionalidades/presentacion/pantalla_presentacion.dart';
import 'package:rompecabezas/nucleo/ajustes/ajustes_aplicacion.dart';
import 'package:rompecabezas/nucleo/ajustes/proveedor_ajustes.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/records/almacen_records.dart';
import 'package:rompecabezas/nucleo/records/proveedor_records.dart';
import 'package:rompecabezas/nucleo/records/records_dificultad.dart';
import 'package:rompecabezas/nucleo/records/servicio_records.dart';
import 'package:rompecabezas/nucleo/tema/tema_aplicacion.dart';

/// Tamaños de ventana representativos: móvil pequeño y normal, móvil en
/// horizontal, tablet vertical y escritorio.
const _tamanos = <String, Size>{
  'móvil pequeño 320×568': Size(320, 568),
  'móvil 360×640': Size(360, 640),
  'móvil horizontal 640×320': Size(640, 320),
  'tablet 768×1024': Size(768, 1024),
  'escritorio 1280×800': Size(1280, 800),
};

ServicioRecords _servicioConDatos() {
  final servicio = ServicioRecords(AlmacenRecordsMemoria());
  for (final dificultad in Dificultad.values) {
    servicio.registrar(ResultadoPartida(
      dificultad: dificultad,
      tiempo: const Duration(minutes: 12, seconds: 34),
      movimientos: 1234,
      fecha: DateTime(2026, 10, 5),
    ));
  }
  return servicio;
}

Widget _envolver(Widget pantalla, {required ThemeMode modo}) {
  return ProveedorAjustes(
    ajustes: AjustesAplicacion(),
    child: ProveedorRecords(
      servicio: _servicioConDatos(),
      child: MaterialApp(
        theme: TemaAplicacion.claro,
        darkTheme: TemaAplicacion.oscuro,
        themeMode: modo,
        home: pantalla,
      ),
    ),
  );
}

void main() {
  final pantallas = <String, Widget Function()>{
    'presentación': () => const PantallaPresentacion(),
    'menú': () => const PantallaMenuPrincipal(),
    'configuración': () => const PantallaConfiguracion(),
    'marcadores': () => const PantallaMarcadores(),
    'instrucciones': () => const PantallaInstrucciones(),
    'juego fácil': () => PantallaJuego(
          key: UniqueKey(),
          dificultad: Dificultad.facil,
        ),
    'juego medio': () => PantallaJuego(
          key: UniqueKey(),
          dificultad: Dificultad.medio,
        ),
    'juego difícil': () => PantallaJuego(
          key: UniqueKey(),
          dificultad: Dificultad.dificil,
        ),
  };

  for (final modo in [ThemeMode.light, ThemeMode.dark]) {
    for (final tamano in _tamanos.entries) {
      testWidgets(
          'ninguna pantalla se desborda: ${tamano.key}, tema '
          '${modo == ThemeMode.light ? 'claro' : 'oscuro'}', (tester) async {
        tester.view.physicalSize = tamano.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        for (final pantalla in pantallas.entries) {
          await tester.pumpWidget(_envolver(pantalla.value(), modo: modo));
          await tester.pump(const Duration(milliseconds: 1300));
          expect(
            tester.takeException(),
            isNull,
            reason: 'Excepción en "${pantalla.key}" a ${tamano.key}',
          );
          // Se desmonta para cancelar temporizadores (p. ej. la presentación).
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  }

  testWidgets('un espacio mínimo no rompe el tablero', (tester) async {
    tester.view.physicalSize = const Size(200, 120);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_envolver(
      PantallaJuego(dificultad: Dificultad.dificil),
      modo: ThemeMode.light,
    ));
    await tester.pump();
    // Puede haber desbordes de otros widgets en una ventana tan diminuta, pero
    // el cálculo del tablero no debe producir tamaños negativos.
    final excepcion = tester.takeException();
    expect(
      excepcion.toString().contains('negative'),
      isFalse,
      reason: 'El tablero produjo un tamaño negativo: $excepcion',
    );
  });
}
