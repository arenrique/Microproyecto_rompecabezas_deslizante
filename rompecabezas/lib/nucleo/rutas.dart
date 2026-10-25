import 'package:flutter/material.dart';

import '../funcionalidades/configuracion/pantalla_configuracion.dart';
import '../funcionalidades/instrucciones/pantalla_instrucciones.dart';
import '../funcionalidades/juego/pantalla_juego.dart';
import '../funcionalidades/marcadores/pantalla_marcadores.dart';
import '../funcionalidades/menu/pantalla_menu_principal.dart';
import '../funcionalidades/presentacion/pantalla_presentacion.dart';
import 'logica/dificultad.dart';

/// Nombres de ruta y generador central de rutas con transición suave.
class RutasAplicacion {
  RutasAplicacion._();

  static const String presentacion = '/';
  static const String menu = '/menu';
  static const String juego = '/juego';
  static const String marcadores = '/marcadores';
  static const String configuracion = '/configuracion';
  static const String instrucciones = '/instrucciones';

  static Route<dynamic> alGenerarRuta(RouteSettings ajustes) {
    final Widget pagina;
    switch (ajustes.name) {
      case presentacion:
        pagina = const PantallaPresentacion();
      case menu:
        pagina = const PantallaMenuPrincipal();
      case juego:
        pagina = PantallaJuego(dificultad: _dificultadDe(ajustes.arguments));
      case marcadores:
        pagina = const PantallaMarcadores();
      case configuracion:
        pagina = const PantallaConfiguracion();
      case instrucciones:
        pagina = const PantallaInstrucciones();
      default:
        pagina = const PantallaMenuPrincipal();
    }
    return PageRouteBuilder<void>(
      settings: ajustes,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => pagina,
      transitionsBuilder: (_, animacion, _, hijo) => FadeTransition(
        opacity: CurvedAnimation(parent: animacion, curve: Curves.easeOut),
        child: hijo,
      ),
    );
  }

  /// La dificultad viaja como argumento de la ruta; por defecto, Medio.
  static Dificultad _dificultadDe(Object? argumento) {
    return argumento is Dificultad ? argumento : Dificultad.medio;
  }
}
