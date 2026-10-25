import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../logica/dificultad.dart';
import 'records_dificultad.dart';

/// Dónde se guardan los récords. Separa la lógica del paquete de
/// almacenamiento para poder sustituirlo en las pruebas.
abstract class AlmacenRecords {
  Future<Map<Dificultad, RecordsDificultad>> cargar();
  Future<void> guardar(Dificultad dificultad, RecordsDificultad records);
  Future<void> borrarTodo();
}

/// Almacén real: `shared_preferences`, que es el único uso del paquete en la
/// aplicación (solo para los marcadores). Guarda un JSON por dificultad.
class AlmacenRecordsPreferencias implements AlmacenRecords {
  const AlmacenRecordsPreferencias();

  static String _clave(Dificultad dificultad) => 'records_${dificultad.name}';

  @override
  Future<Map<Dificultad, RecordsDificultad>> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    final resultado = <Dificultad, RecordsDificultad>{};
    for (final dificultad in Dificultad.values) {
      try {
        final texto = preferencias.getString(_clave(dificultad));
        if (texto == null) continue;
        final records = RecordsDificultad.desdeJson(jsonDecode(texto));
        if (!records.estaVacio) resultado[dificultad] = records;
      } catch (_) {
        // Dato corrupto o de otro tipo: se ignora esa dificultad.
      }
    }
    return resultado;
  }

  @override
  Future<void> guardar(Dificultad dificultad, RecordsDificultad records) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(
      _clave(dificultad),
      jsonEncode(records.aJson()),
    );
  }

  @override
  Future<void> borrarTodo() async {
    final preferencias = await SharedPreferences.getInstance();
    for (final dificultad in Dificultad.values) {
      await preferencias.remove(_clave(dificultad));
    }
  }
}

/// Almacén en memoria, para pruebas.
class AlmacenRecordsMemoria implements AlmacenRecords {
  /// Contenido actual (visible para poder comprobarlo en las pruebas).
  final Map<Dificultad, RecordsDificultad> datos = {};

  @override
  Future<Map<Dificultad, RecordsDificultad>> cargar() async => Map.of(datos);

  @override
  Future<void> guardar(Dificultad dificultad, RecordsDificultad records) async {
    datos[dificultad] = records;
  }

  @override
  Future<void> borrarTodo() async {
    datos.clear();
  }
}
