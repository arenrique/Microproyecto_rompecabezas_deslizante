import 'dart:async';

import 'package:flutter/material.dart';

import '../../nucleo/ajustes/proveedor_ajustes.dart';
import '../../nucleo/logica/dificultad.dart';
import '../../nucleo/logica/partida.dart';
import '../../nucleo/records/proveedor_records.dart';
import '../../nucleo/records/records_dificultad.dart';
import '../../nucleo/utilidades/formato.dart';
import '../../nucleo/utilidades/sonido.dart';
import 'widgets/dialogo_victoria.dart';
import 'widgets/vista_tablero.dart';

/// Pantalla de juego. Es un [StatefulWidget] porque el tablero, el contador de
/// movimientos y el cronómetro cambian durante la partida; se usa `setState`
/// únicamente tras un movimiento válido, al reiniciar y en cada tic del
/// cronómetro.
class PantallaJuego extends StatefulWidget {
  const PantallaJuego({
    super.key,
    this.dificultad = Dificultad.medio,
    this.partidaInicial,
  });

  /// Dificultad de la partida. Se fija al abrir la pantalla.
  final Dificultad dificultad;

  /// Permite inyectar una partida concreta (se usa en las pruebas).
  final Partida? partidaInicial;

  @override
  State<PantallaJuego> createState() => _EstadoPantallaJuego();
}

class _EstadoPantallaJuego extends State<PantallaJuego> {
  late final Partida _partida;
  Timer? _temporizador;
  ActualizacionRecord? _actualizacionRecord;

  @override
  void initState() {
    super.initState();
    _partida = widget.partidaInicial ?? Partida(dificultad: widget.dificultad);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _iniciarTemporizador() {
    _temporizador ??= Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  void _detenerTemporizador() {
    _temporizador?.cancel();
    _temporizador = null;
  }

  void _alPulsarFicha(int indice) {
    if (!_partida.mover(indice)) return;
    if (ProveedorAjustes.leer(context).sonidoActivo) reproducirClic();
    if (_partida.estado == EstadoPartida.enCurso) {
      _iniciarTemporizador();
    } else if (_partida.estado == EstadoPartida.victoria) {
      _detenerTemporizador();
      _registrarVictoria();
    }
    setState(() {});
    if (_partida.estado == EstadoPartida.victoria) {
      unawaited(_mostrarVictoria());
    }
  }

  /// Espera un instante para que se vea deslizar la última ficha y muestra el
  /// resumen de la partida.
  Future<void> _mostrarVictoria() async {
    final animar = ProveedorAjustes.leer(context).animacionesActivas;
    await Future<void>.delayed(
      animar ? const Duration(milliseconds: 350) : Duration.zero,
    );
    if (!mounted || _partida.estado != EstadoPartida.victoria) return;

    final accion = await showDialog<AccionVictoria>(
      context: context,
      builder: (_) => DialogoVictoria(
        dificultad: _partida.dificultad,
        tiempo: _partida.tiempo,
        movimientos: _partida.movimientos,
        actualizacion: _actualizacionRecord,
      ),
    );
    if (!mounted) return;
    switch (accion) {
      case AccionVictoria.reiniciar:
        _reiniciar();
      case AccionVictoria.menu:
        unawaited(Navigator.of(context).maybePop());
      case null:
        break;
    }
  }

  Future<void> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Se perderá el progreso de esta partida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Seguir jugando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (salir != true || !mounted) return;
    _detenerTemporizador();
    Navigator.of(context).pop();
  }

  void _reiniciar() {
    _detenerTemporizador();
    setState(() {
      _partida.reiniciar();
      _actualizacionRecord = null;
    });
  }

  /// Guarda el resultado en los récords. Se ejecuta una sola vez por victoria:
  /// si ya hay una actualización registrada, no hace nada.
  void _registrarVictoria() {
    if (_actualizacionRecord != null) return;
    _actualizacionRecord = ProveedorRecords.leer(context).registrar(
      ResultadoPartida(
        dificultad: _partida.dificultad,
        tiempo: _partida.tiempo,
        movimientos: _partida.movimientos,
        fecha: DateTime.now(),
      ),
    );
  }

  Future<void> _solicitarReinicio() async {
    if (_partida.estado == EstadoPartida.enCurso) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          title: const Text('¿Reiniciar la partida?'),
          content: const Text('Perderás el progreso actual.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Reiniciar'),
            ),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;
    }
    _reiniciar();
  }

  @override
  Widget build(BuildContext context) {
    final n = _partida.dificultad.tamano;
    final ajustes = ProveedorAjustes.de(context);

    final tablero = VistaTablero(
      tablero: _partida.tablero,
      alPulsarFicha: _alPulsarFicha,
      estilo: ajustes.estiloFichas,
      animar: ajustes.animacionesActivas,
      habilitado: _partida.estado != EstadoPartida.victoria,
    );
    final estadisticas = _Estadisticas(
      movimientos: _partida.movimientos,
      tiempo: _partida.tiempo,
    );
    final estado = _EtiquetaEstado(
      estado: _partida.estado,
      nuevoRecord: _actualizacionRecord?.esNuevoRecord ?? false,
    );
    final reiniciar = FilledButton.tonalIcon(
      onPressed: _solicitarReinicio,
      icon: const Icon(Icons.refresh),
      label: const Text('Reiniciar'),
    );

    return PopScope<Object?>(
      canPop: _partida.estado != EstadoPartida.enCurso,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmarSalida());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Jugar · ${_partida.dificultad.etiqueta} ($n×$n)'),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, restricciones) {
              final apaisado = restricciones.maxWidth > restricciones.maxHeight;
              if (apaisado) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(child: tablero),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 280,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                estadisticas,
                                const SizedBox(height: 16),
                                estado,
                                const SizedBox(height: 16),
                                reiniciar,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    estadisticas,
                    const SizedBox(height: 12),
                    estado,
                    const SizedBox(height: 12),
                    Expanded(child: tablero),
                    const SizedBox(height: 12),
                    reiniciar,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Estadisticas extends StatelessWidget {
  const _Estadisticas({required this.movimientos, required this.tiempo});

  final int movimientos;
  final Duration tiempo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Dato(
            clave: const Key('movimientos'),
            etiqueta: 'Movimientos',
            valor: '$movimientos',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Dato(
            clave: const Key('tiempo'),
            etiqueta: 'Tiempo',
            valor: formatearDuracion(tiempo),
          ),
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.clave,
    required this.etiqueta,
    required this.valor,
  });

  final Key clave;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estilos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(etiqueta, style: estilos.labelMedium),
          const SizedBox(height: 4),
          Text(
            valor,
            key: clave,
            style: estilos.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.estado, this.nuevoRecord = false});

  final EstadoPartida estado;
  final bool nuevoRecord;

  String get _mensaje => switch (estado) {
    EstadoPartida.preparada =>
      'Toca una ficha junto al espacio vacío para empezar',
    EstadoPartida.enCurso => 'Partida en curso',
    EstadoPartida.victoria =>
      nuevoRecord ? '¡Resuelto! ¡Nuevo récord!' : '¡Resuelto!',
  };

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final esVictoria = estado == EstadoPartida.victoria;
    return Semantics(
      liveRegion: true,
      child: Text(
        _mensaje,
        key: const Key('estado_partida'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: esVictoria ? esquema.primary : esquema.onSurfaceVariant,
          fontWeight: esVictoria ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}
