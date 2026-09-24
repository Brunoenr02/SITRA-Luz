import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialización de Supabase (Base de Datos principal y Autenticación)
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.cleanUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      debugPrint(' Supabase inicializado exitosamente (BD & Auth activos).');
    } catch (e) {
      debugPrint(' Error al inicializar Supabase: $e');
    }
  } else {
    debugPrint(' Credenciales de Supabase pendientes en lib/core/config/supabase_config.dart');
  }

  // 2. Inicialización de Notificaciones Push (Firebase FCM diferido para fases posteriores)
  // Toda la persistencia, modelos relacionales y autenticación se gestionan 100% en Supabase.
  if (NotificationService.enablePushNotifications) {
    try {
      await Firebase.initializeApp();
      debugPrint(' Firebase inicializado exitosamente (exclusivo para notificaciones FCM).');
      await NotificationService.instance.initialize();
    } catch (e) {
      debugPrint('ℹ️ Firebase Notifications en pausa o sin archivo de servicios: $e');
    }
  } else {
    debugPrint('ℹ️ Notificaciones Push (Firebase FCM) en pausa temporal. Toda la BD y Auth operan en Supabase.');
  }

  // 3. Repositorio de Autenticación en Producción (100% Supabase)
  final AuthRepository authRepository = AuthRepositoryImpl(
    dataSource: AuthRemoteDataSource(),
  );

  final authViewModel = AuthViewModel(repository: authRepository);
  final router = createRouter(authViewModel);

  runApp(
    SitraLuzApp(
      authViewModel: authViewModel,
      router: router,
    ),
  );
}

/// Widget raíz de la aplicación SITRA-Luz
class SitraLuzApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final GoRouter router;

  const SitraLuzApp({
    super.key,
    required this.authViewModel,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: authViewModel,
      child: MaterialApp.router(
        title: 'SITRA-Luz • Clínica La Luz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: router,
      ),
    );
  }
}
