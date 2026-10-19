import 'package:flutter/material.dart';

import 'nucleo/rutas.dart';
import 'nucleo/tema/tema_aplicacion.dart';

class AplicacionRompecabezas extends StatelessWidget {
  const AplicacionRompecabezas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '15-Puzzle Flutter',
      debugShowCheckedModeBanner: false,
      theme: TemaAplicacion.claro,
      darkTheme: TemaAplicacion.oscuro,
      themeMode: ThemeMode.system,
      initialRoute: RutasAplicacion.presentacion,
      onGenerateRoute: RutasAplicacion.alGenerarRuta,
    );
  }
}
