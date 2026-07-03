import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/home/presentation/screens/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tenantController = TextEditingController(text: '001'); // Bodega El Sol
  final _usernameController = TextEditingController(text: 'alan');
  final _passwordController = TextEditingController(text: 'Admin123');

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final rawTenantId = _tenantController.text.trim();
    final resolvedTenantId = rawTenantId == '001' 
        ? 'a1a2a3a4-b1b2-c1c2-d1d2-000000000001' 
        : rawTenantId;

    final authRepo = ref.read(authRepositoryProvider);
    final success = await authRepo.login(
      tenantId: resolvedTenantId,
      usernameOrEmail: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Correo o contraseña incorrectos';
        });
      }
    }
  }

  @override
  void dispose() {
    _tenantController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _outlinedDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: false,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo 80x80dp
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título headlineMedium
                Text(
                  'Sistema Comercial',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Campos Outlined (16dp spacing)
                TextFormField(
                  controller: _tenantController,
                  decoration: _outlinedDecoration('Código de Comercio (Tenant ID)', Icons.business),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: _outlinedDecoration('correo@empresa.com', Icons.email_outlined),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: _outlinedDecoration('••••••••', Icons.lock_outline),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                
                // Mensaje de Error Inline
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                
                const SizedBox(height: 32),

                // Botón Filled Button 48dp
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                            ),
                            const SizedBox(width: 12),
                            const Text('Iniciando sesión...'),
                          ],
                        )
                      : const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 16),
                
                // Link text button
                TextButton(
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
