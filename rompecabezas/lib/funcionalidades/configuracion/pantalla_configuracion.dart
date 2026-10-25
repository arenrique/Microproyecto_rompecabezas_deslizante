import 'package:flutter/material.dart';

import '../../nucleo/ajustes/estilo_ficha.dart';
import '../../nucleo/ajustes/proveedor_ajustes.dart';
import '../../nucleo/logica/dificultad.dart';
import '../juego/widgets/ficha_vista.dart';

/// Pantalla de ajustes. El estado vive en [AjustesAplicacion] (un
/// `ChangeNotifier` compartido por toda la app) y esta pantalla se reconstruye
/// sola cuando cambia, por lo que no necesita `setState`.
class PantallaConfiguracion extends StatelessWidget {
  const PantallaConfiguracion({super.key});

  @override
  Widget build(BuildContext context) {
    final ajustes = ProveedorAjustes.de(context);
    final estilos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Seccion(
                  titulo: 'Dificultad',
                  ayuda: '${ajustes.dificultad.tamano}×'
                      '${ajustes.dificultad.tamano} · '
                      '${ajustes.dificultad.cantidadFichas} fichas. '
                      'Se aplica a la próxima partida nueva.',
                  hijo: SegmentedButton<Dificultad>(
                    showSelectedIcon: false,
                    segments: [
                      for (final d in Dificultad.values)
                        ButtonSegment<Dificultad>(
                          value: d,
                          label: Text(d.etiqueta),
                        ),
                    ],
                    selected: {ajustes.dificultad},
                    onSelectionChanged: (s) =>
                        ajustes.establecerDificultad(s.first),
                  ),
                ),
                _Seccion(
                  titulo: 'Tema',
                  // En pantallas estrechas se quitan los iconos para que los
                  // tres botones quepan sin desbordarse.
                  hijo: LayoutBuilder(
                    builder: (context, restricciones) {
                      final compacto = restricciones.maxWidth < 420;
                      return SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: compacto
                                ? null
                                : const Icon(Icons.light_mode_outlined),
                            label: const Text('Claro'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: compacto
                                ? null
                                : const Icon(Icons.dark_mode_outlined),
                            label: const Text('Oscuro'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: compacto
                                ? null
                                : const Icon(Icons.brightness_auto_outlined),
                            label: const Text('Automático'),
                          ),
                        ],
                        selected: {ajustes.modoTema},
                        onSelectionChanged: (s) =>
                            ajustes.establecerModoTema(s.first),
                      );
                    },
                  ),
                ),
                _Seccion(
                  titulo: 'Estilo de fichas',
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final estilo in EstiloFicha.values)
                            ChoiceChip(
                              label: Text(estilo.etiqueta),
                              selected: ajustes.estiloFichas == estilo,
                              onSelected: (_) =>
                                  ajustes.establecerEstiloFichas(estilo),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _VistaPreviaFichas(estilo: ajustes.estiloFichas),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const Key('interruptor_animaciones'),
                        title: const Text('Animaciones'),
                        subtitle: const Text(
                          'Movimiento de fichas y aparición del menú',
                        ),
                        value: ajustes.animacionesActivas,
                        onChanged: ajustes.establecerAnimaciones,
                      ),
                      SwitchListTile(
                        key: const Key('interruptor_sonido'),
                        title: const Text('Efectos de sonido'),
                        subtitle: const Text(
                          'Clic al mover una ficha (sonido del sistema; '
                          'puede no oírse en navegador)',
                        ),
                        value: ajustes.sonidoActivo,
                        onChanged: ajustes.establecerSonido,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Los ajustes se mantienen mientras la aplicación esté '
                  'abierta.',
                  textAlign: TextAlign.center,
                  style: estilos.bodySmall?.copyWith(
                    color: esquema.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.hijo, this.ayuda});

  final String titulo;
  final String? ayuda;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: estilos.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          hijo,
          if (ayuda != null) ...[
            const SizedBox(height: 8),
            Text(
              ayuda!,
              style: estilos.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VistaPreviaFichas extends StatelessWidget {
  const _VistaPreviaFichas({required this.estilo});

  final EstiloFicha estilo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final valor in const [1, 7, 15])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              width: 64,
              height: 64,
              child: FichaVista(
                valor: valor,
                totalFichas: 15,
                estilo: estilo,
              ),
            ),
          ),
      ],
    );
  }
}
