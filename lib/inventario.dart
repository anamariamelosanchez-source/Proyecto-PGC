import 'package:flutter/material.dart';
import 'añadir_producto.dart';
import 'inventario_controller.dart';
import 'main.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});
  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final InventarioController _controller = InventarioController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.obtenerProductos();
    _searchController.addListener(() {
      _controller.filtrarProductos(_searchController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'CONTROL DE INVENTARIO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: TuliColors.texto,
            letterSpacing: 0.8,
          ),
        ),
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
        foregroundColor: TuliColors.texto,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TuliColors.rosa,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AnadirProductoView(usuarioIdActual: 30),
            ),
          );
          if (resultado == true) _controller.obtenerProductos();
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEF5)),
                boxShadow: [
                  BoxShadow(
                    color: TuliColors.rosa.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: TuliColors.texto),
                decoration: const InputDecoration(
                  hintText: 'Buscar en tu inventario por nombre o detalle...',
                  hintStyle: TextStyle(
                    color: TuliColors.textoSuave,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TuliColors.rosa,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (_controller.cargando) {
                  return const Center(
                    child: CircularProgressIndicator(color: TuliColors.rosa),
                  );
                }
                if (_controller.productosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: TuliColors.rosaClaro,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: TuliColors.rosa,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron productos.',
                          style: TextStyle(
                            color: TuliColors.textoSuave,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: _controller.productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = _controller.productosFiltrados[index];
                    return _buildProductoCard(producto);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(Map<String, dynamic> producto) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(
            color: TuliColors.rosa.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Foto producto
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TuliColors.rosaClaro,
                    TuliColors.morado.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: producto['foto'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        producto['foto'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image_rounded,
                              color: TuliColors.rosa,
                              size: 28,
                            ),
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_rounded,
                      color: TuliColors.rosa,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: TuliColors.texto,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildChip(
                        'Stock: ${producto['stock']}',
                        TuliColors.morado.withOpacity(0.12),
                        TuliColors.morado,
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        '\$${producto['precio_venta']}',
                        TuliColors.rosa.withOpacity(0.12),
                        TuliColors.rosa,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Acciones
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionBtn(
                  Icons.edit_rounded,
                  const Color(0xFFE3F2FD),
                  Colors.blueAccent,
                  () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnadirProductoView(
                          usuarioIdActual: 30,
                          productoParaEditar: producto,
                        ),
                      ),
                    );
                    if (resultado == true) _controller.obtenerProductos();
                  },
                ),
                const SizedBox(width: 6),
                _buildActionBtn(
                  Icons.delete_rounded,
                  const Color(0xFFFFEBEE),
                  Colors.redAccent,
                  () => _mostrarConfirmacionEliminar(
                    producto['idproducto'],
                    producto['nombre'] ?? 'este producto',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  void _mostrarConfirmacionEliminar(int id, String nombre) {
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
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '¿Eliminar producto?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Esta acción quitará a "$nombre" de tu inventario permanentemente.',
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
              Navigator.pop(context);
              bool exito = await _controller.eliminarProducto(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      exito
                          ? 'Producto eliminado con éxito'
                          : 'Error al eliminar el producto',
                    ),
                    backgroundColor: exito ? TuliColors.rosa : Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
}
