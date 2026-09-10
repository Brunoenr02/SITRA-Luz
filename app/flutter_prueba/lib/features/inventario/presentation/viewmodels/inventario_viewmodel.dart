import 'package:flutter/material.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../states/ui_state.dart';
import '../../domain/entities/producto.dart';

class InventarioViewModel extends ChangeNotifier {
  final InventarioRepository repository;

  UiState<List<Producto>> estado = UiStateLoading();

  InventarioViewModel({required this.repository});

  Future<void> cargarProductos({String simulacion = 'exito'}) async {
    estado = UiStateLoading();
    notifyListeners();

    try {
      final productos = await repository.obtenerProductos(simulacion: simulacion);
      if (productos.isEmpty) {
        estado = UiStateEmpty();
      } else {
        estado = UiStateSuccess(productos);
      }
    } catch (e) {
      estado = UiStateError(
        message: e.toString(),
        retry: () => cargarProductos(simulacion: simulacion),
      );
    }
    notifyListeners();
  }
}
