import '../../domain/entities/pedido_abastecimiento_entity.dart';

class PedidoAbastecimientoItemModel extends PedidoAbastecimientoItemEntity {
  const PedidoAbastecimientoItemModel({
    required super.id,
    required super.pedidoId,
    required super.medicamentoId,
    required super.nombreMedicamento,
    super.concentracion,
    required super.cantidadSolicitada,
    super.cantidadDespachada,
  });

  factory PedidoAbastecimientoItemModel.fromMap(Map<String, dynamic> map) {
    final med = map['medicamento'] as Map<String, dynamic>?;

    return PedidoAbastecimientoItemModel(
      id: map['id']?.toString() ?? '',
      pedidoId: map['pedido_id']?.toString() ?? '',
      medicamentoId: map['medicamento_id']?.toString() ?? '',
      nombreMedicamento: med?['nombre_comercial']?.toString() ?? 'Medicamento Solicitado',
      concentracion: med?['concentracion']?.toString() ?? '',
      cantidadSolicitada: (map['cantidad_solicitada'] as num?)?.toInt() ?? 0,
      cantidadDespachada: (map['cantidad_despachada'] as num?)?.toInt() ?? 0,
    );
  }
}

class PedidoAbastecimientoModel extends PedidoAbastecimientoEntity {
  const PedidoAbastecimientoModel({
    required super.id,
    required super.codigo,
    super.solicitanteId,
    super.solicitanteNombre,
    super.areaOrigen,
    super.areaDestino,
    super.estado,
    super.notas,
    required super.fechaSolicitud,
    super.fechaDespacho,
    super.items,
  });

  factory PedidoAbastecimientoModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsParsed = rawItems
        .map((i) => PedidoAbastecimientoItemModel.fromMap(i as Map<String, dynamic>))
        .toList();

    final profile = map['solicitante'] as Map<String, dynamic>?;

    return PedidoAbastecimientoModel(
      id: map['id']?.toString() ?? '',
      codigo: map['codigo']?.toString() ?? 'PED-2026',
      solicitanteId: map['solicitante_id']?.toString(),
      solicitanteNombre: profile?['nombre']?.toString() ?? 'Farmacia de Turno',
      areaOrigen: map['area_origen']?.toString() ?? 'FARMACIA',
      areaDestino: map['area_destino']?.toString() ?? 'ALMACEN',
      estado: map['estado']?.toString() ?? 'PENDIENTE',
      notas: map['notas']?.toString(),
      fechaSolicitud: map['fecha_solicitud'] != null
          ? DateTime.tryParse(map['fecha_solicitud'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fechaDespacho: map['fecha_despacho'] != null
          ? DateTime.tryParse(map['fecha_despacho'].toString())
          : null,
      items: itemsParsed,
    );
  }
}
