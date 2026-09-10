import 'package:flutter/material.dart';
import '../viewmodels/inventario_viewmodel.dart';
import '../states/ui_state.dart';
import '../../data/repositories/inventario_repository_impl.dart';
import '../../domain/entities/producto.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  late InventarioViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = InventarioViewModel(repository: InventarioRepositoryImpl());
    _viewModel.cargarProductos();
    _viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario SITRA-Luz'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Botones para simular los estados (para facilitar las capturas)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _viewModel.cargarProductos(simulacion: 'exito'), child: const Text('Éxito')),
                ElevatedButton(onPressed: () => _viewModel.cargarProductos(simulacion: 'vacio'), child: const Text('Vacío')),
                ElevatedButton(onPressed: () => _viewModel.cargarProductos(simulacion: 'error'), child: const Text('Error')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final state = _viewModel.estado;

    if (state is UiStateLoading<List<Producto>>) {
      return const Center(child: CircularProgressIndicator());
    } 
    
    if (state is UiStateError<List<Producto>>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.retry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } 
    
    if (state is UiStateEmpty<List<Producto>>) {
      return const Center(
        child: Text('No hay productos en el inventario.', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    } 
    
    if (state is UiStateSuccess<List<Producto>>) {
      final productos = state.data;
      return ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final prod = productos[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.medication)),
            title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Cantidad en almacén: ${prod.cantidad}'),
          );
        },
      );
    }

    return const SizedBox();
  }
}
