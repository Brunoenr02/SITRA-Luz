import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/medicamento_entity.dart';
import '../../viewmodels/almacen_viewmodel.dart';

/// Diálogo para registrar un nuevo ingreso de lote para un medicamento ya catalogado
class IngresoLoteDialog extends StatefulWidget {
  final List<MedicamentoEntity> catalogo;
  final MedicamentoEntity? medicamentoPreseleccionado;

  const IngresoLoteDialog({
    super.key,
    required this.catalogo,
    this.medicamentoPreseleccionado,
  });

  @override
  State<IngresoLoteDialog> createState() => _IngresoLoteDialogState();
}

class _IngresoLoteDialogState extends State<IngresoLoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedMedicamentoId;
  final _loteController = TextEditingController();
  final _distribuidorController = TextEditingController();
  final _cantidadController = TextEditingController(text: '50');
  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    _selectedMedicamentoId = widget.medicamentoPreseleccionado?.id ??
        (widget.catalogo.isNotEmpty ? widget.catalogo.first.id : null);
  }

  @override
  void dispose() {
    _loteController.dispose();
    _distribuidorController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365 * 10)),
    );

    if (seleccionada != null) {
      setState(() => _fechaVencimiento = seleccionada);
    }
  }

  Future<void> _guardarLote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMedicamentoId == null) return;

    final viewModel = context.read<AlmacenViewModel>();
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;

    final exito = await viewModel.registrarLoteParaMedicamentoExistente(
      medicamentoId: _selectedMedicamentoId!,
      numeroLote: _loteController.text.trim(),
      fechaVencimiento: _fechaVencimiento,
      distribuidor: _distribuidorController.text.trim(),
      cantidadInicial: cantidad,
    );

    if (!mounted) return;

    if (exito) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Lote y stock ingresados correctamente a Almacén'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${viewModel.errorMessage ?? "No se pudo registrar"}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<AlmacenViewModel>().isSaving;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_box_rounded, color: AppColors.almacenColor),
          SizedBox(width: 8),
          Text('Nuevo Lote de Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de medicamento
              DropdownButtonFormField<String>(
                value: _selectedMedicamentoId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Medicamento',
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
                items: widget.catalogo
                    .map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text('${m.nombreComercial} (${m.concentracion})', overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMedicamentoId = val),
                validator: (val) => val == null ? 'Selecciona un medicamento' : null,
              ),
              const SizedBox(height: 12),

              // Número de lote
              TextFormField(
                controller: _loteController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Número de Lote *',
                  hintText: 'Ej: L2026-X09',
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // Distribuidor
              TextFormField(
                controller: _distribuidorController,
                decoration: const InputDecoration(
                  labelText: 'Proveedor / Laboratorio',
                  hintText: 'Ej: Distribuidora Médica',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Cantidad
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Recibida *',
                  prefixIcon: Icon(Icons.inventory_2_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Selector fecha de vencimiento
              InkWell(
                onTap: _seleccionarFechaVencimiento,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Caducidad (FEFO):', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            '${_fechaVencimiento.day.toString().padLeft(2, '0')}/${_fechaVencimiento.month.toString().padLeft(2, '0')}/${_fechaVencimiento.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.almacenColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.almacenColor),
          onPressed: isSaving ? null : _guardarLote,
          child: isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Ingresar Stock'),
        ),
      ],
    );
  }
}
