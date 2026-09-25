/// Entidad pura de Dominio que representa un ítem solicitado en un pedido de abastecimiento
class PedidoAbastecimientoItemEntity {
  final String id;
  final String pedidoId;
  final String medicamentoId;
  final String nombreMedicamento;
  final String concentracion;
  final int cantidadSolicitada;
  final int cantidadDespachada;

  const PedidoAbastecimientoItemEntity({
    required this.id,
    required this.pedidoId,
    required this.medicamentoId,
    required this.nombreMedicamento,
    this.concentracion = '',
    required this.cantidadSolicitada,
    this.cantidadDespachada = 0,
  });
}

/// Entidad pura de Dominio que representa una solicitud de abastecimiento de Farmacia a Almacén (RF-030 / RF-031)
class PedidoAbastecimientoEntity {
  final String id;
  final String codigo;
  final String? solicitanteId;
  final String solicitanteNombre;
  final String areaOrigen;
  final String areaDestino;
  final String estado; // 'PENDIENTE', 'DESPACHADO', 'RECIBIDO', 'RECHAZADO'
  final String? notas;
  final DateTime fechaSolicitud;
  final DateTime? fechaDespacho;
  final List<PedidoAbastecimientoItemEntity> items;

  const PedidoAbastecimientoEntity({
    required this.id,
    required this.codigo,
    this.solicitanteId,
    this.solicitanteNombre = 'Guardia de Farmacia',
    this.areaOrigen = 'FARMACIA',
    this.areaDestino = 'ALMACEN',
    this.estado = 'PENDIENTE',
    this.notas,
    required this.fechaSolicitud,
    this.fechaDespacho,
    this.items = const [],
  });

  bool get esPendiente => estado == 'PENDIENTE';
  bool get esDespachado => estado == 'DESPACHADO';

  /// Total de unidades solicitadas en la orden
  int get totalUnidadesSolicitadas =>
      items.fold(0, (sum, i) => sum + i.cantidadSolicitada);
}
