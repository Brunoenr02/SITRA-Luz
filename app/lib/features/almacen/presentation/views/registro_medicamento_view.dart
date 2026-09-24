import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';

/// Formulario completo para registrar un nuevo medicamento y dar entrada a su primer lote en Almacén
class RegistroMedicamentoView extends StatefulWidget {
  const RegistroMedicamentoView({super.key});

  @override
  State<RegistroMedicamentoView> createState() => _RegistroMedicamentoViewState();
}

class _RegistroMedicamentoViewState extends State<RegistroMedicamentoView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de Medicamento
  final _gtinController = TextEditingController();
  final _nombreController = TextEditingController();
  final _principioActivoController = TextEditingController();
  final _concentracionController = TextEditingController();
  final _registroSanitarioController = TextEditingController();

  String _formaFarmaceutica = 'Tableta';
  bool _requiereCadenaFrio = false;
  final double _tempMin = 2.0;
  final double _tempMax = 8.0;

  // Controladores de Lote
  final _loteController = TextEditingController();
  final _distribuidorController = TextEditingController();
  final _cantidadController = TextEditingController(text: '50');
  final _tempRecepcionController = TextEditingController(text: '4.0');
  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 365));

  final List<String> _formasDisponibles = [
    'Tableta',
    'Cápsula',
    'Ampolla',
    'Frasco Ampolla',
    'Frasco / Solución',
    'Jarabe',
    'Ungüento',
    'Inhalador',
  ];

  @override
  void dispose() {
    _gtinController.dispose();
    _nombreController.dispose();
    _principioActivoController.dispose();
    _concentracionController.dispose();
    _registroSanitarioController.dispose();
    _loteController.dispose();
    _distribuidorController.dispose();
    _cantidadController.dispose();
    _tempRecepcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.almacenColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionada != null) {
      setState(() {
        _fechaVencimiento = seleccionada;
      });
    }
  }

  void _generarGtinDemo() {
    final rand = DateTime.now().millisecondsSinceEpoch.toString();
    _gtinController.text = '7750215${rand.substring(rand.length - 6)}';
  }

  Future<void> _guardarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AlmacenViewModel>();
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;
    final tempRecepcion = _requiereCadenaFrio
        ? double.tryParse(_tempRecepcionController.text.trim())
        : null;

    final exito = await viewModel.registrarMedicamentoYPrimerLote(
      gtin: _gtinController.text.trim(),
      nombreComercial: _nombreController.text.trim(),
      principioActivo: _principioActivoController.text.trim(),
      formaFarmaceutica: _formaFarmaceutica,
      concentracion: _concentracionController.text.trim(),
      registroSanitario: _registroSanitarioController.text.trim(),
      requiereCadenaFrio: _requiereCadenaFrio,
      temperaturaMin: _tempMin,
      temperaturaMax: _tempMax,
      numeroLote: _loteController.text.trim(),
      fechaVencimiento: _fechaVencimiento,
      distribuidor: _distribuidorController.text.trim(),
      temperaturaRecepcion: tempRecepcion,
      cantidadInicial: cantidad,
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Medicamento y lote inicial ingresados al Almacén exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${viewModel.errorMessage ?? "No se pudo guardar"}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<AlmacenViewModel>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ingreso de Medicamento'),
        backgroundColor: AppColors.almacenColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SECCIÓN: DATOS GENERALES DEL MEDICAMENTO
              _buildSectionHeader(
                icon: Icons.medication_rounded,
                title: '1. Ficha Técnica del Medicamento',
                subtitle: 'Datos maestros catalogados para la clínica',
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    // Código GTIN / Barras
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gtinController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Código GTIN / Código de Barras *',
                              hintText: 'Ej: 7750215001234',
                              prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Generar código de prueba',
                          onPressed: _generarGtinDemo,
                          icon: const Icon(Icons.auto_fix_high_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Nombre comercial
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Comercial *',
                        hintText: 'Ej: Amoxicilina 500mg, Meropenem 1g',
                        prefixIcon: Icon(Icons.label_outline_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa el nombre comercial' : null,
                    ),
                    const SizedBox(height: 14),

                    // Principio Activo
                    TextFormField(
                      controller: _principioActivoController,
                      decoration: const InputDecoration(
                        labelText: 'Principio Activo *',
                        hintText: 'Ej: Amoxicilina Trihidrato',
                        prefixIcon: Icon(Icons.science_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa el principio activo' : null,
                    ),
                    const SizedBox(height: 14),

                    // Concentración y Forma Farmacéutica
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _concentracionController,
                            decoration: const InputDecoration(
                              labelText: 'Concentración *',
                              hintText: 'Ej: 500 mg, 1 g / 10ml',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formaFarmaceutica,
                            decoration: const InputDecoration(
                              labelText: 'Forma Farmacéutica',
                            ),
                            items: _formasDisponibles
                                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _formaFarmaceutica = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Registro Sanitario
                    TextFormField(
                      controller: _registroSanitarioController,
                      decoration: const InputDecoration(
                        labelText: 'Registro Sanitario (DIGEMID)',
                        hintText: 'Ej: RS-EE-04812',
                        prefixIcon: Icon(Icons.verified_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Switch Cadena de Frío
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _requiereCadenaFrio
                            ? Colors.cyan.withOpacity(0.08)
                            : AppColors.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _requiereCadenaFrio ? Colors.cyan : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.ac_unit_rounded,
                            color: _requiereCadenaFrio ? Colors.cyan.shade700 : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requiere Cadena de Frío',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Rango estricto de 2.0 °C a 8.0 °C',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _requiereCadenaFrio,
                            activeColor: Colors.cyan.shade700,
                            onChanged: (v) => setState(() => _requiereCadenaFrio = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. SECCIÓN: DATOS DEL LOTE Y STOCK INICIAL
              _buildSectionHeader(
                icon: Icons.inventory_2_rounded,
                title: '2. Recepción Física de Lote y Stock',
                subtitle: 'Ingreso directo al inventario de Almacén General',
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    // Número de Lote y Distribuidor
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _loteController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Número de Lote *',
                              hintText: 'Ej: L2026-B04',
                              prefixIcon: Icon(Icons.numbers_rounded),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _distribuidorController,
                            decoration: const InputDecoration(
                              labelText: 'Distribuidor / Proveedor',
                              hintText: 'Ej: Medifarma',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Fecha de vencimiento (con selector y semáforo visual)
                    InkWell(
                      onTap: _seleccionarFechaVencimiento,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.almacenColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fecha de Caducidad (FEFO) *',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_fechaVencimiento.day.toString().padLeft(2, '0')}/${_fechaVencimiento.month.toString().padLeft(2, '0')}/${_fechaVencimiento.year}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Chip(
                              label: Text('Cambiar'),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Cantidad a ingresar y temperatura de recepción
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cantidadController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad Recibida *',
                              hintText: 'Ej: 100',
                              prefixIcon: Icon(Icons.add_shopping_cart_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requerido';
                              final n = int.tryParse(v);
                              if (n == null || n <= 0) return 'Mayor a 0';
                              return null;
                            },
                          ),
                        ),
                        if (_requiereCadenaFrio) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tempRecepcionController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Temp. Recepción (°C)',
                                hintText: 'Ej: 3.8',
                                prefixIcon: Icon(Icons.thermostat_rounded),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.almacenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isSaving ? null : _guardarRegistro,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    isSaving ? 'REGISTRANDO EN SUPABASE...' : 'REGISTRAR MEDICAMENTO Y STOCK',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.almacenColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.almacenColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
