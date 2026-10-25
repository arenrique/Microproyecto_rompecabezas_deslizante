import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logica/dificultad.dart';
import 'almacen_records.dart';
import 'records_dificultad.dart';

/// Mantiene los récords en memoria, los sincroniza con el [AlmacenRecords] y
/// avisa a la interfaz cuando cambian.
class ServicioRecords extends ChangeNotifier {
  ServicioRecords(this._almacen);

  final AlmacenRecords _almacen;
  final Map<Dificultad, RecordsDificultad> _records = {};

  RecordsDificultad recordsDe(Dificultad dificultad) =>
      _records[dificultad] ?? const RecordsDificultad.vacio();

  bool get hayRecords => _records.values.any((r) => !r.estaVacio);

  /// Carga los récords guardados. Si el almacenamiento falla (por ejemplo,
  /// está bloqueado), la aplicación sigue funcionando sin récords previos.
  Future<void> cargar() async {
    try {
      final datos = await _almacen.cargar();
      for (final entrada in datos.entries) {
        _records.putIfAbsent(entrada.key, () => entrada.value);
      }
    } catch (_) {
      // Sin datos previos.
    }
    notifyListeners();
  }

  /// Compara [resultado] con los récords de su dificultad y, si mejora alguno,
  /// lo actualiza y lo guarda. Devuelve qué cambió.
  ActualizacionRecord registrar(ResultadoPartida resultado) {
    final actual = recordsDe(resultado.dificultad);
    final actualizacion = actual.conResultado(resultado);
    if (actualizacion.esNuevoRecord) {
      _records[resultado.dificultad] = actualizacion.records;
      notifyListeners();
      unawaited(_guardar(resultado.dificultad, actualizacion.records));
    }
    return actualizacion;
  }

  /// Elimina todos los récords.
  Future<void> borrarTodo() async {
    _records.clear();
    notifyListeners();
    try {
      await _almacen.borrarTodo();
    } catch (_) {
      // Los datos en memoria ya se borraron; se reintentará en otra ocasión.
    }
  }

  Future<void> _guardar(Dificultad dificultad, RecordsDificultad records) async {
    try {
      await _almacen.guardar(dificultad, records);
    } catch (_) {
      // El récord sigue vigente en esta sesión aunque no se pudiera guardar.
    }
  }
}
