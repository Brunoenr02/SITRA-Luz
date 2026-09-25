import 'package:flutter/foundation.dart';
import '../../domain/repositories/almacen_repository.dart';
import '../states/almacen_state.dart';

/// ViewModel que gestiona la lógica de presentación del Almacén General
class AlmacenViewModel extends ChangeNotifier {
  final AlmacenRepository _repository;

  AlmacenState _state = const AlmacenInitial();
  AlmacenState get state => _state;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AlmacenViewModel({required AlmacenRepository repository})
      : _repository = repository;

  /// Carga el inventario y el catálogo de medicamentos desde Supabase
  Future<void> cargarInventario() async {
    _state = const AlmacenLoading();
    notifyListeners();

    try {
      final inventario = await _repository.getInventarioAlmacen();
      final catalogo = await _repository.getMedicamentos();
      final solicitudes = await _repository.getSolicitudesAbastecimiento();

      _state = AlmacenLoaded(
        inventario: inventario,
        catalogo: catalogo,
        solicitudes: solicitudes,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AlmacenError('No se pudo cargar el inventario: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Registra un nuevo medicamento maestro y su lote inicial en Almacén
  Future<bool> registrarMedicamentoYPrimerLote({
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
    required String numeroLote,
    required DateTime fechaVencimiento,
    DateTime? fechaFabricacion,
    String? distribuidor,
    double? temperaturaRecepcion,
    String? observaciones,
    required int cantidadInicial,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Crear el medicamento maestro
      final nuevoMed = await _repository.registrarMedicamento(
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

      // 2. Crear el lote inicial con el stock en Almacén
      await _repository.registrarIngresoLote(
        medicamentoId: nuevoMed.id,
        numeroLote: numeroLote,
        fechaVencimiento: fechaVencimiento,
        fechaFabricacion: fechaFabricacion,
        distribuidor: distribuidor,
        temperaturaRecepcion: temperaturaRecepcion,
        observaciones: observaciones,
        cantidadInicial: cantidadInicial,
      );

      // 3. Recargar el inventario
      await cargarInventario();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo ingreso de lote para un medicamento que ya existe en el catálogo
  Future<bool> registrarLoteParaMedicamentoExistente({
    required String medicamentoId,
    required String numeroLote,
    required DateTime fechaVencimiento,
    DateTime? fechaFabricacion,
    String? distribuidor,
    double? temperaturaRecepcion,
    String? observaciones,
    required int cantidadInicial,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.registrarIngresoLote(
        medicamentoId: medicamentoId,
        numeroLote: numeroLote,
        fechaVencimiento: fechaVencimiento,
        fechaFabricacion: fechaFabricacion,
        distribuidor: distribuidor,
        temperaturaRecepcion: temperaturaRecepcion,
        observaciones: observaciones,
        cantidadInicial: cantidadInicial,
      );

      await cargarInventario();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Transfiere stock físico de un lote desde Almacén hacia Farmacia Central (RF-025)
  Future<bool> transferirStockAFarmacia({
    required String loteId,
    required String medicamentoId,
    required int cantidad,
    String? motivo,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.transferirStockAFarmacia(
        loteId: loteId,
        medicamentoId: medicamentoId,
        cantidad: cantidad,
        motivo: motivo,
      );

      await cargarInventario();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Marca una solicitud de abastecimiento como despachada / atendida (RF-031)
  Future<bool> atenderSolicitudAbastecimiento({
    required String pedidoId,
    String? notasDespacho,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.atenderSolicitudAbastecimiento(
        pedidoId: pedidoId,
        notasDespacho: notasDespacho,
      );

      await cargarInventario();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
