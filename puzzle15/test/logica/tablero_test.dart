import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/logica/tablero.dart';

void main() {
  group('Dificultad', () {
    test('define el tamaño y la cantidad de fichas de cada nivel', () {
      expect(Dificultad.facil.tamano, 3);
      expect(Dificultad.facil.cantidadFichas, 8);
      expect(Dificultad.medio.tamano, 4);
      expect(Dificultad.medio.cantidadFichas, 15);
      expect(Dificultad.dificil.tamano, 5);
      expect(Dificultad.dificil.cantidadFichas, 24);
    });
  });

  group('Tablero resuelto', () {
    for (final dificultad in Dificultad.values) {
      test('${dificultad.etiqueta}: estado ganador con el vacío al final', () {
        final n = dificultad.tamano;
        final tablero = Tablero.resuelto(n);
        expect(tablero.fichas.length, n * n);
        expect(tablero.estaResuelto, isTrue);
        expect(tablero.indiceVacio, n * n - 1);
        expect(tablero.fichas.last, Tablero.valorVacio);
        expect(tablero.fichas.first, 1);
        expect(tablero.esResoluble, isTrue);
      });
    }

    test('rechaza disposiciones inválidas', () {
      expect(() => Tablero.desde(1, [0]), throwsArgumentError);
      expect(() => Tablero.desde(3, [1, 2, 3]), throwsArgumentError);
      expect(
        () => Tablero.desde(3, [1, 1, 3, 4, 5, 6, 7, 8, 0]),
        throwsArgumentError,
      );
    });

    test('las fichas no se pueden modificar desde fuera', () {
      final tablero = Tablero.resuelto(3);
      expect(() => tablero.fichas[0] = 5, throwsUnsupportedError);
    });
  });

  group('Validación de movimientos', () {
    test('solo se mueven las fichas adyacentes al vacío', () {
      final tablero = Tablero.resuelto(3); // vacío en el índice 8
      expect(tablero.puedeMover(7), isTrue); // izquierda del vacío
      expect(tablero.puedeMover(5), isTrue); // encima del vacío
      expect(tablero.puedeMover(4), isFalse); // diagonal
      expect(tablero.puedeMover(0), isFalse); // lejos
      expect(tablero.puedeMover(8), isFalse); // el propio vacío
      expect(tablero.puedeMover(-1), isFalse);
      expect(tablero.puedeMover(9), isFalse);
    });

    test('el final de una fila no es adyacente al inicio de la siguiente', () {
      // Vacío en la fila 1, columna 0 (índice 3).
      final tablero = Tablero.desde(3, [1, 2, 3, 0, 4, 5, 6, 7, 8]);
      expect(tablero.puedeMover(2), isFalse); // fila 0, columna 2
      expect(tablero.puedeMover(0), isTrue); // arriba
      expect(tablero.puedeMover(4), isTrue); // derecha
      expect(tablero.puedeMover(6), isTrue); // abajo
    });

    test('mover devuelve un tablero nuevo sin alterar el original', () {
      final original = Tablero.resuelto(3);
      final movido = original.mover(7)!;
      expect(movido.fichas, [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(movido.indiceVacio, 7);
      expect(original.estaResuelto, isTrue);
    });

    test('mover una ficha no adyacente o el vacío devuelve null', () {
      final tablero = Tablero.resuelto(4);
      expect(tablero.mover(0), isNull);
      expect(tablero.mover(10), isNull);
      expect(tablero.mover(tablero.indiceVacio), isNull);
      expect(tablero.mover(99), isNull);
    });
  });

  group('Detección de victoria', () {
    test('se pierde al mover y se recupera al volver atrás', () {
      final resuelto = Tablero.resuelto(3);
      final alterado = resuelto.mover(7)!;
      expect(alterado.estaResuelto, isFalse);
      expect(alterado.mover(8)!.estaResuelto, isTrue);
    });

    test('el vacío fuera de su sitio no cuenta como resuelto', () {
      final tablero = Tablero.desde(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(tablero.estaResuelto, isFalse);
    });
  });

  group('Resolubilidad', () {
    test('detecta tableros imposibles (dos fichas finales intercambiadas)', () {
      expect(
        Tablero.desde(3, [1, 2, 3, 4, 5, 6, 8, 7, 0]).esResoluble,
        isFalse,
      );
      expect(
        Tablero.desde(4, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 14, 0])
            .esResoluble,
        isFalse,
      );
    });

    for (final dificultad in Dificultad.values) {
      test('${dificultad.etiqueta}: movimientos legales conservan la '
          'resolubilidad', () {
        final n = dificultad.tamano;
        final azar = Random(1);
        var tablero = Tablero.resuelto(n);
        for (var paso = 0; paso < 500; paso++) {
          final candidatos = [
            for (var i = 0; i < n * n; i++)
              if (tablero.puedeMover(i)) i,
          ];
          tablero = tablero.mover(candidatos[azar.nextInt(candidatos.length)])!;
          expect(tablero.esResoluble, isTrue);
        }
      });
    }
  });

  group('Generación aleatoria', () {
    for (final dificultad in Dificultad.values) {
      test('${dificultad.etiqueta}: 300 tableros válidos y resolubles', () {
        final n = dificultad.tamano;
        final azar = Random(42);
        for (var i = 0; i < 300; i++) {
          final tablero = Tablero.aleatorio(n, azar: azar);
          expect(tablero.tamano, n);
          expect(tablero.esResoluble, isTrue);
          expect(tablero.estaResuelto, isFalse);
          final ordenadas = List<int>.of(tablero.fichas)..sort();
          expect(ordenadas, List<int>.generate(n * n, (k) => k));
        }
      });
    }

    test('con la misma semilla produce el mismo tablero', () {
      final a = Tablero.aleatorio(4, azar: Random(7));
      final b = Tablero.aleatorio(4, azar: Random(7));
      expect(a, equals(b));
    });

    test('funciona sin semilla', () {
      expect(Tablero.aleatorio(3).esResoluble, isTrue);
    });
  });
}
