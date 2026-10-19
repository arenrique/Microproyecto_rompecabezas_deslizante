import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/logica/tablero.dart';

import '../ayudas/resolutor.dart';

void main() {
  group('Resolutor de pruebas', () {
    test('un tablero resuelto no necesita movimientos', () {
      expect(resolver(Tablero.resuelto(3)), isEmpty);
    });

    test('resuelve un tablero a dos movimientos', () {
      final tablero = Tablero.resuelto(3).mover(7)!.mover(4)!;
      expect(resolver(tablero), hasLength(2));
    });

    test('resuelve 25 tableros aleatorios de 3×3 con movimientos legales', () {
      final azar = Random(5);
      for (var i = 0; i < 25; i++) {
        final inicial = Tablero.aleatorio(3, azar: azar);
        final pasos = resolver(inicial);
        var actual = inicial;
        for (final indice in pasos) {
          final siguiente = actual.mover(indice);
          expect(siguiente, isNotNull, reason: 'movimiento ilegal en $inicial');
          actual = siguiente!;
        }
        expect(actual.estaResuelto, isTrue);
        expect(pasos.length, lessThanOrEqualTo(31)); // máximo del 8-puzzle
      }
    });
  });
}
