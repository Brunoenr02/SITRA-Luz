import '../../domain/entities/producto_farmaceutico_entity.dart';

sealed class ProductoCargaState {
  const ProductoCargaState();
}

class ProductoCargaInitial extends ProductoCargaState {
  const ProductoCargaInitial();
}

class ProductoCargaLoading extends ProductoCargaState {
  const ProductoCargaLoading();
}

class ProductoCargaSuccess extends ProductoCargaState {
  final ProductoFarmaceuticoEntity producto;

  const ProductoCargaSuccess(this.producto);
}

class ProductoCargaError extends ProductoCargaState {
  final String mensaje;

  const ProductoCargaError(this.mensaje);
}
