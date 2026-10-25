/// Formatea una duración como `mm:ss`.
String formatearDuracion(Duration duracion) {
  final totalSegundos = duracion.inSeconds;
  final minutos = totalSegundos ~/ 60;
  final segundos = totalSegundos % 60;
  return '${minutos.toString().padLeft(2, '0')}:'
      '${segundos.toString().padLeft(2, '0')}';
}

/// Formatea una fecha como `dd/mm/aaaa`.
String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}
