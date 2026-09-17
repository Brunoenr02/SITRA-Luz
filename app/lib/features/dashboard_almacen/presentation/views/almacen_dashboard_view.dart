import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/sitra_app_bar.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class AlmacenDashboardView extends StatelessWidget {
  const AlmacenDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SitraAppBar(
        title: 'Almacén General',
        subtitle: 'Recepción, Lotes y Cadena de Frío',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Almacén
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.inventory_2_rounded,
                                color: Colors.white, size: 16),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.ac_unit_rounded,
                                color: Colors.cyanAccent, size: 14),
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

            // Métricas de Almacén
            const Text(
              'Estado del Almacén General',
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
                  child: _buildMetricCard(
                    title: 'Guías Pendientes',
                    value: '2',
                    subtitle: 'Por recepcionar',
                    icon: Icons.local_shipping_rounded,
                    color: AppColors.almacenColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Transferencias',
                    value: '3',
                    subtitle: 'Hacia Farmacia',
                    icon: Icons.outbox_rounded,
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
                    title: 'Stock Crítico',
                    value: '4',
                    subtitle: 'Bajo punto de reorden',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Lotes Ingresados',
                    value: '18',
                    subtitle: 'Esta semana',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Módulos operativos
            const Text(
              'Operaciones de Almacén',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildModuleTile(
              icon: Icons.post_add_rounded,
              title: 'Ingreso de Guías de Remisión',
              subtitle: 'Registrar nuevo ingreso, número de lote, fecha caducidad y fabricante.',
              color: AppColors.almacenColor,
              onTap: () => _showActionSnackbar(context, 'Ingreso de Guía de Remisión'),
            ),
            const SizedBox(height: 10),
            _buildModuleTile(
              icon: Icons.transform_rounded,
              title: 'Transferencia Interna a Farmacia Central',
              subtitle: 'Generar orden de traslado de stock para abastecer ventanillas.',
              color: AppColors.primary,
              onTap: () => _showActionSnackbar(context, 'Transferencia Interna'),
            ),
            const SizedBox(height: 10),
            _buildModuleTile(
              icon: Icons.ac_unit_rounded,
              title: 'Control de Cadena de Frío',
              subtitle: 'Registro de temperatura de conservadoras (Insulinas, vacunas, sueros).',
              color: Colors.teal,
              onTap: () => _showActionSnackbar(context, 'Registro de Temperatura'),
            ),
            const SizedBox(height: 10),
            _buildModuleTile(
              icon: Icons.sync_rounded,
              title: 'Sincronización con Sistema Dialyma',
              subtitle: 'Conciliar stocks teóricos con el ERP general de la clínica.',
              color: AppColors.adminColor,
              onTap: () => _showActionSnackbar(context, 'Sincronización Dialyma'),
            ),

            const SizedBox(height: 24),

            // Guías de remisión recientes
            const Text(
              'Guías en Proceso de Recepción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildShipmentItem(
              guideNumber: 'GR-001-99238',
              supplier: 'Droguería Suiza Peruana S.A.',
              items: 'Cefradina 1g (x200), Tramadol 50mg (x150)',
              status: 'En Verificación Física',
              statusColor: AppColors.warning,
            ),
            _buildShipmentItem(
              guideNumber: 'GR-002-44102',
              supplier: 'Laboratorios Medifarma',
              items: 'Suero Fisiológico 9‰ 1000ml (x500 bolsas)',
              status: 'Aprobado para Almacén',
              statusColor: AppColors.success,
            ),
          ],
        ),
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

  Widget _buildModuleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentItem({
    required String guideNumber,
    required String supplier,
    required String items,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                guideNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.almacenColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            supplier,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            items,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSnackbar(BuildContext context, String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accediendo a $module'),
        backgroundColor: AppColors.almacenColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
