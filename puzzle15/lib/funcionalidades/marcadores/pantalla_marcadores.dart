import 'package:flutter/material.dart';

import '../../nucleo/widgets/seccion_provisional.dart';

class PantallaMarcadores extends StatelessWidget {
  const PantallaMarcadores({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeccionProvisional(
      titulo: 'Marcadores',
      icono: Icons.emoji_events_rounded,
      mensaje: 'En construccion.',
    );
  }
}
