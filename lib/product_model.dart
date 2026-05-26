class ProductoModel {
  final int idProducto;
  final String nombre;
  final int stock;
  final String descripcion;
  final int usuarioId;
  final double precioVenta;
  final String urlFoto;

  const ProductoModel({
    required this.idProducto,
    required this.nombre,
    required this.stock,
    required this.descripcion,
    required this.usuarioId,
    this.precioVenta = 0.0,
    this.urlFoto = '',
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    double parsePrecio(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    String resolverFoto(dynamic v) {
      if (v == null || v.toString().isEmpty) return '';
      final s = v.toString();
      if (s.startsWith('http')) return s;
      return 'http://127.0.0.1:8000$s';
    }

    String parsearDescripcion(dynamic v) {
      if (v == null) return '';
      final texto = v.toString();
      if (texto.contains('- Descripción:')) {
        final lineas = texto.split('\n');
        final lineaDesc = lineas.firstWhere(
          (l) => l.trim().startsWith('- Descripción:'),
          orElse: () => '',
        );
        return lineaDesc.replaceFirst('- Descripción:', '').trim();
      }
      return texto;
    }

    return ProductoModel(
      idProducto: json['idproducto'] ?? json['Idproducto'] ?? 0,
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      descripcion: parsearDescripcion(
        json['descripcion'] ?? json['Descripción'] ?? json['Descripcion'],
      ),
      usuarioId:
          int.tryParse(json['usuario_id']?.toString() ?? '0') ??
          int.tryParse(json['usuarios_idusuario']?.toString() ?? '0') ??
          0,
      precioVenta: parsePrecio(
        json['precio_venta'] ?? json['precioVenta'] ?? json['precio'],
      ),
      urlFoto: resolverFoto(json['foto'] ?? json['url_foto'] ?? json['imagen']),
    );
  }
}
