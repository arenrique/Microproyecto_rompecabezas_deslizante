import 'package:flutter/material.dart';

import '../../../nucleo/logica/dificultad.dart';
import '../../../nucleo/records/records_dificultad.dart';
import '../../../nucleo/utilidades/formato.dart';

/// Opción elegida en el diálogo de victoria.
enum AccionVictoria { reiniciar, menu }

/// Resumen de la partida ganada, con aviso de nuevo récord si corresponde.
class DialogoVictoria extends StatelessWidget {
  const DialogoVictoria({
    super.key,
    required this.dificultad,
    required this.tiempo,
    required this.movimientos,
    this.actualizacion,
  });

  final Dificultad dificultad;
  final Duration tiempo;
  final int movimientos;

  /// Qué récords mejoró esta partida (nulo si no se pudo calcular).
  final ActualizacionRecord? actualizacion;

  String? get _detalleRecord {
    final a = actualizacion;
    if (a == null || !a.esNuevoRecord) return null;
    if (a.nuevoMejorTiempo && a.nuevosMenosMovimientos) {
      return 'Mejor tiempo y menos movimientos';
    }
    return a.nuevoMejorTiempo
        ? 'Nuevo mejor tiempo'
        : 'Nuevo menor número de movimientos';
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estilos = Theme.of(context).textTheme;
    final detalle = _detalleRecord;
    final n = dificultad.tamano;

    return AlertDialog(
      icon: Icon(Icons.emoji_events_rounded, size: 48, color: esquema.primary),
      title: const Text('¡Ganaste!', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (detalle != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: esquema.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '¡Nuevo récord!',
                      textAlign: TextAlign.center,
                      style: estilos.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: esquema.onTertiaryContainer,
                      ),
                    ),
                    Text(
                      detalle,
                      textAlign: TextAlign.center,
                      style: estilos.bodySmall?.copyWith(
                        color: esquema.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _FilaResumen(
              etiqueta: 'Tiempo',
              valor: formatearDuracion(tiempo),
              clave: const Key('resumen_tiempo'),
            ),
            _FilaResumen(
              etiqueta: 'Movimientos',
              valor: '$movimientos',
              clave: const Key('resumen_movimientos'),
            ),
            _FilaResumen(
              etiqueta: 'Dificultad',
              valor: '${dificultad.etiqueta} ($n×$n)',
              clave: const Key('resumen_dificultad'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(AccionVictoria.menu),
          child: const Text('Menú principal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(AccionVictoria.reiniciar),
          child: const Text('Reiniciar'),
        ),
      ],
    );
  }
}

class _FilaResumen extends StatelessWidget {
  const _FilaResumen({
    required this.etiqueta,
    required this.valor,
    required this.clave,
  });

  final String etiqueta;
  final String valor;
  final Key clave;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: estilos.bodyLarge),
          Text(
            valor,
            key: clave,
            style: estilos.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
