import '../entities/medicamento_entity.dart';
import '../entities/lote_entity.dart';
import '../entities/pedido_abastecimiento_entity.dart';
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

  /// Actualiza los datos técnicos de un medicamento existente en el catálogo (RF-016)
  Future<MedicamentoEntity> editarMedicamento({
    required String id,
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
    bool activo = true,
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

  /// Obtiene la lista de solicitudes de abastecimiento enviadas por Farmacia (RF-031)
  Future<List<PedidoAbastecimientoEntity>> getSolicitudesAbastecimiento();

  /// Marca una solicitud de abastecimiento como atendida/despachada (RF-031)
  Future<void> atenderSolicitudAbastecimiento({
    required String pedidoId,
    String? notasDespacho,
  });
}
