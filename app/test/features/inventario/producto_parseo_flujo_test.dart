import 'package:flutter_test/flutter_test.dart';
import 'package:sitra_luz/features/inventario/data/models/producto_farmaceutico_model.dart';
import 'package:sitra_luz/features/inventario/domain/entities/producto_farmaceutico_entity.dart';
import 'package:sitra_luz/features/inventario/domain/repositories/producto_farmaceutico_repository.dart';
import 'package:sitra_luz/features/inventario/presentation/states/producto_carga_state.dart';
import 'package:sitra_luz/features/inventario/presentation/viewmodels/producto_carga_viewmodel.dart';

void main() {
  const validPayload = <String, dynamic>{
    'id': 9007199254740993,
    'nombre': 'Paracetamol 500 mg',
    'descripcion': 'Tabletas para administración oral',
    'laboratorio': 'Clínica La Luz',
    'requiere_receta': false,
    'etiquetas': ['analgésico', 'tableta'],
    'precio': '12.50',
  };

  test('a) Carga de entidad: hidrata todos los atributos íntegros', () {
    final entity = ProductoFarmaceuticoModel.fromJson(validPayload).toEntity();

    expect(entity.id, '9007199254740993');
    expect(entity.nombre, 'Paracetamol 500 mg');
    expect(entity.descripcion, 'Tabletas para administración oral');
    expect(entity.laboratorio, 'Clínica La Luz');
    expect(entity.requiereReceta, isFalse);
    expect(entity.etiquetas, orderedEquals(['analgésico', 'tableta']));
    expect(entity.precioCentimos, '1250');
  });

  test('b) Estado exitoso: deja datos listos para renderizar', () async {
    final repository = _JsonProductoRepository(validPayload);
    final viewModel = ProductoCargaViewModel(repository: repository);

    await viewModel.cargarProducto();

    expect(viewModel.state, isA<ProductoCargaSuccess>());
    final success = viewModel.state as ProductoCargaSuccess;
    expect(success.producto.nombre, 'Paracetamol 500 mg');
    expect(success.producto.precioCentimos, '1250');
    expect(repository.numeroDeLlamadas, 1);
  });

  test('c) Carga fallida: finaliza en error sin reintentos', () async {
    final repository = _JsonProductoRepository({
      'nombre': 'Payload sin identificador',
      'precio': '10.999',
    });
    final viewModel = ProductoCargaViewModel(repository: repository);

    await viewModel.cargarProducto();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state, isA<ProductoCargaError>());
    final error = viewModel.state as ProductoCargaError;
    expect(error.mensaje, isNotEmpty);
    expect(repository.numeroDeLlamadas, 1);
  });
}

class _JsonProductoRepository implements ProductoFarmaceuticoRepository {
  final Map<String, dynamic> payload;
  int numeroDeLlamadas = 0;

  _JsonProductoRepository(this.payload);

  @override
  Future<ProductoFarmaceuticoEntity> obtenerProducto() async {
    numeroDeLlamadas++;
    return ProductoFarmaceuticoModel.fromJson(payload).toEntity();
  }
}
