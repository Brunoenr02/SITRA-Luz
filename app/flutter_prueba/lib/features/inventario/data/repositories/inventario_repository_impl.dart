import '../../domain/entities/producto.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../models/producto_model.dart';

class InventarioRepositoryImpl implements InventarioRepository {
  @override
  Future<List<Producto>> obtenerProductos({String simulacion = 'exito'}) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular red

    if (simulacion == 'error') {
      throw Exception('Error de conexión al servidor.');
    }

    if (simulacion == 'vacio') {
      return [];
    }

    // Éxito simulado
    return [
      ProductoModel(id: '1', nombre: 'Paracetamol 500mg', cantidad: 50),
      ProductoModel(id: '2', nombre: 'Ibuprofeno 400mg', cantidad: 30),
      ProductoModel(id: '3', nombre: 'Amoxicilina 500mg', cantidad: 100),
    ];
  }
}
