import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/records/records_dificultad.dart';

ResultadoPartida _resultado(int segundos, int movimientos, DateTime fecha) {
  return ResultadoPartida(
    dificultad: Dificultad.medio,
    tiempo: Duration(seconds: segundos),
    movimientos: movimientos,
    fecha: fecha,
  );
}

void main() {
  final dia1 = DateTime(2026, 10, 1);
  final dia2 = DateTime(2026, 10, 2);
  final dia3 = DateTime(2026, 10, 3);

  group('RecordsDificultad', () {
    test('al principio está vacío', () {
      expect(const RecordsDificultad.vacio().estaVacio, isTrue);
    });

    test('la primera partida establece ambos récords', () {
      final act = const RecordsDificultad.vacio()
          .conResultado(_resultado(90, 120, dia1));
      expect(act.esNuevoRecord, isTrue);
      expect(act.nuevoMejorTiempo, isTrue);
      expect(act.nuevosMenosMovimientos, isTrue);
      expect(act.records.mejorTiempo, const Duration(seconds: 90));
      expect(act.records.menosMovimientos, 120);
      expect(act.records.fechaMejorTiempo, dia1);
      expect(act.records.fechaMenosMovimientos, dia1);
    });

    test('los dos récords son independientes y cada uno guarda su fecha', () {
      final base = const RecordsDificultad.vacio()
          .conResultado(_resultado(90, 120, dia1))
          .records;
      // Más rápida pero con más movimientos: solo mejora el tiempo.
      final act = base.conResultado(_resultado(60, 150, dia2));
      expect(act.nuevoMejorTiempo, isTrue);
      expect(act.nuevosMenosMovimientos, isFalse);
      expect(act.records.mejorTiempo, const Duration(seconds: 60));
      expect(act.records.fechaMejorTiempo, dia2);
      expect(act.records.menosMovimientos, 120);
      expect(act.records.fechaMenosMovimientos, dia1);
    });

    test('un empate no reemplaza el récord ni su fecha', () {
      final base = const RecordsDificultad.vacio()
          .conResultado(_resultado(90, 120, dia1))
          .records;
      final act = base.conResultado(_resultado(90, 120, dia3));
      expect(act.esNuevoRecord, isFalse);
      expect(act.records, base);
      expect(act.records.fechaMejorTiempo, dia1);
    });

    test('una partida peor en todo no cambia nada', () {
      final base = const RecordsDificultad.vacio()
          .conResultado(_resultado(90, 120, dia1))
          .records;
      final act = base.conResultado(_resultado(200, 300, dia2));
      expect(act.esNuevoRecord, isFalse);
      expect(act.records, base);
    });

    test('conResultado no modifica el objeto original', () {
      const original = RecordsDificultad.vacio();
      original.conResultado(_resultado(10, 10, dia1));
      expect(original.estaVacio, isTrue);
    });
  });

  group('JSON', () {
    test('ida y vuelta conserva los datos', () {
      final records = const RecordsDificultad.vacio()
          .conResultado(_resultado(75, 88, dia1))
          .records;
      expect(RecordsDificultad.desdeJson(records.aJson()), records);
    });

    test('datos inválidos producen récords vacíos o parciales', () {
      expect(RecordsDificultad.desdeJson(null).estaVacio, isTrue);
      expect(RecordsDificultad.desdeJson('texto').estaVacio, isTrue);
      expect(RecordsDificultad.desdeJson({'tiempoMs': -5}).estaVacio, isTrue);

      final parcial = RecordsDificultad.desdeJson({
        'tiempoMs': 5000,
        'fechaTiempo': 'no es una fecha',
        'movimientos': 'muchos',
      });
      expect(parcial.mejorTiempo, const Duration(seconds: 5));
      expect(parcial.fechaMejorTiempo, isNull);
      expect(parcial.menosMovimientos, isNull);
    });
  });
}
