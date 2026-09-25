import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/medicamento_entity.dart';
import '../viewmodels/almacen_viewmodel.dart';

/// Pantalla para la edición técnica de un medicamento registrado en el catálogo (RF-016).
/// Permite actualizar nombre, principio activo, forma, concentración, GTIN, registro sanitario y cadena de frío.
class EditarMedicamentoView extends StatefulWidget {
  final MedicamentoEntity medicamento;

  const EditarMedicamentoView({super.key, required this.medicamento});

  @override
  State<EditarMedicamentoView> createState() => _EditarMedicamentoViewState();
}

class _EditarMedicamentoViewState extends State<EditarMedicamentoView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _gtinController;
  late final TextEditingController _nombreController;
  late final TextEditingController _principioActivoController;
  late final TextEditingController _concentracionController;
  late final TextEditingController _registroSanitarioController;
  late final TextEditingController _unidadPresentacionController;
  late final TextEditingController _cantidadPorPresentacionController;
  late final TextEditingController _tempMinController;
  late final TextEditingController _tempMaxController;

  late String _formaFarmaceutica;
  late bool _requiereCadenaFrio;
  late bool _activo;

  final List<String> _formasDisponibles = [
    'Tableta',
    'Cápsula',
    'Ampolla',
    'Frasco Ampolla',
    'Frasco / Solución',
    'Jarabe',
    'Ungüento',
    'Inhalador',
    'Solución Inyectable',
    'Suspensión Oral',
  ];

  @override
  void initState() {
    super.initState();
    final med = widget.medicamento;

    _gtinController = TextEditingController(text: med.gtin);
    _nombreController = TextEditingController(text: med.nombreComercial);
    _principioActivoController = TextEditingController(text: med.principioActivo);
    _concentracionController = TextEditingController(text: med.concentracion);
    _registroSanitarioController = TextEditingController(text: med.registroSanitario ?? '');
    _unidadPresentacionController = TextEditingController(text: med.unidadPresentacion);
    _cantidadPorPresentacionController = TextEditingController(text: med.cantidadPorPresentacion.toString());
    _tempMinController = TextEditingController(text: med.temperaturaMin.toString());
    _tempMaxController = TextEditingController(text: med.temperaturaMax.toString());

    if (_formasDisponibles.contains(med.formaFarmaceutica)) {
      _formaFarmaceutica = med.formaFarmaceutica;
    } else {
      _formaFarmaceutica = _formasDisponibles.first;
    }

    _requiereCadenaFrio = med.requiereCadenaFrio;
    _activo = med.activo;
  }

  @override
  void dispose() {
    _gtinController.dispose();
    _nombreController.dispose();
    _principioActivoController.dispose();
    _concentracionController.dispose();
    _registroSanitarioController.dispose();
    _unidadPresentacionController.dispose();
    _cantidadPorPresentacionController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final vm = context.read<AlmacenViewModel>();

    final tempMin = double.tryParse(_tempMinController.text.trim()) ?? 2.0;
    final tempMax = double.tryParse(_tempMaxController.text.trim()) ?? 8.0;
    final cantidadPresentacion = int.tryParse(_cantidadPorPresentacionController.text.trim()) ?? 1;

    final exito = await vm.editarMedicamento(
      id: widget.medicamento.id,
      gtin: _gtinController.text.trim(),
      nombreComercial: _nombreController.text.trim(),
      principioActivo: _principioActivoController.text.trim(),
      formaFarmaceutica: _formaFarmaceutica,
      concentracion: _concentracionController.text.trim(),
      registroSanitario: _registroSanitarioController.text.trim().isNotEmpty
          ? _registroSanitarioController.text.trim()
          : null,
      unidadPresentacion: _unidadPresentacionController.text.trim().isNotEmpty
          ? _unidadPresentacionController.text.trim()
          : 'unidad',
      cantidadPorPresentacion: cantidadPresentacion,
      requiereCadenaFrio: _requiereCadenaFrio,
      temperaturaMin: tempMin,
      temperaturaMax: tempMax,
      activo: _activo,
    );

    if (exito) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ Medicamento "${_nombreController.text.trim()}" actualizado correctamente.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      nav.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al actualizar: ${vm.errorMessage ?? "Ocurrió un error inesperado."}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final isSaving = vm.isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editar Medicamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Ficha técnica y trazabilidad clínica (RF-016)', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.almacenColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.almacenColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving ? null : _guardarCambios,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    isSaving ? 'Guardando...' : 'Guardar Cambios',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER INFORMATIVO DEL ARTÍCULO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.almacenColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.almacenColor.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.almacenColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppColors.almacenColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.medicamento.nombreComercial,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GTIN: ${widget.medicamento.gtin} • ID: ${widget.medicamento.id.length > 8 ? widget.medicamento.id.substring(0, 8) : widget.medicamento.id}...',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECCIÓN 1: DATOS CLÍNICOS Y DENOMINACIÓN
              const Text(
                'Datos Clínicos y Denominación',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Comercial *',
                        prefixIcon: Icon(Icons.medication_rounded),
                        hintText: 'Ej: Meropenem 1g',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El nombre comercial es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _principioActivoController,
                      decoration: const InputDecoration(
                        labelText: 'Principio Activo (DCI) *',
                        prefixIcon: Icon(Icons.science_rounded),
                        hintText: 'Ej: Meropenem Trihidrato',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El principio activo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: _concentracionController,
                            decoration: const InputDecoration(
                              labelText: 'Concentración *',
                              hintText: 'Ej: 1 g',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 6,
                          child: DropdownButtonFormField<String>(
                            value: _formaFarmaceutica,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Forma Farmacéutica',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            items: _formasDisponibles.map((forma) {
                              return DropdownMenuItem(
                                value: forma,
                                child: Text(
                                  forma,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _formaFarmaceutica = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECCIÓN 2: CODIFICACIÓN Y REGISTRO SANITARIO
              const Text(
                'Codificación y Registro Sanitario (DIGEMID)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _gtinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Código GTIN / Barras (GS1) *',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                        hintText: 'Código de 13 o 14 dígitos',
                        helperText: 'Identificador único global del medicamento',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El código GTIN es obligatorio';
                        }
                        if (v.trim().length < 8) {
                          return 'Debe tener al menos 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _registroSanitarioController,
                      decoration: const InputDecoration(
                        labelText: 'Registro Sanitario DIGEMID',
                        prefixIcon: Icon(Icons.verified_user_rounded),
                        hintText: 'Ej: EE-04581',
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _unidadPresentacionController,
                            decoration: const InputDecoration(
                              labelText: 'Presentación',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                              hintText: 'Ej: Frasco, Caja, Ampolla',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cantidadPorPresentacionController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Unidades x Empaque',
                              prefixIcon: Icon(Icons.pin_outlined),
                            ),
                            validator: (v) {
                              final parsed = int.tryParse(v ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Mínimo 1';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECCIÓN 3: CONTROL TÉRMICO Y CADENA DE FRÍO (RF-014)
              const Text(
                'Control Térmico y Cadena de Frío',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _requiereCadenaFrio ? Colors.cyan.shade300 : AppColors.surfaceVariant,
                    width: _requiereCadenaFrio ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _requiereCadenaFrio
                              ? Colors.cyan.withOpacity(0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.ac_unit_rounded,
                          color: _requiereCadenaFrio ? Colors.cyan.shade800 : AppColors.textSecondary,
                        ),
                      ),
                      title: const Text('Requiere Cadena de Frío', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        _requiereCadenaFrio
                            ? 'Monitoreo térmico estricto en Almacén y Farmacia'
                            : 'Almacenamiento a temperatura ambiente controlada (15-25 °C)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: _requiereCadenaFrio,
                      activeColor: Colors.cyan.shade800,
                      onChanged: (val) {
                        setState(() {
                          _requiereCadenaFrio = val;
                          if (val) {
                            _tempMinController.text = '2.0';
                            _tempMaxController.text = '8.0';
                          }
                        });
                      },
                    ),

                    if (_requiereCadenaFrio) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tempMinController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: 'Temp Mínima (°C)',
                                prefixIcon: Icon(Icons.thermostat_rounded, color: Colors.blue),
                              ),
                              validator: (v) {
                                if (!_requiereCadenaFrio) return null;
                                if (double.tryParse(v ?? '') == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tempMaxController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: 'Temp Máxima (°C)',
                                prefixIcon: Icon(Icons.thermostat_rounded, color: Colors.redAccent),
                              ),
                              validator: (v) {
                                if (!_requiereCadenaFrio) return null;
                                final maxVal = double.tryParse(v ?? '');
                                final minVal = double.tryParse(_tempMinController.text);
                                if (maxVal == null) return 'Valor inválido';
                                if (minVal != null && maxVal <= minVal) {
                                  return 'Debe ser > Mín';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.ac_unit_rounded, size: 14, color: Colors.cyan),
                            label: const Text('Refrigeración 2 a 8 °C', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              setState(() {
                                _tempMinController.text = '2.0';
                                _tempMaxController.text = '8.0';
                              });
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.severe_cold_rounded, size: 14, color: Colors.blue),
                            label: const Text('Congelado -20 °C', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              setState(() {
                                _tempMinController.text = '-25.0';
                                _tempMaxController.text = '-15.0';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECCIÓN 4: ESTADO EN CATÁLOGO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    _activo ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                    color: _activo ? AppColors.success : AppColors.error,
                  ),
                  title: const Text('Medicamento Activo', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    _activo
                        ? 'Disponible para pedidos y recepción de lotes'
                        : 'Descontinuado / Bloqueado para nuevas solicitudes',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _activo,
                  activeColor: AppColors.success,
                  onChanged: (val) {
                    setState(() => _activo = val);
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
