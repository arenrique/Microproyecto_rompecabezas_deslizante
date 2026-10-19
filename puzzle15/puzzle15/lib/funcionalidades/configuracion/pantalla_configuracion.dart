import 'package:flutter/material.dart';

import '../../nucleo/widgets/seccion_provisional.dart';

class PantallaConfiguracion extends StatelessWidget {
  const PantallaConfiguracion({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeccionProvisional(
      titulo: 'Configuración',
      icono: Icons.settings_rounded,
      mensaje: 'En construccion.',
    );
  }
}
