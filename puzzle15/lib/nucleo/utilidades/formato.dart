/// Formatea una duración como `mm:ss`.
String formatearDuracion(Duration duracion) {
  final totalSegundos = duracion.inSeconds;
  final minutos = totalSegundos ~/ 60;
  final segundos = totalSegundos % 60;
  return '${minutos.toString().padLeft(2, '0')}:'
      '${segundos.toString().padLeft(2, '0')}';
}
