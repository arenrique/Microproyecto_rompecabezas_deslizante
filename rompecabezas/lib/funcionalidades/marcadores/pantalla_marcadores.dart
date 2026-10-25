import 'package:flutter/material.dart';

import '../../nucleo/logica/dificultad.dart';
import '../../nucleo/records/proveedor_records.dart';
import '../../nucleo/records/records_dificultad.dart';
import '../../nucleo/records/servicio_records.dart';
import '../../nucleo/utilidades/formato.dart';

/// Tabla de récords por dificultad. El estado vive en [ServicioRecords]; la
/// pantalla se reconstruye sola cuando cambia, por lo que no necesita
/// `setState`.
class PantallaMarcadores extends StatelessWidget {
  const PantallaMarcadores({super.key});

  Future<void> _confirmarBorrado(
    BuildContext context,
    ServicioRecords servicio,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('¿Borrar todos los marcadores?'),
        content: const Text(
          'Se eliminarán los récords de todas las dificultades. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar == true) await servicio.borrarTodo();
  }

  @override
  Widget build(BuildContext context) {
    final servicio = ProveedorRecords.de(context);
    final hayRecords = servicio.hayRecords;

    return Scaffold(
      appBar: AppBar(title: const Text('Marcadores')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: hayRecords
                        ? ListView(
                            children: [
                              for (final dificultad in Dificultad.values)
                                _TarjetaDificultad(
                                  dificultad: dificultad,
                                  records: servicio.recordsDe(dificultad),
                                ),
                            ],
                          )
                        : const _SinRecords(),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('borrar_marcadores'),
                    onPressed: hayRecords
                        ? () => _confirmarBorrado(context, servicio)
                        : null,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Borrar marcadores'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al menú'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SinRecords extends StatelessWidget {
  const _SinRecords();

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estilos = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 72,
                color: esquema.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Todavía no hay récords',
                textAlign: TextAlign.center,
                style: estilos.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Termina una partida y aquí aparecerán tu mejor tiempo y tu '
                'menor número de movimientos.',
                textAlign: TextAlign.center,
                style: estilos.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaDificultad extends StatelessWidget {
  const _TarjetaDificultad({required this.dificultad, required this.records});

  final Dificultad dificultad;
  final RecordsDificultad records;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final n = dificultad.tamano;
    final tiempo = records.mejorTiempo;
    final movimientos = records.menosMovimientos;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${dificultad.etiqueta} · $n×$n',
                style: estilos.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: esquema.primary,
                ),
              ),
            ),
            if (records.estaVacio)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  'Aún sin récord',
                  style: estilos.bodyMedium?.copyWith(
                    color: esquema.onSurfaceVariant,
                  ),
                ),
              )
            else ...[
              if (tiempo != null)
                _FilaRecord(
                  icono: Icons.timer_outlined,
                  etiqueta: 'Mejor tiempo',
                  valor: formatearDuracion(tiempo),
                  claveValor: Key('tiempo_${dificultad.name}'),
                  fecha: records.fechaMejorTiempo,
                ),
              if (movimientos != null)
                _FilaRecord(
                  icono: Icons.touch_app_outlined,
                  etiqueta: 'Menos movimientos',
                  valor: '$movimientos',
                  claveValor: Key('movimientos_${dificultad.name}'),
                  fecha: records.fechaMenosMovimientos,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilaRecord extends StatelessWidget {
  const _FilaRecord({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.claveValor,
    required this.fecha,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final Key claveValor;
  final DateTime? fecha;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icono),
      title: Text(etiqueta),
      subtitle: Text(
        fecha == null ? 'Fecha desconocida' : formatearFecha(fecha!),
      ),
      trailing: Text(
        valor,
        key: claveValor,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
