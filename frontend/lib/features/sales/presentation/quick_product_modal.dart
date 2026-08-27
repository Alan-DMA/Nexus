import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/sales/data/sales_client.dart';

class QuickProductModal extends ConsumerStatefulWidget {
  final String initialBarcode;

  const QuickProductModal({super.key, this.initialBarcode = ''});

  @override
  ConsumerState<QuickProductModal> createState() => _QuickProductModalState();
}

class _QuickProductModalState extends ConsumerState<QuickProductModal> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  final _costController = TextEditingController(text: '0.00');
  final _priceController = TextEditingController(text: '0.00');
  final _stockController = TextEditingController(text: '0');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _barcodeController = TextEditingController(text: widget.initialBarcode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(salesRepositoryProvider);
      final product = await repository.quickCreateProduct(
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim(),
        costUsd: double.parse(_costController.text),
        priceUsd: double.parse(_priceController.text),
        stockInicial: double.parse(_stockController.text),
      );

      if (mounted) {
        Navigator.of(context).pop(product); // Retorna el producto recién creado
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar el producto: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Producto al Vuelo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Registra rápidamente un producto en el inventario sin salir del checkout comercial.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Nombre
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
                    prefixIcon: Icon(
                      Icons.shopping_bag_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Nombre obligatorio'
                      : null,
                ),
                const SizedBox(height: 16),
                // Código de barras
                TextFormField(
                  controller: _barcodeController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Código de Barras',
                    prefixIcon: Icon(
                      Icons.qr_code_scanner_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Código de barras obligatorio'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Costo USD
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Costo (USD)',
                          prefixIcon: Icon(
                            Icons.money_off_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Obligatorio';
                          if (double.tryParse(val) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Precio USD
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Precio (USD)',
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Obligatorio';
                          if (double.tryParse(val) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Cantidad Inicial
                TextFormField(
                  controller: _stockController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad Inicial (Almacén Principal)',
                    prefixIcon: Icon(
                      Icons.warehouse_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Obligatorio';
                    if (double.tryParse(val) == null) return 'Inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.primary,
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Registrar y Agregar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
