import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/logica/partida.dart';
import 'package:rompecabezas/nucleo/logica/tablero.dart';

/// Tablero 3×3 a dos movimientos de ganar: [1,2,3,4,0,6,7,5,8].
Tablero _tableroADosMovimientos() {
  return Tablero.resuelto(3).mover(7)!.mover(4)!;
}

void main() {
  group('Partida', () {
    test('nace preparada, sin movimientos ni tiempo', () {
      final partida = Partida(dificultad: Dificultad.medio);
      expect(partida.estado, EstadoPartida.preparada);
      expect(partida.movimientos, 0);
      expect(partida.tiempo, Duration.zero);
      expect(partida.tablero.tamano, 4);
      expect(partida.tablero.esResoluble, isTrue);
      expect(partida.tablero.estaResuelto, isFalse);
    });

    test('un movimiento inválido no cuenta ni inicia el cronómetro', () {
      var ahora = DateTime(2026, 1, 1);
      final partida = Partida(
        dificultad: Dificultad.facil,
        tableroInicial: Tablero.resuelto(3),
        reloj: () => ahora,
      );
      expect(partida.mover(0), isFalse);
      ahora = ahora.add(const Duration(seconds: 30));
      expect(partida.movimientos, 0);
      expect(partida.estado, EstadoPartida.preparada);
      expect(partida.tiempo, Duration.zero);
    });

    test('el cronómetro arranca con el primer movimiento válido', () {
      var ahora = DateTime(2026, 1, 1);
      final partida = Partida(
        dificultad: Dificultad.facil,
        tableroInicial: _tableroADosMovimientos(),
        reloj: () => ahora,
      );
      ahora = ahora.add(const Duration(seconds: 10)); // antes de empezar
      expect(partida.tiempo, Duration.zero);

      expect(partida.mover(7), isTrue);
      expect(partida.estado, EstadoPartida.enCurso);
      expect(partida.movimientos, 1);

      ahora = ahora.add(const Duration(seconds: 3));
      expect(partida.tiempo, const Duration(seconds: 3));
    });

    test('al ganar se detiene el cronómetro y se bloquean los movimientos', () {
      var ahora = DateTime(2026, 1, 1);
      final partida = Partida(
        dificultad: Dificultad.facil,
        tableroInicial: _tableroADosMovimientos(),
        reloj: () => ahora,
      );
      partida.mover(7);
      ahora = ahora.add(const Duration(seconds: 4));
      expect(partida.mover(8), isTrue);

      expect(partida.estado, EstadoPartida.victoria);
      expect(partida.movimientos, 2);
      expect(partida.tablero.estaResuelto, isTrue);

      ahora = ahora.add(const Duration(seconds: 10));
      expect(partida.tiempo, const Duration(seconds: 4));
      expect(partida.mover(7), isFalse);
      expect(partida.movimientos, 2);
    });

    test('reiniciar vuelve al estado preparado con otro tablero', () {
      var ahora = DateTime(2026, 1, 1);
      final partida = Partida(
        dificultad: Dificultad.facil,
        tableroInicial: _tableroADosMovimientos(),
        reloj: () => ahora,
      );
      partida.mover(7);
      ahora = ahora.add(const Duration(seconds: 5));

      partida.reiniciar();
      expect(partida.estado, EstadoPartida.preparada);
      expect(partida.movimientos, 0);
      expect(partida.tiempo, Duration.zero);
      expect(partida.tablero.tamano, 3);
      expect(partida.tablero.esResoluble, isTrue);
      expect(partida.tablero.estaResuelto, isFalse);
    });

    test('funciona con los tres tamaños de tablero', () {
      for (final dificultad in Dificultad.values) {
        final partida = Partida(dificultad: dificultad);
        expect(partida.tablero.tamano, dificultad.tamano);
      }
    });
  });
}
