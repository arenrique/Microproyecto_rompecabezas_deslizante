import 'dart:math';

/// Tablero inmutable de un rompecabezas deslizante de [tamano] × [tamano].
///
/// Las fichas se guardan en una lista plana, por filas (de izquierda a derecha
/// y de arriba abajo). El valor [valorVacio] (0) representa el espacio vacío.
/// El estado resuelto es `1, 2, ..., n²-1` seguido del espacio vacío.
class Tablero {
  Tablero._(this.tamano, List<int> fichas)
      : fichas = List<int>.unmodifiable(fichas),
        indiceVacio = fichas.indexOf(valorVacio);

  /// Crea un tablero a partir de una disposición concreta.
  ///
  /// Lanza [ArgumentError] si el tamaño es menor que 2 o si [fichas] no es una
  /// permutación de `0..tamano²-1`.
  factory Tablero.desde(int tamano, List<int> fichas) {
    if (tamano < 2) {
      throw ArgumentError.value(tamano, 'tamano', 'Debe ser al menos 2.');
    }
    final total = tamano * tamano;
    if (fichas.length != total) {
      throw ArgumentError.value(
        fichas.length,
        'fichas',
        'Se esperaban $total fichas.',
      );
    }
    final ordenadas = List<int>.of(fichas)..sort();
    for (var i = 0; i < total; i++) {
      if (ordenadas[i] != i) {
        throw ArgumentError(
          'Las fichas deben ser una permutación de 0..${total - 1}.',
        );
      }
    }
    return Tablero._(tamano, fichas);
  }

  /// Tablero en el estado ganador.
  factory Tablero.resuelto(int tamano) {
    final total = tamano * tamano;
    return Tablero.desde(
      tamano,
      [for (var i = 1; i < total; i++) i, valorVacio],
    );
  }

  /// Tablero aleatorio, garantizado como resoluble y distinto del resuelto.
  ///
  /// Se mezclan las fichas al azar y, si la permutación resultante no es
  /// resoluble (paridad de inversiones), se intercambian dos fichas, lo que
  /// invierte la paridad. Se puede pasar [azar] para obtener resultados
  /// reproducibles.
  factory Tablero.aleatorio(int tamano, {Random? azar}) {
    final generador = azar ?? Random();
    while (true) {
      final fichas = List<int>.generate(tamano * tamano, (i) => i)
        ..shuffle(generador);
      var candidato = Tablero.desde(tamano, fichas);
      if (!candidato.esResoluble) {
        candidato = Tablero.desde(tamano, _conDosFichasIntercambiadas(fichas));
      }
      if (!candidato.estaResuelto) return candidato;
    }
  }

  /// Valor que representa el espacio vacío.
  static const int valorVacio = 0;

  /// Número de filas y de columnas.
  final int tamano;

  /// Fichas por filas. La lista no se puede modificar.
  final List<int> fichas;

  /// Posición del espacio vacío dentro de [fichas].
  final int indiceVacio;

  int filaDe(int indice) => indice ~/ tamano;

  int columnaDe(int indice) => indice % tamano;

  /// Indica si todas las fichas están en su posición final.
  bool get estaResuelto {
    final ultima = fichas.length - 1;
    for (var i = 0; i < ultima; i++) {
      if (fichas[i] != i + 1) return false;
    }
    return fichas[ultima] == valorVacio;
  }

  /// Indica si el tablero se puede resolver con movimientos legales.
  ///
  /// Tamaño impar: el número de inversiones debe ser par. Tamaño par: si el
  /// vacío está en una fila par contando desde abajo, las inversiones deben
  /// ser impares; si está en una fila impar, deben ser pares.
  bool get esResoluble {
    final inversiones = _contarInversiones();
    if (tamano.isOdd) return inversiones.isEven;
    final filaDesdeAbajo = tamano - filaDe(indiceVacio);
    return filaDesdeAbajo.isEven ? inversiones.isOdd : inversiones.isEven;
  }

  /// Una ficha se puede mover solo si está justo al lado (arriba, abajo,
  /// izquierda o derecha) del espacio vacío.
  bool puedeMover(int indice) {
    if (indice < 0 || indice >= fichas.length) return false;
    if (indice == indiceVacio) return false;
    final distanciaFilas = (filaDe(indice) - filaDe(indiceVacio)).abs();
    final distanciaColumnas = (columnaDe(indice) - columnaDe(indiceVacio)).abs();
    return distanciaFilas + distanciaColumnas == 1;
  }

  /// Devuelve un tablero nuevo con la ficha de [indice] movida al espacio
  /// vacío, o `null` si el movimiento no es válido. No modifica este tablero.
  Tablero? mover(int indice) {
    if (!puedeMover(indice)) return null;
    final nuevas = List<int>.of(fichas);
    nuevas[indiceVacio] = nuevas[indice];
    nuevas[indice] = valorVacio;
    return Tablero._(tamano, nuevas);
  }

  int _contarInversiones() {
    var inversiones = 0;
    for (var i = 0; i < fichas.length; i++) {
      if (fichas[i] == valorVacio) continue;
      for (var j = i + 1; j < fichas.length; j++) {
        if (fichas[j] != valorVacio && fichas[i] > fichas[j]) inversiones++;
      }
    }
    return inversiones;
  }

  static List<int> _conDosFichasIntercambiadas(List<int> fichas) {
    final copia = List<int>.of(fichas);
    final posiciones = [
      for (var i = 0; i < copia.length; i++)
        if (copia[i] != valorVacio) i,
    ];
    final a = posiciones[0];
    final b = posiciones[1];
    final auxiliar = copia[a];
    copia[a] = copia[b];
    copia[b] = auxiliar;
    return copia;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tablero || other.tamano != tamano) return false;
    for (var i = 0; i < fichas.length; i++) {
      if (fichas[i] != other.fichas[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(tamano, Object.hashAll(fichas));

  @override
  String toString() => 'Tablero($tamano, $fichas)';
}
