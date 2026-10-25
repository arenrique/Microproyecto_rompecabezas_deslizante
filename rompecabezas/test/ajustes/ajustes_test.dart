import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/ajustes/ajustes_aplicacion.dart';
import 'package:rompecabezas/nucleo/ajustes/estilo_ficha.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';

void main() {
  group('AjustesAplicacion', () {
    test('valores por defecto', () {
      final ajustes = AjustesAplicacion();
      expect(ajustes.dificultad, Dificultad.medio);
      expect(ajustes.modoTema, ThemeMode.system);
      expect(ajustes.estiloFichas, EstiloFicha.clasico);
      expect(ajustes.animacionesActivas, isTrue);
      expect(ajustes.sonidoActivo, isFalse);
    });

    test('notifica al cambiar cada ajuste', () {
      final ajustes = AjustesAplicacion();
      var avisos = 0;
      ajustes.addListener(() => avisos++);

      ajustes.establecerDificultad(Dificultad.dificil);
      ajustes.establecerModoTema(ThemeMode.dark);
      ajustes.establecerEstiloFichas(EstiloFicha.retro);
      ajustes.establecerAnimaciones(false);
      ajustes.establecerSonido(true);

      expect(avisos, 5);
      expect(ajustes.dificultad, Dificultad.dificil);
      expect(ajustes.modoTema, ThemeMode.dark);
      expect(ajustes.estiloFichas, EstiloFicha.retro);
      expect(ajustes.animacionesActivas, isFalse);
      expect(ajustes.sonidoActivo, isTrue);
    });

    test('no notifica si el valor no cambia', () {
      final ajustes = AjustesAplicacion();
      var avisos = 0;
      ajustes.addListener(() => avisos++);
      ajustes.establecerDificultad(Dificultad.medio);
      ajustes.establecerModoTema(ThemeMode.system);
      expect(avisos, 0);
    });
  });
}
