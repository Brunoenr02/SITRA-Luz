import 'package:flutter/foundation.dart';

import '../../domain/repositories/producto_farmaceutico_repository.dart';
import '../states/producto_carga_state.dart';

class ProductoCargaViewModel extends ChangeNotifier {
  final ProductoFarmaceuticoRepository _repository;

  ProductoCargaState _state = const ProductoCargaInitial();
  ProductoCargaState get state => _state;

  ProductoCargaViewModel({
    required ProductoFarmaceuticoRepository repository,
  }) : _repository = repository;

  /// Realiza un único intento. Un error queda como estado final y no genera
  /// reintentos automáticos ni llamadas recursivas al repositorio.
  Future<void> cargarProducto() async {
    _setState(const ProductoCargaLoading());

    try {
      final producto = await _repository.obtenerProducto();
      _setState(ProductoCargaSuccess(producto));
    } on FormatException catch (error) {
      _setState(ProductoCargaError(error.message));
    } catch (_) {
      _setState(
        const ProductoCargaError('No se pudo cargar el producto farmacéutico.'),
      );
    }
  }

  void _setState(ProductoCargaState newState) {
    _state = newState;
    notifyListeners();
  }
}
