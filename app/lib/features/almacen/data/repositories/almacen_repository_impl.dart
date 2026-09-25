import '../../domain/entities/lote_entity.dart';
import '../../domain/entities/medicamento_entity.dart';
import '../../domain/entities/pedido_abastecimiento_entity.dart';
import '../../domain/entities/stock_almacen_entity.dart';
import '../../domain/repositories/almacen_repository.dart';
import '../datasources/almacen_remote_datasource.dart';
import '../models/medicamento_model.dart';

/// Implementación concreta del repositorio de Almacén
class AlmacenRepositoryImpl implements AlmacenRepository {
  final AlmacenRemoteDataSource _dataSource;

  AlmacenRepositoryImpl({AlmacenRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? AlmacenRemoteDataSource();

  @override
  Future<List<StockAlmacenEntity>> getInventarioAlmacen() async {
    return await _dataSource.getInventarioAlmacen();
  }

  @override
  Future<List<MedicamentoEntity>> getMedicamentos() async {
    return await _dataSource.getMedicamentos();
  }

  @override
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
  }) async {
    final model = MedicamentoModel(
      id: '', // Se autogenera en la BD
      gtin: gtin,
      nombreComercial: nombreComercial,
      principioActivo: principioActivo,
      formaFarmaceutica: formaFarmaceutica,
      concentracion: concentracion,
      registroSanitario: registroSanitario,
      unidadPresentacion: unidadPresentacion,
      cantidadPorPresentacion: cantidadPorPresentacion,
      requiereCadenaFrio: requiereCadenaFrio,
      temperaturaMin: temperaturaMin,
      temperaturaMax: temperaturaMax,
    );
    return await _dataSource.registrarMedicamento(model);
  }

  @override
  Future<LoteEntity> registrarIngresoLote({
    required String medicamentoId,
    required String numeroLote,
    required DateTime fechaVencimiento,
    DateTime? fechaFabricacion,
    String? distribuidor,
    double? temperaturaRecepcion,
    String? observaciones,
    required int cantidadInicial,
  }) async {
    return await _dataSource.registrarIngresoLote(
      medicamentoId: medicamentoId,
      numeroLote: numeroLote,
      fechaVencimiento: fechaVencimiento,
      fechaFabricacion: fechaFabricacion,
      distribuidor: distribuidor,
      temperaturaRecepcion: temperaturaRecepcion,
      observaciones: observaciones,
      cantidadInicial: cantidadInicial,
    );
  }

  @override
  Future<void> transferirStockAFarmacia({
    required String loteId,
    required String medicamentoId,
    required int cantidad,
    String? motivo,
  }) async {
    await _dataSource.transferirStockAFarmacia(
      loteId: loteId,
      medicamentoId: medicamentoId,
      cantidad: cantidad,
      motivo: motivo,
    );
  }

  @override
  Future<List<PedidoAbastecimientoEntity>> getSolicitudesAbastecimiento() async {
    return await _dataSource.getSolicitudesAbastecimiento();
  }

  @override
  Future<void> atenderSolicitudAbastecimiento({
    required String pedidoId,
    String? notasDespacho,
  }) async {
    await _dataSource.atenderSolicitudAbastecimiento(
      pedidoId: pedidoId,
      notasDespacho: notasDespacho,
    );
  }
}
