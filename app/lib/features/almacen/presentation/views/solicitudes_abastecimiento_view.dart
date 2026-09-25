import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pedido_abastecimiento_entity.dart';
import '../states/almacen_state.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'dialogs/transferir_a_farmacia_dialog.dart';

/// Pantalla dedicada a la visualización y atención de solicitudes de abastecimiento
/// enviadas por la guardia de Farmacia Central hacia Almacén General (RF-031).
class SolicitudesAbastecimientoView extends StatefulWidget {
  const SolicitudesAbastecimientoView({super.key});

  @override
  State<SolicitudesAbastecimientoView> createState() =>
      _SolicitudesAbastecimientoViewState();
}

class _SolicitudesAbastecimientoViewState
    extends State<SolicitudesAbastecimientoView> {
  String _filtroEstado = 'PENDIENTE'; // 'TODAS', 'PENDIENTE', 'DESPACHADO'

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solicitudes de Abastecimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Peticiones de reposición de Farmacia (RF-031)', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.almacenColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: state is AlmacenLoaded
          ? _buildBody(context, state)
          : const Center(child: CircularProgressIndicator(color: AppColors.almacenColor)),
    );
  }

  Widget _buildBody(BuildContext context, AlmacenLoaded loaded) {
    final solicitudes = loaded.solicitudes;

    final filtradas = solicitudes.where((s) {
      if (_filtroEstado == 'PENDIENTE') return s.esPendiente;
      if (_filtroEstado == 'DESPACHADO') return s.esDespachado;
      return true;
    }).toList();

    return RefreshIndicator(
      color: AppColors.almacenColor,
      onRefresh: () => context.read<AlmacenViewModel>().cargarInventario(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Selector de Filtros
          Row(
            children: [
              _buildFilterChip('PENDIENTE', 'Pendientes (${loaded.solicitudesPendientes})', Colors.orange),
              const SizedBox(width: 8),
              _buildFilterChip('DESPACHADO', 'Atendidas', AppColors.success),
              const SizedBox(width: 8),
              _buildFilterChip('TODAS', 'Todas (${solicitudes.length})', AppColors.textSecondary),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Lista de Solicitudes
          if (filtradas.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    _filtroEstado == 'PENDIENTE'
                        ? 'No hay solicitudes pendientes'
                        : 'No se encontraron solicitudes',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _filtroEstado == 'PENDIENTE'
                        ? 'Farmacia Central no ha reportado faltantes de stock por ahora.'
                        : 'No hay pedidos que coincidan con el filtro seleccionado.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtradas[index];
                return _buildSolicitudCard(context, item, loaded);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String valor, String etiqueta, Color color) {
    final activo = _filtroEstado == valor;
    return ChoiceChip(
      label: Text(etiqueta),
      selected: activo,
      selectedColor: color.withOpacity(0.18),
      labelStyle: TextStyle(
        color: activo ? color : AppColors.textSecondary,
        fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _filtroEstado = valor),
    );
  }

  Widget _buildSolicitudCard(
    BuildContext context,
    PedidoAbastecimientoEntity item,
    AlmacenLoaded loaded,
  ) {
    final esPendiente = item.esPendiente;
    final estadoColor = esPendiente ? Colors.orange.shade800 : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esPendiente ? Colors.orange.shade300 : AppColors.surfaceVariant,
          width: esPendiente ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Código, Estado y Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.codigo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      esPendiente ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                      size: 14,
                      color: estadoColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.estado,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Solicitante y fecha
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.solicitanteNombre,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              Text(
                '${item.fechaSolicitud.day.toString().padLeft(2, '0')}/${item.fechaSolicitud.month.toString().padLeft(2, '0')} ${item.fechaSolicitud.hour.toString().padLeft(2, '0')}:${item.fechaSolicitud.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Lista de ítems solicitados
          const Text(
            'Medicamentos Solicitados:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),

          ...item.items.map((it) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.medication_outlined, size: 16, color: AppColors.almacenColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${it.nombreMedicamento} ${it.concentracion}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${it.cantidadSolicitada} unid.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Notas de la guardia (si las hay)
          if (item.notas != null && item.notas!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.speaker_notes_outlined, size: 16, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.notas!,
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Botón de Acción para Despachar / Atender
          if (esPendiente)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      // Abrir diálogo de transferencia rápida
                      showDialog(
                        context: context,
                        builder: (_) => TransferirAFarmaciaDialog(
                          inventario: loaded.inventario,
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Transferir Stock'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _confirmarAtencion(item),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Marcar Atendida'),
                  ),
                ),
              ],
            )
          else if (item.fechaDespacho != null)
            Row(
              children: [
                const Icon(Icons.done_all_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Despachado a Farmacia el ${item.fechaDespacho!.day}/${item.fechaDespacho!.month} a las ${item.fechaDespacho!.hour}:${item.fechaDespacho!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmarAtencion(PedidoAbastecimientoEntity item) {
    final notasController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final vm = context.read<AlmacenViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Atender Pedido ${item.codigo}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Desea confirmar el despacho y marcar esta solicitud de Farmacia como Atendida?',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notasController,
              decoration: const InputDecoration(
                labelText: 'Nota de Despacho (Opcional)',
                hintText: 'Ej: Entregado completo en caja térmica',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final exito = await vm.atenderSolicitudAbastecimiento(
                pedidoId: item.id,
                notasDespacho: notasController.text.trim(),
              );
              if (exito) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ Solicitud ${item.codigo} marcada como Atendida.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Confirmar Atención'),
          ),
        ],
      ),
    );
  }
}
