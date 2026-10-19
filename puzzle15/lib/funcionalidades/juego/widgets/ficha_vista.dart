import 'package:flutter/material.dart';

/// Una ficha numerada del tablero.
class FichaVista extends StatelessWidget {
  const FichaVista({super.key, required this.valor, this.alPulsar});

  final int valor;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Ficha $valor',
      button: true,
      child: Material(
        color: esquema.primaryContainer,
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
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
                    color: esquema.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
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
