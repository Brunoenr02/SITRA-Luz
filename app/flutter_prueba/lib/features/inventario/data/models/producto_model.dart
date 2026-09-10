import '../../domain/entities/producto.dart';

class ProductoModel extends Producto {
  ProductoModel({required super.id, required super.nombre, required super.cantidad});

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
    );
  }
}
