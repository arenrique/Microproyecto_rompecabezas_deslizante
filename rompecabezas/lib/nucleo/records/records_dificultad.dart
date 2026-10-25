import '../logica/dificultad.dart';

/// Resultado de una partida ganada.
class ResultadoPartida {
  const ResultadoPartida({
    required this.dificultad,
    required this.tiempo,
    required this.movimientos,
    required this.fecha,
  });

  final Dificultad dificultad;
  final Duration tiempo;
  final int movimientos;
  final DateTime fecha;
}

/// Resultado de comparar una partida con los récords guardados.
class ActualizacionRecord {
  const ActualizacionRecord({
    required this.records,
    required this.nuevoMejorTiempo,
    required this.nuevosMenosMovimientos,
  });

  /// Récords resultantes (iguales a los anteriores si no hubo mejora).
  final RecordsDificultad records;
  final bool nuevoMejorTiempo;
  final bool nuevosMenosMovimientos;

  bool get esNuevoRecord => nuevoMejorTiempo || nuevosMenosMovimientos;
}

/// Récords de una dificultad.
///
/// Reglas:
/// - Se guardan dos récords independientes: el **mejor tiempo** y el **menor
///   número de movimientos**. Pueden venir de partidas distintas, y cada uno
///   conserva la fecha de la partida en la que se logró.
/// - Un récord solo se reemplaza si el resultado es **estrictamente mejor**.
///   Un empate no lo reemplaza: se conserva la partida más antigua y su fecha.
class RecordsDificultad {
  const RecordsDificultad({
    this.mejorTiempo,
    this.fechaMejorTiempo,
    this.menosMovimientos,
    this.fechaMenosMovimientos,
  });

  const RecordsDificultad.vacio() : this();

  final Duration? mejorTiempo;
  final DateTime? fechaMejorTiempo;
  final int? menosMovimientos;
  final DateTime? fechaMenosMovimientos;

  bool get estaVacio => mejorTiempo == null && menosMovimientos == null;

  /// Compara [resultado] con los récords actuales sin modificar este objeto.
  ActualizacionRecord conResultado(ResultadoPartida resultado) {
    final tiempoActual = mejorTiempo;
    final movimientosActuales = menosMovimientos;
    final mejoraTiempo =
        tiempoActual == null || resultado.tiempo < tiempoActual;
    final mejoraMovimientos = movimientosActuales == null ||
        resultado.movimientos < movimientosActuales;

    return ActualizacionRecord(
      records: RecordsDificultad(
        mejorTiempo: mejoraTiempo ? resultado.tiempo : tiempoActual,
        fechaMejorTiempo: mejoraTiempo ? resultado.fecha : fechaMejorTiempo,
        menosMovimientos:
            mejoraMovimientos ? resultado.movimientos : movimientosActuales,
        fechaMenosMovimientos:
            mejoraMovimientos ? resultado.fecha : fechaMenosMovimientos,
      ),
      nuevoMejorTiempo: mejoraTiempo,
      nuevosMenosMovimientos: mejoraMovimientos,
    );
  }

  Map<String, Object?> aJson() => {
        'tiempoMs': mejorTiempo?.inMilliseconds,
        'fechaTiempo': fechaMejorTiempo?.toIso8601String(),
        'movimientos': menosMovimientos,
        'fechaMovimientos': fechaMenosMovimientos?.toIso8601String(),
      };

  /// Reconstruye los récords desde JSON. Es tolerante: los campos ausentes o
  /// inválidos se ignoran y un valor que no sea un mapa produce un objeto
  /// vacío.
  factory RecordsDificultad.desdeJson(Object? json) {
    if (json is! Map) return const RecordsDificultad.vacio();
    final ms = json['tiempoMs'];
    final movimientos = json['movimientos'];
    final tiempo = ms is int && ms >= 0 ? Duration(milliseconds: ms) : null;
    final menos = movimientos is int && movimientos >= 0 ? movimientos : null;
    return RecordsDificultad(
      mejorTiempo: tiempo,
      fechaMejorTiempo: tiempo == null ? null : _fecha(json['fechaTiempo']),
      menosMovimientos: menos,
      fechaMenosMovimientos:
          menos == null ? null : _fecha(json['fechaMovimientos']),
    );
  }

  static DateTime? _fecha(Object? valor) {
    return valor is String ? DateTime.tryParse(valor) : null;
  }

  @override
  bool operator ==(Object other) =>
      other is RecordsDificultad &&
      other.mejorTiempo == mejorTiempo &&
      other.fechaMejorTiempo == fechaMejorTiempo &&
      other.menosMovimientos == menosMovimientos &&
      other.fechaMenosMovimientos == fechaMenosMovimientos;

  @override
  int get hashCode => Object.hash(
        mejorTiempo,
        fechaMejorTiempo,
        menosMovimientos,
        fechaMenosMovimientos,
      );
}
