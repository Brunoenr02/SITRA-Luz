import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_prueba/features/inventario/domain/entities/producto.dart';
import 'package:flutter_prueba/features/inventario/domain/repositories/inventario_repository.dart';
import 'package:flutter_prueba/features/inventario/presentation/states/ui_state.dart';
import 'package:flutter_prueba/features/inventario/presentation/viewmodels/inventario_viewmodel.dart';

class RepositorioFalso implements InventarioRepository {
  final List<Producto>? respuesta;
  final Exception? error;

  RepositorioFalso({this.respuesta, this.error});

  @override
  Future<List<Producto>> obtenerProductos({String simulacion = 'exito'}) async {
    if (error != null) throw error!;
    return respuesta ?? [];
  }
}

void main() {
  test('emite Loading y luego Success cuando el repositorio responde', () async {
    final repo = RepositorioFalso(respuesta: [Producto(id: '1', nombre: 'Test', cantidad: 10)]);
    final vm = InventarioViewModel(repository: repo);

    expect(vm.estado, isA<UiStateLoading>());
    await vm.cargarProductos();
    expect(vm.estado, isA<UiStateSuccess<List<Producto>>>());
    expect((vm.estado as UiStateSuccess<List<Producto>>).data.length, 1);
  });

  test('emite Error con accion de reintento cuando el repositorio falla', () async {
    final repo = RepositorioFalso(error: Exception('Falla de red'));
    final vm = InventarioViewModel(repository: repo);

    await vm.cargarProductos();
    expect(vm.estado, isA<UiStateError>());
    expect((vm.estado as UiStateError).retry, isNotNull);
  });

  test('emite Empty cuando el repositorio responde sin elementos', () async {
    final repo = RepositorioFalso(respuesta: []);
    final vm = InventarioViewModel(repository: repo);

    await vm.cargarProductos();
    expect(vm.estado, isA<UiStateEmpty>());
  });
}
