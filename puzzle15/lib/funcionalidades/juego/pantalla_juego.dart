import 'package:flutter/material.dart';

import '../../nucleo/widgets/seccion_provisional.dart';

class PantallaJuego extends StatelessWidget {
  const PantallaJuego({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeccionProvisional(
      titulo: 'Jugar',
      icono: Icons.grid_view_rounded,
      mensaje: 'En construccion.',
    );
  }
}
