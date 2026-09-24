import 'medicamento_entity.dart';
import 'lote_entity.dart';

/// Representa una línea de inventario físico en el Almacén General
class StockAlmacenEntity {
  final String id;
  final String loteId;
  final String areaCodigo;
  final int cantidad;
  final DateTime updatedAt;
  final MedicamentoEntity medicamento;
  final LoteEntity lote;

  const StockAlmacenEntity({
    required this.id,
    required this.loteId,
    this.areaCodigo = 'ALMACEN',
    required this.cantidad,
    required this.updatedAt,
    required this.medicamento,
    required this.lote,
  });
}
