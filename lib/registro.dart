import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_model.dart';
import 'main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _authService = AuthService();
  int? _selectedRolId;
  bool _verPass = false;
  bool _verConfirm = false;

  final List<Map<String, dynamic>> _roles = [
    {'id': 2, 'nombre': 'Comprador', 'icono': Icons.shopping_cart_rounded},
    {'id': 3, 'nombre': 'Emprendedor', 'icono': Icons.storefront_rounded},
    {'id': 4, 'nombre': 'Proveedor', 'icono': Icons.local_shipping_rounded},
    {'id': 5, 'nombre': 'Asesor', 'icono': Icons.support_agent_rounded},
    {
      'id': 6,
      'nombre': 'Prestador de Servicios',
      'icono': Icons.construction_rounded,
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, seleccione un Rol.'),
          backgroundColor: TuliColors.rosa,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    final user = RegisterModel(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      selectedRolId: _selectedRolId!,
      nombre: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
    );

    final success = await _authService.registerUser(user);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cuenta registrada con éxito.'),
          backgroundColor: TuliColors.rosa,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _limpiarFormulario();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar cuenta.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _emailController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _selectedRolId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    TuliColors.rosa.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: TuliColors.rosa.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        TuliColors.rosa,
                                        TuliColors.morado,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: TuliColors.rosa.withOpacity(
                                          0.35,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person_add_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: TuliColors.texto,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Únete a la comunidad TuliMarket',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: TuliColors.textoSuave,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          _buildField(
                            'Nombre Completo',
                            _nombreController,
                            Icons.person_outline,
                            validator: (val) =>
                                val!.isEmpty ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Correo Electrónico',
                            _emailController,
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) =>
                                val!.isEmpty ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Número de Teléfono',
                            _telefonoController,
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (val) =>
                                val!.isEmpty ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Dirección de Residencia',
                            _direccionController,
                            Icons.location_on_outlined,
                            validator: (val) =>
                                val!.isEmpty ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Contraseña',
                            _passwordController,
                            Icons.lock_outline,
                            obscure: !_verPass,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: TuliColors.textoSuave,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _verPass = !_verPass),
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Confirmar Contraseña',
                            _confirmPasswordController,
                            Icons.lock_outline,
                            obscure: !_verConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: TuliColors.textoSuave,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _verConfirm = !_verConfirm),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Por favor, confirme su contraseña';
                              if (val != _passwordController.text)
                                return 'Las contraseñas no coinciden';
                              return null;
                            },
                          ),

                          const SizedBox(height: 22),

                          // Selección de rol
                          const Text(
                            'ROL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: TuliColors.textoSuave,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _roles.map((rol) {
                              final int rolId = rol['id'] as int;
                              final bool selected = _selectedRolId == rolId;
                              return InkWell(
                                onTap: () => setState(
                                  () =>
                                      _selectedRolId = selected ? null : rolId,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: selected
                                        ? const LinearGradient(
                                            colors: [
                                              TuliColors.rosa,
                                              TuliColors.morado,
                                            ],
                                          )
                                        : null,
                                    color: selected
                                        ? null
                                        : const Color(0xFFF8F8FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.transparent
                                          : const Color(0xFFEEEEF5),
                                      width: 1.5,
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: TuliColors.rosa
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        rol['icono'] as IconData,
                                        size: 15,
                                        color: selected
                                            ? Colors.white
                                            : TuliColors.textoSuave,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        rol['nombre'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : TuliColors.textoSuave,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 30),

                          // Botón finalizar
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [TuliColors.rosa, TuliColors.morado],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: TuliColors.rosa.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'CREAR CUENTA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Ya tengo cuenta · Iniciar sesión',
                                style: TextStyle(
                                  color: TuliColors.textoSuave,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: TuliColors.textoSuave,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEF5)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: TuliColors.texto),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: TuliColors.rosa, size: 18),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              errorStyle: const TextStyle(
                fontSize: 11,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
