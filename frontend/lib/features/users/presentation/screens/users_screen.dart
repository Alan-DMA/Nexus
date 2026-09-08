import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'Alan D.',
      'email': 'alan@nexus.pos',
      'role': 'Administrador',
      'is_active': true,
    },
    {
      'id': '2',
      'name': 'María Delgado',
      'email': 'maria.caja@nexus.pos',
      'role': 'Cajero',
      'is_active': true,
    },
    {
      'id': '3',
      'name': 'Pedro Ramírez',
      'email': 'pedro.deposito@nexus.pos',
      'role': 'Inventariado',
      'is_active': false,
    },
  ];

  void _openAddUserModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'Cajero';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.darkBorder),
          ),
          title: Text(
            'Crear Usuario / Operador',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico / Usuario',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                dropdownColor: AppTheme.darkSurface,
                decoration: const InputDecoration(labelText: 'Rol y Permisos'),
                items: const [
                  DropdownMenuItem(
                    value: 'Cajero',
                    child: Text(
                      'Cajero',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Inventariado',
                    child: Text(
                      'Inventariado',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Administrador',
                    child: Text(
                      'Administrador',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => role = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.darkTextSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _users.insert(0, {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'role': role,
                      'is_active': true,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Usuarios y Permisos (RBAC)',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: _users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final u = _users[index];
          final isActive = u['is_active'] == true;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.cyanAccent.withValues(alpha: 0.2),
                  child: Text(
                    u['name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['name'],
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${u['email']} • ${u['role']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  activeThumbColor: AppTheme.cyanAccent,
                  onChanged: (val) => setState(() => u['is_active'] = val),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Nuevo Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _openAddUserModal,
      ),
    );
  }
}
