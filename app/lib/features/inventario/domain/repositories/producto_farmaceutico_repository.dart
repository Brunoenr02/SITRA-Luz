import '../entities/producto_farmaceutico_entity.dart';

abstract class ProductoFarmaceuticoRepository {
  Future<ProductoFarmaceuticoEntity> obtenerProducto();
}
