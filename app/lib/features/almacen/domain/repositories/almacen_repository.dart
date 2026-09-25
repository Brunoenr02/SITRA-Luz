import '../entities/medicamento_entity.dart';
import '../entities/lote_entity.dart';
import '../entities/stock_almacen_entity.dart';

/// Contrato del Repositorio de Almacén (Capa de Dominio)
abstract class AlmacenRepository {
  /// Obtiene la lista completa de stock disponible en el Almacén General
  Future<List<StockAlmacenEntity>> getInventarioAlmacen();

  /// Obtiene el catálogo maestro de medicamentos registrados
  Future<List<MedicamentoEntity>> getMedicamentos();

  /// Registra un nuevo medicamento maestro en el catálogo
  Future<MedicamentoEntity> registrarMedicamento({
    required String gtin,
    required String nombreComercial,
    required String principioActivo,
    required String formaFarmaceutica,
    required String concentracion,
    String? registroSanitario,
    String unidadPresentacion = 'unidad',
    int cantidadPorPresentacion = 1,
    bool requiereCadenaFrio = false,
    double temperaturaMin = 2.0,
    double temperaturaMax = 8.0,
  });

  /// Registra un ingreso de lote y agrega el stock correspondiente en Almacén
  Future<LoteEntity> registrarIngresoLote({
    required String medicamentoId,
    required String numeroLote,
    required DateTime fechaVencimiento,
    DateTime? fechaFabricacion,
    String? distribuidor,
    double? temperaturaRecepcion,
    String? observaciones,
    required int cantidadInicial,
  });

  /// Transfiere stock de un lote específico desde Almacén hacia Farmacia Central (RF-025)
  Future<void> transferirStockAFarmacia({
    required String loteId,
    required String medicamentoId,
    required int cantidad,
    String? motivo,
  });
}
