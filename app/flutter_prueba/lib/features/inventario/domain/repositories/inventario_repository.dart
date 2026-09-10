import '../entities/producto.dart';

abstract class InventarioRepository {
  Future<List<Producto>> obtenerProductos({String simulacion = 'exito'});
}
