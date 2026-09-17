import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // Intenta inicializar Firebase si ya se agregaron los archivos de configuración
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint(' Firebase inicializado exitosamente.');
  } on FirebaseException catch (e) {
    debugPrint(' FirebaseException al inicializar: ${e.code} — ${e.message}');
    debugPrint('ℹ SITRA-Luz activo en Modo Simulación Local (MockAuthRepository).');
  } catch (e, stackTrace) {
    // Captura cualquier otro error (MissingPluginException, PlatformException, etc.)
    debugPrint(' Error inesperado al inicializar Firebase: $e');
    debugPrint('StackTrace: $stackTrace');
    debugPrint('ℹ️ SITRA-Luz activo en Modo Simulación Local (MockAuthRepository).');
  }

  // Si Firebase está activo usa AuthRepositoryImpl; de lo contrario usa MockAuthRepository con los 5 roles
  final AuthRepository authRepository = firebaseInitialized
      ? AuthRepositoryImpl(dataSource: AuthRemoteDataSource())
      : MockAuthRepository();

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
