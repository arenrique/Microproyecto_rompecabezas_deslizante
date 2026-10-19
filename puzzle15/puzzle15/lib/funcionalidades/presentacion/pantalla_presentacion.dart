import 'dart:async';

import 'package:flutter/material.dart';

import '../../nucleo/rutas.dart';

/// Pantalla inicial: título con fade-in y escala, y paso automático al menú.
class PantallaPresentacion extends StatefulWidget {
  const PantallaPresentacion({super.key});

  static const Duration retardoNavegacionAutomatica = Duration(seconds: 3);

  @override
  State<PantallaPresentacion> createState() => _EstadoPantallaPresentacion();
}

class _EstadoPantallaPresentacion extends State<PantallaPresentacion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final Animation<double> _desvanecimiento;
  late final Animation<double> _escala;
  Timer? _temporizador;
  bool _yaNavego = false;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _desvanecimiento = CurvedAnimation(
      parent: _controlador,
      curve: Curves.easeOut,
    );
    _escala = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _controlador, curve: Curves.easeOutBack));
    _controlador.forward();
    _temporizador = Timer(
      PantallaPresentacion.retardoNavegacionAutomatica,
      _irAlMenu,
    );
  }

  void _irAlMenu() {
    if (_yaNavego || !mounted) return;
    _yaNavego = true;
    _temporizador?.cancel();
    Navigator.of(context).pushReplacementNamed(RutasAplicacion.menu);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estiloTexto = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _desvanecimiento,
                child: ScaleTransition(
                  scale: _escala,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: esquema.primary,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 64,
                            color: esquema.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '15-Puzzle Flutter',
                          textAlign: TextAlign.center,
                          style: estiloTexto.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: esquema.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: TextButton(
                onPressed: _irAlMenu,
                child: const Text('Saltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
