import '../../domain/entities/stock_almacen_entity.dart';
import '../../domain/entities/medicamento_entity.dart';

/// Estado sellado de la interfaz de Almacén
sealed class AlmacenState {
  const AlmacenState();
}

/// Estado inicial antes de cargar datos
class AlmacenInitial extends AlmacenState {
  const AlmacenInitial();
}

/// Estado de carga (consultando inventario en Supabase)
class AlmacenLoading extends AlmacenState {
  const AlmacenLoading();
}

/// Estado con datos de inventario cargados exitosamente
class AlmacenLoaded extends AlmacenState {
  final List<StockAlmacenEntity> inventario;
  final List<MedicamentoEntity> catalogo;

  const AlmacenLoaded({
    required this.inventario,
    required this.catalogo,
  });

  /// Total de unidades físicas en stock
  int get totalUnidades => inventario.fold(0, (sum, item) => sum + item.cantidad);

  /// Cantidad de lotes en estado crítico (< 30 días de vencimiento)
  int get lotesCriticos =>
      inventario.where((item) => item.lote.diasParaVencer <= 30 && item.lote.diasParaVencer > 0).length;

  /// Cantidad de lotes vencidos
  int get lotesVencidos =>
      inventario.where((item) => item.lote.diasParaVencer <= 0).length;

  /// Cantidad de medicamentos que requieren cadena de frío
  int get articulosCadenaFrio =>
      inventario.where((item) => item.medicamento.requiereCadenaFrio).length;
}

/// Estado de error
class AlmacenError extends AlmacenState {
  final String message;
  const AlmacenError(this.message);
}
