import 'dart:math';

import 'package:flutter/material.dart';

import '../../../nucleo/ajustes/estilo_ficha.dart';
import '../../../nucleo/logica/tablero.dart';
import 'ficha_vista.dart';

/// Dibuja el tablero adaptándose al espacio disponible y anima el
/// desplazamiento de las fichas (si [animar] es verdadero).
class VistaTablero extends StatelessWidget {
  const VistaTablero({
    super.key,
    required this.tablero,
    required this.alPulsarFicha,
    this.estilo = EstiloFicha.clasico,
    this.habilitado = true,
    this.animar = true,
  });

  final Tablero tablero;
  final ValueChanged<int> alPulsarFicha;
  final EstiloFicha estilo;
  final bool habilitado;
  final bool animar;

  static const double _ladoMaximo = 560;
  static const double _relleno = 8;
  static const double _separacion = 6;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final n = tablero.tamano;
    final totalFichas = n * n - 1;

    return LayoutBuilder(
      builder: (context, restricciones) {
        final lado = min(
          min(restricciones.maxWidth, restricciones.maxHeight),
          _ladoMaximo,
        );
        // Con muy poco espacio el cálculo podría dar un tamaño negativo.
        final ladoFicha = max(
          0.0,
          (lado - 2 * _relleno - (n - 1) * _separacion) / n,
        );
        final paso = ladoFicha + _separacion;

        return Center(
          child: SizedBox(
            width: lado,
            height: lado,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: esquema.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  for (var i = 0; i < tablero.fichas.length; i++)
                    if (tablero.fichas[i] != Tablero.valorVacio)
                      AnimatedPositioned(
                        key: ValueKey('ficha_${tablero.fichas[i]}'),
                        duration: animar
                            ? const Duration(milliseconds: 160)
                            : Duration.zero,
                        curve: Curves.easeOut,
                        left: _relleno + tablero.columnaDe(i) * paso,
                        top: _relleno + tablero.filaDe(i) * paso,
                        width: ladoFicha,
                        height: ladoFicha,
                        child: FichaVista(
                          valor: tablero.fichas[i],
                          totalFichas: totalFichas,
                          estilo: estilo,
                          alPulsar: habilitado ? () => alPulsarFicha(i) : null,
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
