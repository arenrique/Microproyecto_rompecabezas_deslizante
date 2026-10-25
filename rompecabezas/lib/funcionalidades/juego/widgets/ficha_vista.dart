import 'package:flutter/material.dart';

import '../../../nucleo/ajustes/estilo_ficha.dart';

/// Una ficha numerada del tablero, con el aspecto del [estilo] elegido.
class FichaVista extends StatelessWidget {
  const FichaVista({
    super.key,
    required this.valor,
    required this.totalFichas,
    required this.estilo,
    this.alPulsar,
  });

  final int valor;

  /// Cantidad de fichas numeradas del tablero (se usa para repartir colores).
  final int totalFichas;
  final EstiloFicha estilo;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final aspecto = _Aspecto.de(
      estilo: estilo,
      valor: valor,
      totalFichas: totalFichas,
      esquema: tema.colorScheme,
      oscuro: tema.brightness == Brightness.dark,
    );
    return Semantics(
      label: 'Ficha $valor',
      button: true,
      child: Material(
        color: aspecto.fondo,
        elevation: aspecto.elevacion,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(aspecto.radio),
          side: aspecto.borde,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alPulsar,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                child: Text(
                  '$valor',
                  style: TextStyle(
                    color: aspecto.texto,
                    fontWeight: aspecto.peso,
                    fontFamily: aspecto.fuente,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Aspecto {
  const _Aspecto({
    required this.fondo,
    required this.texto,
    required this.borde,
    required this.radio,
    required this.elevacion,
    required this.peso,
    this.fuente,
  });

  final Color fondo;
  final Color texto;
  final BorderSide borde;
  final double radio;
  final double elevacion;
  final FontWeight peso;
  final String? fuente;

  factory _Aspecto.de({
    required EstiloFicha estilo,
    required int valor,
    required int totalFichas,
    required ColorScheme esquema,
    required bool oscuro,
  }) {
    switch (estilo) {
      case EstiloFicha.clasico:
        return _Aspecto(
          fondo: esquema.primaryContainer,
          texto: esquema.onPrimaryContainer,
          borde: BorderSide.none,
          radio: 12,
          elevacion: 1,
          peso: FontWeight.w700,
        );
      case EstiloFicha.colorido:
        final tono = ((valor - 1) / totalFichas) * 360;
        return _Aspecto(
          fondo: HSLColor.fromAHSL(1, tono, 0.65, oscuro ? 0.38 : 0.42)
              .toColor(),
          texto: Colors.white,
          borde: BorderSide.none,
          radio: 12,
          elevacion: 1,
          peso: FontWeight.w800,
        );
      case EstiloFicha.retro:
        const dorado = Color(0xFFFFD166);
        return const _Aspecto(
          fondo: Color(0xFF2B2B2B),
          texto: dorado,
          borde: BorderSide(color: dorado, width: 3),
          radio: 2,
          elevacion: 0,
          peso: FontWeight.w700,
          fuente: 'monospace',
        );
      case EstiloFicha.minimalista:
        return _Aspecto(
          fondo: Colors.transparent,
          texto: esquema.onSurface,
          borde: BorderSide(color: esquema.outline, width: 1.5),
          radio: 8,
          elevacion: 0,
          peso: FontWeight.w300,
        );
    }
  }
}
