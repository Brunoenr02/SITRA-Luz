import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/sitra_app_bar.dart';
import '../../../almacen/domain/entities/lote_entity.dart';
import '../../../almacen/domain/entities/stock_almacen_entity.dart';
import '../../../almacen/presentation/states/almacen_state.dart';
import '../../../almacen/presentation/viewmodels/almacen_viewmodel.dart';
import '../../../almacen/presentation/views/dialogs/ingreso_lote_dialog.dart';
import '../../../almacen/presentation/views/registro_medicamento_view.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class AlmacenDashboardView extends StatefulWidget {
  const AlmacenDashboardView({super.key});

  @override
  State<AlmacenDashboardView> createState() => _AlmacenDashboardViewState();
}

class _AlmacenDashboardViewState extends State<AlmacenDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlmacenViewModel>().cargarInventario();
    });
  }

  void _abrirRegistroMedicamento() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistroMedicamentoView()),
    );
  }

  void _abrirIngresoLote(AlmacenLoaded loaded) {
    showDialog(
      context: context,
      builder: (_) => IngresoLoteDialog(catalogo: loaded.catalogo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final almacenVM = context.watch<AlmacenViewModel>();
    final state = almacenVM.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SitraAppBar(
        title: 'Almacén General',
        subtitle: 'Recepción, Lotes y Cadena de Frío',
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.almacenColor,
        foregroundColor: Colors.white,
        onPressed: _abrirRegistroMedicamento,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar Medicamento', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: AppColors.almacenColor,
        onRefresh: () => almacenVM.cargarInventario(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BANNER DE BIENVENIDA Y ESTADO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.almacenColor, Color(0xFFBF360C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.almacenColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.inventory_2_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'LOGÍSTICA CLÍNICA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.ac_unit_rounded, color: Colors.cyanAccent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Frío: 3.8 °C',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Bienvenido, ${user?.nombre ?? "Responsable de Almacén"}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recepción de guías, ingreso de lotes al sistema y despacho hacia Farmacia Central.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. MÉTRICAS OPERATIVAS REALES DE ALMACÉN
              const Text(
                'Estado del Almacén General',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (state is AlmacenLoaded) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Unidades',
                        value: '${state.totalUnidades}',
                        subtitle: 'Físico en Almacén',
                        icon: Icons.inventory_rounded,
                        color: AppColors.almacenColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Lotes Registrados',
                        value: '${state.inventario.length}',
                        subtitle: 'Lotes únicos',
                        icon: Icons.numbers_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Alertas FEFO',
                        value: '${state.lotesCriticos}',
                        subtitle: 'Vence < 30 días',
                        icon: Icons.warning_amber_rounded,
                        color: state.lotesCriticos > 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Cadena de Frío',
                        value: '${state.articulosCadenaFrio}',
                        subtitle: '2.0 °C a 8.0 °C',
                        icon: Icons.ac_unit_rounded,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ] else if (state is AlmacenLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.almacenColor),
                  ),
                ),
              ] else ...[
                const Text('Sin datos disponibles'),
              ],

              const SizedBox(height: 24),

              // 3. ACCIONES RÁPIDAS
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.almacenColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.almacenColor, width: 1.5),
                        ),
                      ),
                      onPressed: _abrirRegistroMedicamento,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('Nuevo Artículo', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onPressed: state is AlmacenLoaded ? () => _abrirIngresoLote(state) : null,
                      icon: const Icon(Icons.playlist_add_rounded),
                      label: const Text('Ingresar Lote', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. LISTADO DE INVENTARIO FÍSICO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inventario en Almacén General',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (state is AlmacenLoaded)
                    Text(
                      '${state.inventario.length} ítems',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (state is AlmacenLoaded) ...[
                if (state.inventario.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 10),
                        const Text(
                          'No hay medicamentos en Almacén',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Registra tu primer artículo con el botón inferior.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.almacenColor),
                          onPressed: _abrirRegistroMedicamento,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Registrar Primer Medicamento'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.inventario.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = state.inventario[index];
                      return _buildStockItemCard(item);
                    },
                  ),
              ],
              const SizedBox(height: 60), // Margen para el FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockItemCard(StockAlmacenEntity item) {
    final med = item.medicamento;
    final lote = item.lote;

    Color fefoColor;
    switch (lote.estadoFefo) {
      case EstadoFefo.vencido:
      case EstadoFefo.critico:
        fefoColor = AppColors.error;
        break;
      case EstadoFefo.preventivo:
        fefoColor = AppColors.warning;
        break;
      case EstadoFefo.seguro:
        fefoColor = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila Superior: Nombre y Cantidad
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.nombreComercial,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${med.principioActivo} • ${med.concentracion}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.almacenColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${item.cantidad}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.almacenColor,
                      ),
                    ),
                    const Text(
                      'unid.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.almacenColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Fila Inferior: Chips informativos
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              // Chip Lote
              _buildBadge(
                icon: Icons.numbers_rounded,
                text: 'Lote: ${lote.numeroLote}',
                color: Colors.indigo,
              ),

              // Chip Caducidad / FEFO
              _buildBadge(
                icon: Icons.calendar_month_rounded,
                text: 'FEFO: ${lote.etiquetaFefo}',
                color: fefoColor,
              ),

              // Chip Cadena de Frío (si aplica)
              if (med.requiereCadenaFrio)
                _buildBadge(
                  icon: Icons.ac_unit_rounded,
                  text: 'Cadena de Frío (2-8 °C)',
                  color: Colors.cyan.shade800,
                ),

              // Chip GTIN
              _buildBadge(
                icon: Icons.qr_code_rounded,
                text: med.gtin,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
