import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/sitra_app_bar.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class FarmaciaDashboardView extends StatelessWidget {
  const FarmaciaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SitraAppBar(
        title: 'Farmacia Clínica',
        subtitle: 'Dispensación y Control de Piso',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Farmacia
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.farmaciaColor, Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.farmaciaColor.withOpacity(0.25),
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
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_pharmacy_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'VENTANILLA & DISPENSACIÓN',
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
                          color: Colors.amberAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '7 Pendientes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Bienvenido, ${user?.nombre ?? "Químico Farmacéutico"}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atención de recetas hospitalarias y reposición a servicios de hospitalización.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Métricas de atención
            const Text(
              'Cola de Trabajo de Farmacia',
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
                    title: 'Recetas Pendientes',
                    value: '7',
                    subtitle: 'Pacientes en espera',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.farmaciaColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pedidos de Piso',
                    value: '4',
                    subtitle: 'UCI / Emergencia',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Dispensadas Hoy',
                    value: '46',
                    subtitle: 'Recetas completadas',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Transferencias',
                    value: '2',
                    subtitle: 'En camino desde Almacén',
                    icon: Icons.move_to_inbox_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Acciones directas
            const Text(
              'Operaciones Farmacéuticas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildModuleTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Dispensar Receta Médica',
              subtitle: 'Validar prescripción médica, escanear lote FEFO y registrar entrega.',
              color: AppColors.farmaciaColor,
              onTap: () => _showActionSnackbar(context, 'Dispensación con Escáner'),
            ),
            const SizedBox(height: 10),
            _buildModuleTile(
              icon: Icons.inventory_rounded,
              title: 'Atender Pedidos de Reposición (Pisos)',
              subtitle: 'Preparar coches de paro y botiquines para enfermería.',
              color: AppColors.warning,
              onTap: () => _showActionSnackbar(context, 'Atención a Botiquines'),
            ),
            const SizedBox(height: 10),
            _buildModuleTile(
              icon: Icons.search_rounded,
              title: 'Consulta de Stock y Lotes en Farmacia',
              subtitle: 'Buscar principios activos, presentaciones, saldos y vencimientos.',
              color: AppColors.primary,
              onTap: () => _showActionSnackbar(context, 'Kardex de Farmacia'),
            ),
            const SizedBox(height: 10),
            _buildModuleTile(
              icon: Icons.download_done_rounded,
              title: 'Recepción de Mercadería desde Almacén',
              subtitle: 'Confirmar llegada física de lotes y validar cantidades.',
              color: AppColors.secondary,
              onTap: () => _showActionSnackbar(context, 'Recepción desde Almacén'),
            ),

            const SizedBox(height: 24),

            // Cola de recetas en espera
            const Text(
              'Próximas Recetas por Atender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildPendingItem(
              code: 'REC-2026-089',
              patient: 'García Flores, Rosa • Cama 204 (Hosp)',
              meds: 'Omeprazol 40mg EV (x1), Paracetamol 1g (x2)',
              status: 'Urgente',
              statusColor: AppColors.error,
            ),
            _buildPendingItem(
              code: 'PED-UCI-014',
              patient: 'Servicio UCI Adultos • Botiquín Coche #2',
              meds: 'Fentanilo 0.5mg/10ml (x5), Midazolam 50mg (x3)',
              status: 'En preparación',
              statusColor: AppColors.warning,
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

  Widget _buildPendingItem({
    required String code,
    required String patient,
    required String meds,
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
                code,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
            patient,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            meds,
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
        backgroundColor: AppColors.farmaciaColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
