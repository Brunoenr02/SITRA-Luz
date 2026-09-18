import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

/// Tarjeta visual que muestra los datos del producto/usuario autenticado
/// Requisito Examen Práctico Tipo 3 - Ítem 1 (Muestra de dato de producto post-login)
class ProductUserDataCard extends StatelessWidget {
  const ProductUserDataCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    if (user == null) return const SizedBox.shrink();

    final areasText = user.areasAsignadas.isNotEmpty
        ? user.areasAsignadas.join(', ')
        : 'Todas las áreas clínicas';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'DATOS DEL PRODUCTO / ENTIDAD CARGADA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildInfoRow('Usuario:', user.nombre, Icons.person_outline_rounded),
          const SizedBox(height: 6),
          _buildInfoRow('Correo:', user.email, Icons.email_outlined),
          const SizedBox(height: 6),
          _buildInfoRow('Rol del Sistema:', user.rol.displayName, Icons.verified_user_outlined),
          const SizedBox(height: 6),
          _buildInfoRow('Áreas Asignadas:', areasText, Icons.local_hospital_outlined),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
