import 'package:flutter/material.dart';
import 'perfil.dart';
import 'auth_service.dart' as servicio_auth;
import 'register_model.dart';
import 'barra_menu_ventas.dart';
import 'carrito.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  final String nombreUsuarioActual;
  final String urlFotoUsuario;

  const HomePage({
    super.key,
    required this.nombreUsuarioActual,
    this.urlFotoUsuario = "",
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  bool _isMenuOpen = false;
  String _seccionActual = 'HOME';

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Ropa', 'icono': Icons.checkroom},
    {'nombre': 'Zapatos', 'icono': Icons.ice_skating},
    {'nombre': 'Tejidos', 'icono': Icons.texture},
    {'nombre': 'Tecnología', 'icono': Icons.devices},
    {'nombre': 'Hoteles', 'icono': Icons.hotel},
    {'nombre': 'Comida', 'icono': Icons.restaurant},
  ];

  final List<List<Color>> _catGradients = [
    [Color(0xFFE8417A), Color(0xFFFF6B9D)],
    [Color(0xFF7B3FA0), Color(0xFF9C55C8)],
    [Color(0xFFF5A623), Color(0xFFFFCC02)],
    [Color(0xFF2196F3), Color(0xFF64B5F6)],
    [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
    [Color(0xFF4CAF50), Color(0xFF81C784)],
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TuliColors.fondo,
      body: Row(
        children: [
          // ── Menú Lateral
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: _isMenuOpen ? 248 : 0,
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(0xFFEEEEF5), width: 1),
              ),
            ),
            child: _isMenuOpen ? _buildSideMenu() : const SizedBox.shrink(),
          ),

          // ── Contenido Principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 44, left: 16, right: 20, bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEF5), width: 1)),
      ),
      child: Row(
        children: [
          _buildIconBtn(
            icon: _isMenuOpen ? Icons.menu_open : Icons.menu,
            onTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
          ),
          const SizedBox(width: 12),

          // Barra de búsqueda
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: TuliColors.fondo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEF5)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: TuliColors.texto),
                decoration: const InputDecoration(
                  hintText: 'Buscar servicios, productos...',
                  hintStyle: TextStyle(
                    color: TuliColors.textoSuave,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TuliColors.rosa,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Perfil
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              print(
                "Consultando datos en Django para: ${widget.nombreUsuarioActual}",
              );
              try {
                servicio_auth.AuthService authService =
                    servicio_auth.AuthService();
                RegisterModel datosUsuario = await authService
                    .obtenerPerfilUsuario(widget.nombreUsuarioActual);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilPage(
                        nombreUsuario: datosUsuario.nombre,
                        telefonoUsuario: datosUsuario.telefono.toString(),
                        direccionUsuario: datosUsuario.direccion,
                        rolUsuario: datosUsuario.selectedRolId.toString(),
                        emailUsuario: datosUsuario.email,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text("Error de servidor: $e"),
                    ),
                  );
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.nombreUsuarioActual.isNotEmpty
                      ? widget.nombreUsuarioActual
                      : 'Usuario',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TuliColors.texto,
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: TuliColors.rosaClaro,
                  backgroundImage: widget.urlFotoUsuario.isNotEmpty
                      ? NetworkImage(widget.urlFotoUsuario)
                      : null,
                  child: widget.urlFotoUsuario.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: TuliColors.rosa,
                          size: 20,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_seccionActual == 'VENTAS') return const VentasView();
    if (_seccionActual == 'CARRITO')
      return const CarritoScreen(idUsuarioActual: 30);
    return _buildHome();
  }

  // ── HOME
  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner bienvenida
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TuliColors.rosa, TuliColors.morado],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: TuliColors.rosa.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.nombreUsuarioActual.isNotEmpty ? widget.nombreUsuarioActual.split(' ').first : 'Bienvenido'} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Descubre lo mejor del mercado hoy',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Título categorías
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TuliColors.rosa, TuliColors.naranja],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'CATEGORÍAS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: TuliColors.texto,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 600 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                ),
                itemCount: _categorias.length,
                itemBuilder: (context, index) =>
                    _buildCatCard(_categorias[index], index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCatCard(Map<String, dynamic> cat, int index) {
    final grad = _catGradients[index % _catGradients.length];
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: grad.first.withOpacity(0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icono'] as IconData, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              cat['nombre'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 52,
            left: 20,
            right: 16,
            bottom: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TuliColors.rosa, TuliColors.morado],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'TuliMarket',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isMenuOpen = false),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: TuliColors.textoSuave,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Separador
        const Divider(color: Color(0xFFEEEEF5), height: 1, thickness: 1),
        const SizedBox(height: 8),

        // Ítems
        _buildMenuItem('INICIO', Icons.home_rounded, () {
          setState(() {
            _seccionActual = 'HOME';
            _isMenuOpen = false;
          });
        }),
        _buildMenuItem('PROVEEDORES', Icons.business_rounded, () {}),
        _buildMenuItem('VENTAS', Icons.point_of_sale_rounded, () {
          setState(() {
            _seccionActual = 'VENTAS';
            _isMenuOpen = false;
          });
        }),
        _buildMenuItem('ASESORÍAS', Icons.support_agent_rounded, () {}),
        _buildMenuItem('COMPRAS', Icons.shopping_bag_rounded, () {
          setState(() {
            _seccionActual = 'CARRITO';
            _isMenuOpen = false;
          });
        }),
        _buildMenuItem('SERVICIOS', Icons.construction_rounded, () {}),
      ],
    );
  }

  Widget _buildMenuItem(String titulo, IconData icono, VoidCallback onTap) {
    final bool active =
        (titulo == 'INICIO' && _seccionActual == 'HOME') ||
        (titulo == 'VENTAS' && _seccionActual == 'VENTAS') ||
        (titulo == 'COMPRAS' && _seccionActual == 'CARRITO');

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Fondo rosa muy suave solo en ítem activo
          color: active ? TuliColors.rosaClaro : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Indicador lateral rosa en activo
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 3,
              height: 18,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: active ? TuliColors.rosa : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              icono,
              size: 19,
              color: active ? TuliColors.rosa : TuliColors.textoSuave,
            ),
            const SizedBox(width: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.8,
                color: active ? TuliColors.rosa : TuliColors.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: TuliColors.fondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEF5)),
        ),
        child: Icon(icon, size: 22, color: TuliColors.texto),
      ),
    );
  }
}
