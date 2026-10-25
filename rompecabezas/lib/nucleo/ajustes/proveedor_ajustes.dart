import 'package:flutter/material.dart';

import 'ajustes_aplicacion.dart';

/// Expone [AjustesAplicacion] a todo el árbol de widgets sin paquetes
/// externos. Los widgets que llaman a [de] se reconstruyen cuando cambian los
/// ajustes.
class ProveedorAjustes extends InheritedNotifier<AjustesAplicacion> {
  const ProveedorAjustes({
    super.key,
    required AjustesAplicacion ajustes,
    required super.child,
  }) : super(notifier: ajustes);

  /// Obtiene los ajustes y suscribe al widget para reconstruirse (usar en
  /// `build`).
  static AjustesAplicacion de(BuildContext context) {
    final proveedor =
        context.dependOnInheritedWidgetOfExactType<ProveedorAjustes>();
    assert(proveedor != null, 'Falta un ProveedorAjustes en el árbol.');
    return proveedor!.notifier!;
  }

  /// Obtiene los ajustes sin suscribirse (usar en manejadores de eventos).
  static AjustesAplicacion leer(BuildContext context) {
    final proveedor =
        context.getInheritedWidgetOfExactType<ProveedorAjustes>();
    assert(proveedor != null, 'Falta un ProveedorAjustes en el árbol.');
    return proveedor!.notifier!;
  }
}
