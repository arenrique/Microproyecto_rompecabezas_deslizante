import 'package:flutter/services.dart';

/// Reproduce el sonido de clic del sistema.
///
/// No usa paquetes de audio. Funciona en Android e iOS; en otras plataformas
/// (por ejemplo, web) puede no producir sonido. Cualquier error se ignora.
void reproducirClic() {
  SystemSound.play(SystemSoundType.click).catchError((Object _) {});
}
