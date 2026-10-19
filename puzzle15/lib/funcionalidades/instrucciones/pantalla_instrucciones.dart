import 'package:flutter/material.dart';

import '../../nucleo/widgets/seccion_provisional.dart';

class PantallaInstrucciones extends StatelessWidget {
  const PantallaInstrucciones({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeccionProvisional(
      titulo: '¿Cómo jugar?',
      icono: Icons.help_outline_rounded,
      mensaje: 'En construccion.',
    );
  }
}
