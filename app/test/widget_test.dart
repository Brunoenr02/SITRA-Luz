import 'package:flutter_test/flutter_test.dart';
import 'package:sitra_luz/core/routes/app_router.dart';
import 'package:sitra_luz/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:sitra_luz/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:sitra_luz/main.dart';

void main() {
  testWidgets('SITRA-Luz app renders login screen correctly', (WidgetTester tester) async {
    final mockRepository = MockAuthRepository();
    final authViewModel = AuthViewModel(repository: mockRepository);
    final router = createRouter(authViewModel);

    await tester.pumpWidget(
      SitraLuzApp(
        authViewModel: authViewModel,
        router: router,
      ),
    );
    await tester.pumpAndSettle();

    // Verifica que el logo y título principal aparezcan
    expect(find.text('SITRA-LUZ'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
  });
}
