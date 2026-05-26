import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarritoController extends ChangeNotifier {
  final String _baseUrl = "http://127.0.0.1:8000/api";

  Map<String, dynamic>? carritoActivo;
  List<dynamic> detalles = [];
  bool cargando = false;

  double get subtotal =>
      double.tryParse(carritoActivo?['subtotal'] ?? '0.0') ?? 0.0;
  double get total => double.tryParse(carritoActivo?['total'] ?? '0.0') ?? 0.0;
  Future<void> cargarCarrito(int idUsuario) async {
    cargando = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/carritos/?usuario=$idUsuario&estado=A');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          carritoActivo = data.first;
          detalles = carritoActivo?['detalles'] ?? [];
        } else {
          await crearCarrito(idUsuario);
        }
      }
    } catch (e) {
      debugPrint("Error al cargar carrito: $e");
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> crearCarrito(int idUsuario) async {
    try {
      final url = Uri.parse('$_baseUrl/carritos/');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"usuarios_idusuario": idUsuario}),
      );
      if (response.statusCode == 201) {
        carritoActivo = json.decode(response.body);
        detalles = [];
      }
    } catch (e) {
      debugPrint("Error al crear carrito: $e");
    }
  }

  Future<void> actualizarCantidad(int idDetalle, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await eliminarProducto(idDetalle);
      return;
    }

    try {
      final url = Uri.parse('$_baseUrl/detalles/$idDetalle/');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"cantidad": nuevaCantidad}),
      );

      if (response.statusCode == 200) {
        await cargarCarrito(carritoActivo?['usuarios_idusuario']);
      }
    } catch (e) {
      debugPrint("Error al actualizar cantidad: $e");
    }
  }

  Future<void> eliminarProducto(int idDetalle) async {
    try {
      final url = Uri.parse('$_baseUrl/detalles/$idDetalle/');
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        detalles.removeWhere((item) => item['iddetalle_carrito'] == idDetalle);
        await cargarCarrito(carritoActivo?['usuarios_idusuario']);
      }
    } catch (e) {
      debugPrint("Error al eliminar producto: $e");
    }
  }

  Future<bool> agregarProductoAlCarrito({
    required int idProducto,
    required double precioUnitario,
    int cantidad = 1,
  }) async {
    if (carritoActivo == null) {
      debugPrint(
        "Error: No hay un carrito activo inicializado para el usuario.",
      );
      return false;
    }

    try {
      final url = Uri.parse('$_baseUrl/detalles/');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "carrito_compras": carritoActivo!['idcarrito_compras'],
          "producto": idProducto,
          "cantidad": cantidad,
          "precio_unitario": precioUnitario.toStringAsFixed(2),
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("Producto agregado con éxito en Django");
        await cargarCarrito(carritoActivo!['usuarios_idusuario']);
        return true;
      } else {
        debugPrint(
          "Fallo al agregar producto. Código de estado: ${response.statusCode}",
        );
        debugPrint("Respuesta: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception al agregar al carrito: $e");
      return false;
    }
  }
}
