/// Aspecto visual de las fichas del tablero.
enum EstiloFicha {
  clasico('Numérico clásico'),
  colorido('Colorido'),
  retro('Retro'),
  minimalista('Minimalista');

  const EstiloFicha(this.etiqueta);

  final String etiqueta;
}
