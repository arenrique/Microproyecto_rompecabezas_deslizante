import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/utilidades/formato.dart';

void main() {
  group('formatearDuracion', () {
    test('usa el formato mm:ss', () {
      expect(formatearDuracion(Duration.zero), '00:00');
      expect(formatearDuracion(const Duration(seconds: 5)), '00:05');
      expect(formatearDuracion(const Duration(seconds: 65)), '01:05');
      expect(formatearDuracion(const Duration(minutes: 12, seconds: 3)), '12:03');
    });

    test('ignora los milisegundos', () {
      expect(formatearDuracion(const Duration(milliseconds: 1999)), '00:01');
    });

    test('admite más de 99 minutos', () {
      expect(formatearDuracion(const Duration(minutes: 125)), '125:00');
    });
  });

  group('formatearFecha', () {
    test('usa el formato dd/mm/aaaa', () {
      expect(formatearFecha(DateTime(2026, 10, 7)), '07/10/2026');
      expect(formatearFecha(DateTime(2026, 12, 31)), '31/12/2026');
    });
  });
}
