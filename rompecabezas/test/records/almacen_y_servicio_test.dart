import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/nucleo/logica/dificultad.dart';
import 'package:rompecabezas/nucleo/records/almacen_records.dart';
import 'package:rompecabezas/nucleo/records/records_dificultad.dart';
import 'package:rompecabezas/nucleo/records/servicio_records.dart';
import 'package:shared_preferences/shared_preferences.dart';

ResultadoPartida _resultado(
  Dificultad dificultad,
  int segundos,
  int movimientos, [
  DateTime? fecha,
]) {
  return ResultadoPartida(
    dificultad: dificultad,
    tiempo: Duration(seconds: segundos),
    movimientos: movimientos,
    fecha: fecha ?? DateTime(2026, 10, 1),
  );
}

class _AlmacenQueFalla implements AlmacenRecords {
  @override
  Future<Map<Dificultad, RecordsDificultad>> cargar() async =>
      throw Exception('almacenamiento no disponible');

  @override
  Future<void> guardar(Dificultad d, RecordsDificultad r) async =>
      throw Exception('almacenamiento no disponible');

  @override
  Future<void> borrarTodo() async =>
      throw Exception('almacenamiento no disponible');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlmacenRecordsPreferencias (shared_preferences)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('sin datos devuelve un mapa vacío', () async {
      expect(await const AlmacenRecordsPreferencias().cargar(), isEmpty);
    });

    test('guardar y cargar conserva los récords por dificultad', () async {
      const almacen = AlmacenRecordsPreferencias();
      final facil = const RecordsDificultad.vacio()
          .conResultado(_resultado(Dificultad.facil, 20, 30))
          .records;
      final dificil = const RecordsDificultad.vacio()
          .conResultado(_resultado(Dificultad.dificil, 300, 400))
          .records;
      await almacen.guardar(Dificultad.facil, facil);
      await almacen.guardar(Dificultad.dificil, dificil);

      final cargados = await almacen.cargar();
      expect(cargados[Dificultad.facil], facil);
      expect(cargados[Dificultad.dificil], dificil);
      expect(cargados.containsKey(Dificultad.medio), isFalse);
    });

    test('un valor corrupto se ignora sin afectar a los demás', () async {
      SharedPreferences.setMockInitialValues({
        'records_facil': '{esto no es json',
        'records_medio': '{"tiempoMs": 61000, "movimientos": 99}',
      });
      final cargados = await const AlmacenRecordsPreferencias().cargar();
      expect(cargados.containsKey(Dificultad.facil), isFalse);
      expect(cargados[Dificultad.medio]?.menosMovimientos, 99);
    });

    test('borrarTodo elimina los récords', () async {
      const almacen = AlmacenRecordsPreferencias();
      await almacen.guardar(
        Dificultad.medio,
        const RecordsDificultad.vacio()
            .conResultado(_resultado(Dificultad.medio, 5, 5))
            .records,
      );
      await almacen.borrarTodo();
      expect(await almacen.cargar(), isEmpty);
    });
  });

  group('ServicioRecords', () {
    test('registrar guarda el récord y avisa a los oyentes', () async {
      final almacen = AlmacenRecordsMemoria();
      final servicio = ServicioRecords(almacen);
      var avisos = 0;
      servicio.addListener(() => avisos++);

      final act = servicio.registrar(_resultado(Dificultad.medio, 90, 120));
      expect(act.esNuevoRecord, isTrue);
      expect(servicio.hayRecords, isTrue);
      expect(avisos, 1);
      await Future<void>.delayed(Duration.zero);
      expect(almacen.datos[Dificultad.medio]?.menosMovimientos, 120);
    });

    test('una partida que no mejora no escribe ni avisa', () {
      final almacen = AlmacenRecordsMemoria();
      final servicio = ServicioRecords(almacen);
      servicio.registrar(_resultado(Dificultad.facil, 30, 40));
      var avisos = 0;
      servicio.addListener(() => avisos++);

      final act = servicio.registrar(_resultado(Dificultad.facil, 30, 40));
      expect(act.esNuevoRecord, isFalse);
      expect(avisos, 0);
    });

    test('los récords de cada dificultad son independientes', () {
      final servicio = ServicioRecords(AlmacenRecordsMemoria());
      servicio.registrar(_resultado(Dificultad.facil, 10, 20));
      expect(servicio.recordsDe(Dificultad.facil).estaVacio, isFalse);
      expect(servicio.recordsDe(Dificultad.medio).estaVacio, isTrue);
      expect(servicio.recordsDe(Dificultad.dificil).estaVacio, isTrue);
    });

    test('cargar recupera lo guardado por otra instancia', () async {
      final almacen = AlmacenRecordsMemoria();
      ServicioRecords(almacen).registrar(_resultado(Dificultad.dificil, 5, 6));
      await Future<void>.delayed(Duration.zero);

      final nuevo = ServicioRecords(almacen);
      expect(nuevo.hayRecords, isFalse);
      await nuevo.cargar();
      expect(nuevo.recordsDe(Dificultad.dificil).menosMovimientos, 6);
    });

    test('borrarTodo vacía la memoria y el almacén', () async {
      final almacen = AlmacenRecordsMemoria();
      final servicio = ServicioRecords(almacen);
      servicio.registrar(_resultado(Dificultad.facil, 10, 20));
      await Future<void>.delayed(Duration.zero);

      await servicio.borrarTodo();
      expect(servicio.hayRecords, isFalse);
      expect(almacen.datos, isEmpty);
    });

    test('si el almacenamiento falla, la app sigue funcionando', () async {
      final servicio = ServicioRecords(_AlmacenQueFalla());
      await servicio.cargar();
      final act = servicio.registrar(_resultado(Dificultad.medio, 10, 20));
      await Future<void>.delayed(Duration.zero);
      expect(act.esNuevoRecord, isTrue);
      expect(servicio.hayRecords, isTrue);
      await servicio.borrarTodo();
      expect(servicio.hayRecords, isFalse);
    });
  });
}
