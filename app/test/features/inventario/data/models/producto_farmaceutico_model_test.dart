import 'package:flutter_test/flutter_test.dart';
import 'package:sitra_luz/features/inventario/data/models/producto_farmaceutico_model.dart';

void main() {
  group('ProductoFarmaceuticoModel.fromJson', () {
    test('conserva exactamente un identificador numérico grande', () {
      final model = ProductoFarmaceuticoModel.fromJson({
        'id': 9007199254740993,
        'nombre': 'Paracetamol 500 mg',
        'precio_centimos': '1250',
      });

      expect(model.id, '9007199254740993');
      expect(model.id, isA<String>());
    });

    test('convierte un precio textual a céntimos sin usar double', () {
      final model = ProductoFarmaceuticoModel.fromJson({
        'id': 'MED-0001',
        'nombre': 'Paracetamol 500 mg',
        'precio': '12345678901234567890.07',
      });

      expect(model.precioCentimos, '1234567890123456789007');
      expect(model.precioCentimos, isA<String>());
    });

    test('acepta céntimos numéricos y los almacena como texto', () {
      final model = ProductoFarmaceuticoModel.fromJson({
        'id': 25,
        'nombre': 'Ibuprofeno 400 mg',
        'precio_centimos': 1990,
      });

      expect(model.id, '25');
      expect(model.precioCentimos, '1990');
    });

    test('rechaza un precio con más de dos decimales', () {
      expect(
        () => ProductoFarmaceuticoModel.fromJson({
          'id': 'MED-0002',
          'nombre': 'Producto inválido',
          'precio': '10.999',
        }),
        throwsFormatException,
      );
    });

    test('asigna valores seguros cuando campos opcionales llegan null', () {
      final model = ProductoFarmaceuticoModel.fromJson({
        'id': 'MED-0003',
        'precio_centimos': '850',
        'nombre': null,
        'descripcion': null,
        'laboratorio': null,
        'requiere_receta': null,
        'etiquetas': null,
      });

      expect(model.nombre, '');
      expect(model.descripcion, '');
      expect(model.laboratorio, '');
      expect(model.requiereReceta, isFalse);
      expect(model.etiquetas, isEmpty);
    });

    test('asigna valores seguros cuando campos opcionales se omiten', () {
      final model = ProductoFarmaceuticoModel.fromJson({
        'id': 'MED-0004',
        'precio': '7.50',
      });

      expect(model.nombre, '');
      expect(model.descripcion, '');
      expect(model.laboratorio, '');
      expect(model.requiereReceta, isFalse);
      expect(model.etiquetas, isEmpty);
    });

    test('ignora silenciosamente claves adicionales no mapeadas', () {
      final model = ProductoFarmaceuticoModel.fromJson({
        'id': 'MED-0005',
        'nombre': 'Amoxicilina 500 mg',
        'precio_centimos': '2100',
        'campo_nuevo_del_backend': 'no definido en el modelo',
        'auditoria': {'origen': 'API externa'},
        'valor_desconocido': 999,
      });

      expect(model.id, 'MED-0005');
      expect(model.nombre, 'Amoxicilina 500 mg');
      expect(model.precioCentimos, '2100');
    });
  });
}
