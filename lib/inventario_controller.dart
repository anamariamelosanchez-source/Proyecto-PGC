import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InventarioController extends ChangeNotifier {
  final String _baseUrl = "http://127.0.0.1:8000/api/inventario/productos/";

  List<dynamic> _productos = [];
  List<dynamic> productosFiltrados = [];
  bool cargando = false;
  Future<void> obtenerProductos() async {
    cargando = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        _productos = json.decode(utf8.decode(response.bodyBytes));
        productosFiltrados = List.from(_productos);
      }
    } catch (e) {
      debugPrint("Error al obtener inventario: $e");
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void filtrarProductos(String query) {
    if (query.isEmpty) {
      productosFiltrados = List.from(_productos);
    } else {
      productosFiltrados = _productos.where((producto) {
        final nombre = (producto['nombre'] ?? '').toString().toLowerCase();
        final descripcion = (producto['descripcion'] ?? '')
            .toString()
            .toLowerCase();
        return nombre.contains(query.toLowerCase()) ||
            descripcion.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> eliminarProducto(int idProducto) async {
    try {
      final response = await http.delete(Uri.parse("$_baseUrl$idProducto/"));
      if (response.statusCode == 204) {
        _productos.removeWhere((p) => p['idproducto'] == idProducto);
        productosFiltrados.removeWhere((p) => p['idproducto'] == idProducto);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
    return false;
  }
}
