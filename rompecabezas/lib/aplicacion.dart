import 'package:flutter/material.dart';

import 'nucleo/ajustes/ajustes_aplicacion.dart';
import 'nucleo/ajustes/proveedor_ajustes.dart';
import 'nucleo/records/almacen_records.dart';
import 'nucleo/records/proveedor_records.dart';
import 'nucleo/records/servicio_records.dart';
import 'nucleo/rutas.dart';
import 'nucleo/tema/tema_aplicacion.dart';

/// Raíz de la aplicación. Es un [StatefulWidget] porque es dueña de los
/// objetos de estado compartido (ajustes y récords), que deben crearse una sola
/// vez y liberarse al cerrar.
class AplicacionRompecabezas extends StatefulWidget {
  const AplicacionRompecabezas({
    super.key,
    this.almacenRecords = const AlmacenRecordsPreferencias(),
  });

  /// Dónde se guardan los récords (se puede sustituir en las pruebas).
  final AlmacenRecords almacenRecords;

  @override
  State<AplicacionRompecabezas> createState() =>
      _EstadoAplicacionRompecabezas();
}

class _EstadoAplicacionRompecabezas extends State<AplicacionRompecabezas> {
  final AjustesAplicacion _ajustes = AjustesAplicacion();
  late final ServicioRecords _records;

  @override
  void initState() {
    super.initState();
    _records = ServicioRecords(widget.almacenRecords);
    _records.cargar();
  }

  @override
  void dispose() {
    _ajustes.dispose();
    _records.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProveedorAjustes(
      ajustes: _ajustes,
      child: ProveedorRecords(
        servicio: _records,
        child: ListenableBuilder(
          listenable: _ajustes,
          builder: (context, _) => MaterialApp(
            title: '15-Puzzle Flutter',
            debugShowCheckedModeBanner: false,
            theme: TemaAplicacion.claro,
            darkTheme: TemaAplicacion.oscuro,
            themeMode: _ajustes.modoTema,
            initialRoute: RutasAplicacion.presentacion,
            onGenerateRoute: RutasAplicacion.alGenerarRuta,
          ),
        ),
      ),
    );
  }
}
