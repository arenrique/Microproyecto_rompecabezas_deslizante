/// Niveles de dificultad del juego. Cada uno define el tamaño del tablero.
enum Dificultad {
  facil(3, 'Fácil'),
  medio(4, 'Medio'),
  dificil(5, 'Difícil');

  const Dificultad(this.tamano, this.etiqueta);

  /// Número de filas y de columnas del tablero.
  final int tamano;

  /// Nombre que se muestra al usuario.
  final String etiqueta;

  /// Cantidad de fichas numeradas (sin contar el espacio vacío).
  int get cantidadFichas => tamano * tamano - 1;
}
