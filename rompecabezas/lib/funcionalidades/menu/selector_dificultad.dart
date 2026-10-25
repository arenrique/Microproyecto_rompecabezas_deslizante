import 'package:flutter/material.dart';

import '../../nucleo/logica/dificultad.dart';

/// Muestra una hoja inferior para elegir la dificultad antes de jugar.
/// Devuelve la dificultad elegida o `null` si se cierra sin elegir.
Future<Dificultad?> mostrarSelectorDificultad(
  BuildContext context,
  Dificultad actual,
) {
  return showModalBottomSheet<Dificultad>(
    context: context,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Elige la dificultad',
              textAlign: TextAlign.center,
              style: Theme.of(contexto).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final dificultad in Dificultad.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  selected: dificultad == actual,
                  selectedTileColor:
                      Theme.of(contexto).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const Icon(Icons.grid_view_rounded),
                  title: Text(dificultad.etiqueta),
                  subtitle: Text(
                    '${dificultad.tamano}×${dificultad.tamano} · '
                    '${dificultad.cantidadFichas} fichas',
                  ),
                  onTap: () => Navigator.of(contexto).pop(dificultad),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
