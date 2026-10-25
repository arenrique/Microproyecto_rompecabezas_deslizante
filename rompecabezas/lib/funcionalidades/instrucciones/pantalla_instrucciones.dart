import 'package:flutter/material.dart';

import '../../nucleo/logica/dificultad.dart';
import '../../nucleo/logica/tablero.dart';
import 'widgets/mini_tablero.dart';

/// Reglas del juego. Es contenido estático, por eso es un [StatelessWidget].
class PantallaInstrucciones extends StatelessWidget {
  const PantallaInstrucciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo jugar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _Bloque(
                  icono: Icons.flag_outlined,
                  titulo: 'Objetivo',
                  texto: 'Ordena las fichas en orden numérico utilizando el '
                      'espacio vacío para deslizar las fichas adyacentes.',
                ),
                const _Bloque(
                  icono: Icons.touch_app_outlined,
                  titulo: 'Cómo mover las fichas',
                  texto: 'Toca una ficha que esté justo al lado del espacio '
                      'vacío (arriba, abajo, a la izquierda o a la derecha) y '
                      'se deslizará hasta ocuparlo. Las fichas que no tocan el '
                      'espacio vacío no se pueden mover, ni en diagonal.',
                  ejemplo: _EjemploMovimiento(),
                ),
                const _Bloque(
                  icono: Icons.emoji_events_outlined,
                  titulo: 'Cómo se gana',
                  texto: 'Ganas cuando todas las fichas quedan ordenadas de '
                      'izquierda a derecha y de arriba hacia abajo, con el '
                      'espacio vacío en la última casilla (abajo a la '
                      'derecha).',
                  ejemplo: _EjemploResuelto(),
                ),
                const _Bloque(
                  icono: Icons.timer_outlined,
                  titulo: 'Tiempo y movimientos',
                  texto: 'El cronómetro empieza con tu primer movimiento y se '
                      'detiene al ganar. Solo cuentan los movimientos válidos. '
                      'Guardamos tu mejor tiempo y tu menor número de '
                      'movimientos en cada dificultad.',
                ),
                const _Bloque(
                  icono: Icons.sentiment_satisfied_alt_outlined,
                  titulo: '¿Se puede perder?',
                  texto: 'No. No hay límite de tiempo ni de movimientos, así '
                      'que puedes tomarte todo el tiempo que quieras. Todos los '
                      'tableros se generan de forma que siempre tienen '
                      'solución.',
                ),
                _Bloque(
                  icono: Icons.grid_view_rounded,
                  titulo: 'Dificultades',
                  texto: [
                    for (final d in Dificultad.values)
                      '${d.etiqueta}: ${d.tamano}×${d.tamano} '
                          '(${d.cantidadFichas} fichas)',
                  ].join('\n'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al menú'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({
    required this.icono,
    required this.titulo,
    required this.texto,
    this.ejemplo,
  });

  final IconData icono;
  final String titulo;
  final String texto;
  final Widget? ejemplo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estilos = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: esquema.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: estilos.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(texto, style: estilos.bodyMedium),
            if (ejemplo != null) ...[
              const SizedBox(height: 12),
              ejemplo!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Ejemplo visual: al tocar el 8, que está junto al vacío, se desliza y el
/// tablero queda resuelto.
class _EjemploMovimiento extends StatelessWidget {
  const _EjemploMovimiento();

  @override
  Widget build(BuildContext context) {
    final antes = Tablero.desde(3, [1, 2, 3, 4, 5, 6, 7, 0, 8]);
    final despues = Tablero.resuelto(3);
    final estilos = Theme.of(context).textTheme;

    return Semantics(
      label: 'Ejemplo: en un tablero de 3 por 3, el 8 está junto al espacio '
          'vacío. Al tocarlo se desliza al hueco y el tablero queda resuelto.',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final lado = ((restricciones.maxWidth - 56) / 2).clamp(80.0, 130.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    MiniTablero(tablero: antes, lado: lado, resaltar: 8),
                    const SizedBox(height: 4),
                    Text('Toca el 8', style: estilos.labelMedium),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward_rounded),
                ),
                Column(
                  children: [
                    MiniTablero(tablero: despues, lado: lado, resaltar: 8),
                    const SizedBox(height: 4),
                    Text('Queda resuelto', style: estilos.labelMedium),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EjemploResuelto extends StatelessWidget {
  const _EjemploResuelto();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ejemplo de tablero de 4 por 4 resuelto: del 1 al 15 en orden y '
          'el espacio vacío abajo a la derecha.',
      child: ExcludeSemantics(
        child: Center(
          child: MiniTablero(tablero: Tablero.resuelto(4), lado: 140),
        ),
      ),
    );
  }
}
