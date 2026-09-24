import '../../domain/entities/stock_almacen_entity.dart';
import 'lote_model.dart';
import 'medicamento_model.dart';

/// Modelo de datos para StockAlmacen (mapeo con resultado join de Supabase)
class StockAlmacenModel extends StockAlmacenEntity {
  const StockAlmacenModel({
    required super.id,
    required super.loteId,
    super.areaCodigo,
    required super.cantidad,
    required super.updatedAt,
    required super.medicamento,
    required super.lote,
  });

  factory StockAlmacenModel.fromMap(Map<String, dynamic> map) {
    final loteMap = map['lote'] as Map<String, dynamic>? ?? {};
    final medicamentoMap = loteMap['medicamento'] as Map<String, dynamic>? ?? {};

    return StockAlmacenModel(
      id: map['id']?.toString() ?? '',
      loteId: map['lote_id']?.toString() ?? '',
      areaCodigo: map['area_codigo']?.toString() ?? 'ALMACEN',
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 0,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lote: LoteModel.fromMap(loteMap),
      medicamento: MedicamentoModel.fromMap(medicamentoMap),
    );
  }
}
