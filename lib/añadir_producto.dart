import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

const String kBaseUrl = 'http://127.0.0.1:8000';
const String kProductosUrl = '$kBaseUrl/api/inventario/productos/';

const Map<String, int> _kCategorias = {
  'ropa': 1,
  'zapatos': 2,
  'tejidos': 3,
  'tecnologia': 4,
  'tecnología': 4,
};

class AnadirProductoView extends StatefulWidget {
  final int usuarioIdActual;
  final Map<String, dynamic>? productoParaEditar;

  const AnadirProductoView({
    super.key,
    required this.usuarioIdActual,
    this.productoParaEditar,
  });

  @override
  State<AnadirProductoView> createState() => _AnadirProductoViewState();
}

class _AnadirProductoViewState extends State<AnadirProductoView> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _condicionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _transportadoraController = TextEditingController();
  final _stockController = TextEditingController();
  final _entregaController = TextEditingController();

  Uint8List? _webImage;
  final _picker = ImagePicker();
  bool _isLoading = false;

  bool get _esEdicion => widget.productoParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) _preCargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _condicionController.dispose();
    _ciudadController.dispose();
    _transportadoraController.dispose();
    _stockController.dispose();
    _entregaController.dispose();
    super.dispose();
  }

  void _preCargarDatos() {
    final p = widget.productoParaEditar!;
    _nombreController.text = p['nombre']?.toString() ?? '';
    _precioController.text = p['precio_venta']?.toString() ?? '';
    _stockController.text = p['stock']?.toString() ?? '';

    final descripcion = p['descripcion']?.toString() ?? '';
    for (final linea in descripcion.split('\n')) {
      String val(String prefijo) => linea.startsWith(prefijo)
          ? linea.replaceFirst(prefijo, '').trim()
          : '';

      if (linea.startsWith('- Descripción:'))
        _descripcionController.text = val('- Descripción:');
      else if (linea.startsWith('- Condición:'))
        _condicionController.text = val('- Condición:');
      else if (linea.startsWith('- Ciudad:'))
        _ciudadController.text = val('- Ciudad:');
      else if (linea.startsWith('- Transportadora:'))
        _transportadoraController.text = val('- Transportadora:');
      else if (linea.startsWith('- Entrega:'))
        _entregaController.text = val('- Entrega:');
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (imagen == null) return;
      final bytes = await imagen.readAsBytes();
      setState(() => _webImage = bytes);
    } catch (e) {
      debugPrint('Error al abrir la galería: $e');
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _precioController.clear();
    _descripcionController.clear();
    _categoriaController.clear();
    _condicionController.clear();
    _ciudadController.clear();
    _transportadoraController.clear();
    _stockController.clear();
    _entregaController.clear();
    setState(() => _webImage = null);
  }

  String? _validar() {
    if (_nombreController.text.trim().isEmpty)
      return 'El nombre es obligatorio.';
    if (_stockController.text.trim().isEmpty) return 'El stock es obligatorio.';
    final precioTexto = _precioController.text.trim().replaceAll(',', '.');
    final precio = double.tryParse(precioTexto);
    if (precioTexto.isEmpty) return 'El precio es obligatorio.';
    if (precio == null) return 'El precio debe ser un número válido.';
    if (precio <= 0) return 'El precio debe ser mayor que cero.';
    final stock = int.tryParse(_stockController.text.trim());
    if (stock == null || stock < 0)
      return 'El stock debe ser un número entero positivo.';
    return null;
  }

  Future<void> _guardarProducto() async {
    final error = _validar();
    if (error != null) {
      _mostrarSnack(error);
      return;
    }

    setState(() => _isLoading = true);

    final idCategoria =
        _kCategorias[_categoriaController.text.trim().toLowerCase()] ?? 1;
    final descripcionFormateada =
        'Detalles:\n'
        '- Descripción: ${_descripcionController.text.trim()}\n'
        '- Condición: ${_condicionController.text.trim()}\n'
        '- Ciudad: ${_ciudadController.text.trim()}\n'
        '- Transportadora: ${_transportadoraController.text.trim()}\n'
        '- Entrega: ${_entregaController.text.trim()}';
    final precio = double.parse(
      _precioController.text.trim().replaceAll(',', '.'),
    );

    try {
      final Uri url = _esEdicion
          ? Uri.parse(
              '$kProductosUrl${widget.productoParaEditar!['idproducto']}/',
            )
          : Uri.parse(kProductosUrl);

      final request = http.MultipartRequest(_esEdicion ? 'PATCH' : 'POST', url);
      request.fields['nombre'] = _nombreController.text.trim();
      request.fields['stock'] = _stockController.text.trim();
      request.fields['precio_venta'] = precio.toStringAsFixed(2);
      request.fields['descripcion'] = descripcionFormateada;
      request.fields['usuarios_idusuario'] = widget.usuarioIdActual.toString();
      request.fields['category_category'] = idCategoria.toString();

      if (!_esEdicion) {
        request.fields['idproducto'] =
            (DateTime.now().millisecondsSinceEpoch % 100000).toString();
      }
      if (_webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            _webImage!,
            filename: 'producto_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final exito = _esEdicion
          ? response.statusCode == 200
          : response.statusCode == 201;

      if (!mounted) return;
      if (exito) {
        _mostrarSnack(
          _esEdicion
              ? '¡Producto actualizado exitosamente!'
              : '¡Producto publicado exitosamente!',
          color: Colors.green,
        );
        if (_esEdicion) {
          if (Navigator.canPop(context)) Navigator.pop(context, true);
        } else {
          _limpiarFormulario();
        }
      } else {
        debugPrint('Error Django: ${response.body}');
        _mostrarSnack('Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      if (mounted) _mostrarSnack('No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnack(String mensaje, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── SELECTOR DE FOTO
  Widget _buildSelectorFoto() {
    DecorationImage? decorationImage;
    if (_webImage != null) {
      decorationImage = DecorationImage(
        image: MemoryImage(_webImage!),
        fit: BoxFit.cover,
      );
    } else {
      final fotoUrl = widget.productoParaEditar?['foto']?.toString();
      if (fotoUrl != null && fotoUrl.isNotEmpty) {
        decorationImage = DecorationImage(
          image: NetworkImage(fotoUrl),
          fit: BoxFit.cover,
        );
      }
    }

    final tieneFoto = decorationImage != null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: InkWell(
            onTap: _seleccionarFoto,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: tieneFoto
                    ? null
                    : LinearGradient(
                        colors: [
                          TuliColors.rosaClaro,
                          TuliColors.morado.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: tieneFoto
                      ? Colors.transparent
                      : TuliColors.rosa.withOpacity(0.3),
                  width: 2,
                ),
                image: decorationImage,
                boxShadow: [
                  BoxShadow(
                    color: TuliColors.rosa.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: tieneFoto
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [TuliColors.rosa, TuliColors.morado],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Cambiar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TuliColors.rosa.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 40,
                            color: TuliColors.rosa,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'AÑADIR FOTO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TuliColors.rosa,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para seleccionar',
                          style: TextStyle(
                            color: TuliColors.textoSuave,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [TuliColors.rosa, TuliColors.morado],
                      ).createShader(bounds),
                      child: Text(
                        _esEdicion ? 'EDITAR PRODUCTO' : 'PUBLICAR PRODUCTO',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _esEdicion
                          ? 'Actualiza la información de tu producto'
                          : 'Comparte tu producto con la comunidad TuliMarket',
                      style: const TextStyle(
                        fontSize: 13,
                        color: TuliColors.textoSuave,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _buildSelectorFoto(),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  if (isWide) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                'NOMBRE DEL PRODUCTO *',
                                _nombreController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormRow(
                                'PRECIO *',
                                _precioController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                'CATEGORÍA',
                                _categoriaController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormRow(
                                'CONDICIÓN',
                                _condicionController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildFormRow('NOMBRE DEL PRODUCTO *', _nombreController),
                      const SizedBox(height: 14),
                      _buildFormRow(
                        'PRECIO *',
                        _precioController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _buildFormRow('CATEGORÍA', _categoriaController),
                      const SizedBox(height: 14),
                      _buildFormRow('CONDICIÓN', _condicionController),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Descripción
              _buildLabel('DESCRIPCIÓN DEL PRODUCTO'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEF5)),
                ),
                child: TextField(
                  controller: _descripcionController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 14, color: TuliColors.texto),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                    hintText: 'Describe tu producto...',
                    hintStyle: TextStyle(color: TuliColors.textoSuave),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campos de envío
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  if (isWide) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                'CIUDAD / MUNICIPIO',
                                _ciudadController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormRow(
                                'STOCK *',
                                _stockController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFormRow(
                                'TRANSPORTADORA',
                                _transportadoraController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormRow(
                                'TIEMPO DE ENTREGA',
                                _entregaController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildFormRow('CIUDAD / MUNICIPIO', _ciudadController),
                      const SizedBox(height: 14),
                      _buildFormRow(
                        'STOCK *',
                        _stockController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _buildFormRow(
                        'TRANSPORTADORA',
                        _transportadoraController,
                      ),
                      const SizedBox(height: 14),
                      _buildFormRow('TIEMPO DE ENTREGA', _entregaController),
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 54,
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
                    onPressed: _isLoading ? null : _guardarProducto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _esEdicion
                                ? 'GUARDAR CAMBIOS'
                                : 'PUBLICAR PRODUCTO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: TuliColors.textoSuave,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildFormRow(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEF5)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: TuliColors.texto),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
