import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/home/presentation/screens/dashboard_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Asegurar que los widgets de Flutter estén vinculados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive y abrir la caja de sesión
  await Hive.initFlutter();
  await Hive.openBox('auth');
  
  runApp(
    // ProviderScope es obligatorio para utilizar el estado reactivo con Riverpod
    const ProviderScope(
      child: NexusApp(),
    ),
  );
}

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si ya está autenticado, cargamos el Dashboard. Si no, cargamos el Login.
    final authRepo = ref.watch(authRepositoryProvider);
    final isAuthed = authRepo.isAuthenticated;

    return MaterialApp(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Cargar tema claro del diseño HSL
      home: isAuthed ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
