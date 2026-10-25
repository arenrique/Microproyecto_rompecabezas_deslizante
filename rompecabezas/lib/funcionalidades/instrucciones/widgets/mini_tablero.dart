import 'package:flutter/material.dart';

import '../../../nucleo/logica/tablero.dart';

/// Tablero pequeño y estático para ilustrar ejemplos. No es interactivo.
class MiniTablero extends StatelessWidget {
  const MiniTablero({
    super.key,
    required this.tablero,
    required this.lado,
    this.resaltar,
  });

  final Tablero tablero;
  final double lado;

  /// Valor de la ficha que se quiere destacar, si hay alguna.
  final int? resaltar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final n = tablero.tamano;
    return SizedBox(
      width: lado,
      height: lado,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: esquema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              for (var fila = 0; fila < n; fila++)
                Expanded(
                  child: Row(
                    children: [
                      for (var columna = 0; columna < n; columna++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: _Celda(
                              valor: tablero.fichas[fila * n + columna],
                              destacada: tablero.fichas[fila * n + columna] ==
                                  resaltar,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda({required this.valor, required this.destacada});

  final int valor;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    if (valor == Tablero.valorVacio) return const SizedBox.shrink();
    final esquema = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: destacada ? esquema.tertiary : esquema.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          '$valor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: destacada ? esquema.onTertiary : esquema.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
