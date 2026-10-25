import 'package:flutter/material.dart';

import 'servicio_records.dart';

/// Expone [ServicioRecords] a todo el árbol de widgets.
class ProveedorRecords extends InheritedNotifier<ServicioRecords> {
  const ProveedorRecords({
    super.key,
    required ServicioRecords servicio,
    required super.child,
  }) : super(notifier: servicio);

  /// Obtiene el servicio y suscribe al widget (usar en `build`).
  static ServicioRecords de(BuildContext context) {
    final proveedor =
        context.dependOnInheritedWidgetOfExactType<ProveedorRecords>();
    assert(proveedor != null, 'Falta un ProveedorRecords en el árbol.');
    return proveedor!.notifier!;
  }

  /// Obtiene el servicio sin suscribirse (usar en manejadores de eventos).
  static ServicioRecords leer(BuildContext context) {
    final proveedor =
        context.getInheritedWidgetOfExactType<ProveedorRecords>();
    assert(proveedor != null, 'Falta un ProveedorRecords en el árbol.');
    return proveedor!.notifier!;
  }
}
