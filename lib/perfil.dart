import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'product_model.dart';
import 'main.dart'; // TuliColors

class PerfilPage extends StatefulWidget {
  final String nombreUsuario;
  final String telefonoUsuario;
  final String direccionUsuario;
  final String rolUsuario;
  final String emailUsuario;

  const PerfilPage({
    super.key,
    required this.nombreUsuario,
    required this.telefonoUsuario,
    required this.direccionUsuario,
    required this.rolUsuario,
    this.emailUsuario = '',
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final AuthService _authService = AuthService();

  late String _nombre;
  late String _telefono;
  late String _direccion;

  Key _futureBuilderKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _nombre = widget.nombreUsuario;
    _telefono = widget.telefonoUsuario;
    _direccion = widget.direccionUsuario;
  }

  void _refrescarProductos() {
    setState(() => _futureBuilderKey = UniqueKey());
  }

  void _mostrarDialogoEditar() {
    final nombreController = TextEditingController(text: _nombre);
    final telefonoController = TextEditingController(text: _telefono);
    final direccionController = TextEditingController(text: _direccion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TuliColors.rosa, TuliColors.morado],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Editar Perfil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(
                'Nombre',
                nombreController,
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'Teléfono',
                telefonoController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'Dirección',
                direccionController,
                Icons.location_on_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: TuliColors.textoSuave,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TuliColors.rosa, TuliColors.morado],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                bool exito = await _authService.actualizarPerfilUsuario(
                  nombreUsuario: widget.nombreUsuario,
                  nuevoNombre: nombreController.text,
                  nuevoTelefono: telefonoController.text,
                  nuevaDireccion: direccionController.text,
                );
                if (exito && mounted) {
                  setState(() {
                    _nombre = nombreController.text;
                    _telefono = telefonoController.text;
                    _direccion = direccionController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Perfil guardado con éxito'),
                      backgroundColor: TuliColors.rosa,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
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
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: TuliColors.texto),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: TuliColors.rosa, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TuliColors.rosa),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [TuliColors.rosa, TuliColors.morado],
          ).createShader(bounds),
          child: const Text(
            'TULIVENTAS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TuliColors.rosa,
                  TuliColors.naranja,
                  TuliColors.morado,
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tarjeta de perfil
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TuliColors.rosa, TuliColors.morado],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TuliColors.rosa.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombre.isNotEmpty
                              ? _nombre.toUpperCase()
                              : 'SIN NOMBRE',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.emailUsuario.isNotEmpty)
                          _buildInfoLine(
                            Icons.email_rounded,
                            widget.emailUsuario,
                          ),
                        const SizedBox(height: 4),
                        _buildInfoLine(
                          Icons.phone_rounded,
                          _telefono.isNotEmpty ? _telefono : 'No registrado',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoLine(
                          Icons.location_on_rounded,
                          _direccion.isNotEmpty ? _direccion : 'No registrada',
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: _mostrarDialogoEditar,
                    ),
                  ),
                ],
              ),
            ),

            // Título productos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
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
                    'MIS PRODUCTOS EN TULIVENTAS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: TuliColors.texto,
                    ),
                  ),
                ],
              ),
            ),

            // Grid de productos
            Expanded(
              child: FutureBuilder<List<ProductoModel>>(
                key: _futureBuilderKey,
                future: _authService.obtenerProductosUsuario(
                  widget.nombreUsuario,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: TuliColors.rosa),
                    );
                  }

                  final productos = snapshot.data ?? [];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 600
                          ? 5
                          : constraints.maxWidth > 400
                          ? 3
                          : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.73,
                        ),
                        itemCount: productos.isEmpty ? 10 : productos.length,
                        itemBuilder: (context, index) {
                          if (productos.isEmpty) {
                            return const ItemProductoCardPlaceholder();
                          }
                          return ItemProductoCard(
                            producto: productos[index],
                            onAccionRealizada: _refrescarProductos,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Botón finalizar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TuliColors.rosa,
                    side: BorderSide(
                      color: TuliColors.rosa.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'FINALIZAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ItemProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onAccionRealizada;

  const ItemProductoCard({
    super.key,
    required this.producto,
    required this.onAccionRealizada,
  });

  void _dialogoEditarProducto(BuildContext context) {
    final nombreCtrl = TextEditingController(text: producto.nombre);
    final stockCtrl = TextEditingController(text: producto.stock.toString());
    final descCtrl = TextEditingController(text: producto.descripcion);
    final AuthService authService = AuthService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Editar Producto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAlertField(
              'Nombre del Producto',
              nombreCtrl,
              Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 10),
            _buildAlertField(
              'Stock',
              stockCtrl,
              Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildAlertField(
              'Descripción',
              descCtrl,
              Icons.description_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: TuliColors.textoSuave,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TuliColors.rosa, TuliColors.morado],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final int idProd = producto.idProducto;
                bool exito = await authService.actualizarProducto(
                  idProducto: idProd,
                  nuevoNombre: nombreCtrl.text,
                  nuevoStock: int.tryParse(stockCtrl.text) ?? 0,
                  nuevaDescripcion: descCtrl.text,
                );
                if (exito && context.mounted) {
                  Navigator.pop(context);
                  onAccionRealizada();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Producto actualizado con éxito'),
                      backgroundColor: TuliColors.rosa,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Error al guardar el producto'),
                    ),
                  );
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: TuliColors.textoSuave,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEEEEF5)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: TuliColors.texto),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: TuliColors.rosa, size: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _dialogoEliminarProducto(BuildContext context) {
    final AuthService authService = AuthService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '¿Eliminar Producto?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de borrar "${producto.nombre}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: TuliColors.textoSuave, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: TuliColors.textoSuave,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final int idProd = producto.idProducto;
              bool exito = await authService.eliminarProducto(idProd);
              if (exito && context.mounted) {
                Navigator.pop(context);
                onAccionRealizada();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto eliminado permanentemente'),
                    backgroundColor: TuliColors.rosa,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(
            color: TuliColors.rosa.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TuliColors.rosaClaro,
                    TuliColors.morado.withOpacity(0.08),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 28,
                      color: TuliColors.rosa,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Row(
                      children: [
                        _buildMiniBtn(
                          Icons.edit_rounded,
                          Colors.blueAccent,
                          () => _dialogoEditarProducto(context),
                        ),
                        const SizedBox(width: 3),
                        _buildMiniBtn(
                          Icons.delete_rounded,
                          Colors.redAccent,
                          () => _dialogoEliminarProducto(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: TuliColors.texto,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${producto.stock}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: TuliColors.textoSuave,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  producto.descripcion,
                  style: const TextStyle(
                    fontSize: 9,
                    color: TuliColors.textoSuave,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }
}

class ItemProductoCardPlaceholder extends StatelessWidget {
  const ItemProductoCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TuliColors.rosaClaro,
                    TuliColors.morado.withOpacity(0.06),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 9,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEF5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 7,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
