import 'package:flutter/material.dart';

import '../logica/dificultad.dart';
import 'estilo_ficha.dart';

/// Preferencias del usuario. Viven en memoria mientras la aplicación está
/// abierta y notifican a la interfaz cada vez que cambian, de modo que los
/// cambios se ven de inmediato. No se guardan entre sesiones.
class AjustesAplicacion extends ChangeNotifier {
  Dificultad _dificultad = Dificultad.medio;
  ThemeMode _modoTema = ThemeMode.system;
  EstiloFicha _estiloFichas = EstiloFicha.clasico;
  bool _animacionesActivas = true;
  bool _sonidoActivo = false;

  /// Dificultad que se aplicará a la próxima partida nueva.
  Dificultad get dificultad => _dificultad;
  ThemeMode get modoTema => _modoTema;
  EstiloFicha get estiloFichas => _estiloFichas;
  bool get animacionesActivas => _animacionesActivas;
  bool get sonidoActivo => _sonidoActivo;

  void establecerDificultad(Dificultad valor) {
    if (valor == _dificultad) return;
    _dificultad = valor;
    notifyListeners();
  }

  void establecerModoTema(ThemeMode valor) {
    if (valor == _modoTema) return;
    _modoTema = valor;
    notifyListeners();
  }

  void establecerEstiloFichas(EstiloFicha valor) {
    if (valor == _estiloFichas) return;
    _estiloFichas = valor;
    notifyListeners();
  }

  void establecerAnimaciones(bool valor) {
    if (valor == _animacionesActivas) return;
    _animacionesActivas = valor;
    notifyListeners();
  }

  void establecerSonido(bool valor) {
    if (valor == _sonidoActivo) return;
    _sonidoActivo = valor;
    notifyListeners();
  }
}
