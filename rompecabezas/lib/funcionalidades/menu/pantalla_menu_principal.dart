import 'package:flutter/material.dart';

import '../../nucleo/ajustes/ajustes_aplicacion.dart';
import '../../nucleo/ajustes/proveedor_ajustes.dart';
import '../../nucleo/rutas.dart';
import 'selector_dificultad.dart';

/// Menú principal con las cuatro secciones de la aplicación.
class PantallaMenuPrincipal extends StatelessWidget {
  const PantallaMenuPrincipal({super.key});

  Future<void> _iniciarJuego(
    BuildContext context,
    AjustesAplicacion ajustes,
  ) async {
    final elegida = await mostrarSelectorDificultad(
      context,
      ajustes.dificultad,
    );
    if (elegida == null || !context.mounted) return;
    ajustes.establecerDificultad(elegida);
    await Navigator.of(context).pushNamed(
      RutasAplicacion.juego,
      arguments: elegida,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estiloTexto = Theme.of(context).textTheme;
    final ajustes = ProveedorAjustes.de(context);
    final animar = ajustes.animacionesActivas;
    final navegador = Navigator.of(context);

    final opciones = <_OpcionMenu>[
      _OpcionMenu(
        'Jugar',
        Icons.play_arrow_rounded,
        () => _iniciarJuego(context, ajustes),
      ),
      _OpcionMenu(
        'Marcadores',
        Icons.emoji_events_rounded,
        () => navegador.pushNamed(RutasAplicacion.marcadores),
      ),
      _OpcionMenu(
        'Configuración',
        Icons.settings_rounded,
        () => navegador.pushNamed(RutasAplicacion.configuracion),
      ),
      _OpcionMenu(
        'Cómo jugar',
        Icons.help_outline_rounded,
        () => navegador.pushNamed(RutasAplicacion.instrucciones),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [esquema.primaryContainer, esquema.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '15-Puzzle',
                      textAlign: TextAlign.center,
                      style: estiloTexto.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: esquema.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    for (var i = 0; i < opciones.length; i++)
                      _AparicionEscalonada(
                        indice: i,
                        animar: animar,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _BotonMenu(
                            opcion: opciones[i],
                            animar: animar,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionMenu {
  const _OpcionMenu(this.etiqueta, this.icono, this.alPulsar);

  final String etiqueta;
  final IconData icono;
  final VoidCallback alPulsar;
}

/// Aparición escalonada: cada botón entra un poco después del anterior.
class _AparicionEscalonada extends StatelessWidget {
  const _AparicionEscalonada({
    required this.indice,
    required this.animar,
    required this.child,
  });

  final int indice;
  final bool animar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animar) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + indice * 120),
      curve: Curves.easeOut,
      builder: (context, valor, hijo) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, (1 - valor) * 24),
          child: hijo,
        ),
      ),
      child: child,
    );
  }
}

/// Botón grande con animación de presión (escala y cambio de color).
class _BotonMenu extends StatefulWidget {
  const _BotonMenu({required this.opcion, required this.animar});

  final _OpcionMenu opcion;
  final bool animar;

  @override
  State<_BotonMenu> createState() => _EstadoBotonMenu();
}

class _EstadoBotonMenu extends State<_BotonMenu> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fondo = _presionado ? esquema.primaryContainer : esquema.primary;
    final textoSobreFondo =
        _presionado ? esquema.onPrimaryContainer : esquema.onPrimary;
    final radio = BorderRadius.circular(20);
    final duracion =
        widget.animar ? const Duration(milliseconds: 150) : Duration.zero;

    return AnimatedScale(
      scale: widget.animar && _presionado ? 0.96 : 1,
      duration: duracion,
      child: AnimatedContainer(
        duration: duracion,
        decoration: BoxDecoration(color: fondo, borderRadius: radio),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radio,
            onHighlightChanged: (valor) => setState(() => _presionado = valor),
            onTap: widget.opcion.alPulsar,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.opcion.icono, color: textoSobreFondo, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    widget.opcion.etiqueta,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textoSobreFondo,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
