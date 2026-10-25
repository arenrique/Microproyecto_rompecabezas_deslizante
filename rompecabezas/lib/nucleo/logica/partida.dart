import 'dart:math';

import 'dificultad.dart';
import 'tablero.dart';

/// Fases por las que pasa una partida.
enum EstadoPartida {
  /// Tablero generado; todavía no se ha hecho ningún movimiento válido.
  preparada,

  /// Ya hubo un primer movimiento válido y el cronómetro corre.
  enCurso,

  /// Todas las fichas están en su sitio; el cronómetro está detenido.
  victoria,
}

/// Lógica de una partida: tablero, movimientos, cronómetro y estado.
///
/// No depende de Flutter. El reloj es inyectable para poder probar el
/// cronómetro sin esperas reales.
class Partida {
  Partida({
    required this.dificultad,
    Tablero? tableroInicial,
    DateTime Function()? reloj,
    Random? azar,
  })  : assert(
          tableroInicial == null || tableroInicial.tamano == dificultad.tamano,
          'El tablero no coincide con la dificultad.',
        ),
        assert(
          tableroInicial == null || tableroInicial.esResoluble,
          'El tablero inicial debe ser resoluble.',
        ),
        _reloj = reloj ?? DateTime.now,
        _azar = azar,
        _tablero =
            tableroInicial ?? Tablero.aleatorio(dificultad.tamano, azar: azar);

  final Dificultad dificultad;
  final DateTime Function() _reloj;
  final Random? _azar;

  Tablero _tablero;
  int _movimientos = 0;
  EstadoPartida _estado = EstadoPartida.preparada;
  DateTime? _inicio;
  DateTime? _fin;

  Tablero get tablero => _tablero;
  int get movimientos => _movimientos;
  EstadoPartida get estado => _estado;

  /// Tiempo desde el primer movimiento válido. Es cero antes de empezar y
  /// queda fijo al ganar.
  Duration get tiempo {
    final inicio = _inicio;
    if (inicio == null) return Duration.zero;
    return (_fin ?? _reloj()).difference(inicio);
  }

  /// Intenta mover la ficha de [indice]. Devuelve `true` solo si el
  /// movimiento fue válido (y por tanto se contó). Tras la victoria no se
  /// aceptan más movimientos.
  bool mover(int indice) {
    if (_estado == EstadoPartida.victoria) return false;
    final nuevo = _tablero.mover(indice);
    if (nuevo == null) return false;

    if (_estado == EstadoPartida.preparada) {
      _estado = EstadoPartida.enCurso;
      _inicio = _reloj();
    }
    _tablero = nuevo;
    _movimientos++;

    if (_tablero.estaResuelto) {
      _estado = EstadoPartida.victoria;
      _fin = _reloj();
    }
    return true;
  }

  /// Empieza de nuevo con otro tablero aleatorio de la misma dificultad.
  void reiniciar() {
    _tablero = Tablero.aleatorio(dificultad.tamano, azar: _azar);
    _movimientos = 0;
    _estado = EstadoPartida.preparada;
    _inicio = null;
    _fin = null;
  }
}
