import 'dart:collection';

import 'package:rompecabezas/nucleo/logica/tablero.dart';

/// Resuelve tableros pequeños (hasta 3×3) con una búsqueda en anchura.
///
/// Devuelve, en orden, los **índices de las fichas que hay que pulsar**: cada
/// índice se refiere a la posición de la ficha en el tablero justo antes de
/// moverla. Sirve para completar partidas reales en las pruebas de
/// integración. No se usa en la aplicación.
List<int> resolver(Tablero inicial) {
  assert(inicial.tamano <= 3, 'La búsqueda exhaustiva solo es viable hasta 3×3');
  if (inicial.estaResuelto) return const [];

  final padres = <String, _Paso>{_clave(inicial): const _Paso(null, -1)};
  final cola = Queue<Tablero>()..add(inicial);

  while (cola.isNotEmpty) {
    final actual = cola.removeFirst();
    final claveActual = _clave(actual);
    for (var i = 0; i < actual.fichas.length; i++) {
      final siguiente = actual.mover(i);
      if (siguiente == null) continue;
      final clave = _clave(siguiente);
      if (padres.containsKey(clave)) continue;
      padres[clave] = _Paso(claveActual, i);
      if (siguiente.estaResuelto) return _reconstruir(padres, clave);
      cola.add(siguiente);
    }
  }
  throw StateError('El tablero no tiene solución: $inicial');
}

String _clave(Tablero tablero) => tablero.fichas.join(',');

List<int> _reconstruir(Map<String, _Paso> padres, String claveFinal) {
  final pasos = <int>[];
  var clave = claveFinal;
  while (true) {
    final paso = padres[clave]!;
    final anterior = paso.claveAnterior;
    if (anterior == null) break;
    pasos.add(paso.indice);
    clave = anterior;
  }
  return pasos.reversed.toList();
}

class _Paso {
  const _Paso(this.claveAnterior, this.indice);

  final String? claveAnterior;
  final int indice;
}
