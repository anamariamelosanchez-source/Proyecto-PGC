import 'dart:convert';
import 'package:http/http.dart' as http;
import 'register_model.dart';
import 'product_model.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000';
  Future<bool> registerUser(RegisterModel user) async {
    try {
      final url = Uri.parse('$baseUrl/api/usuarios/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Usuario registrado con éxito en el servidor");
        return true;
      } else {
        print("Error del servidor al registrar: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  Future<RegisterModel> obtenerPerfilUsuario(String nombreUsuario) async {
    try {
      final url = Uri.parse('$baseUrl/api/usuarios/?nombre=$nombreUsuario');
      print("Realizando petición HTTP a: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Código de respuesta de Django (Perfil): ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final Map<String, dynamic> usuarioMapa = Map<String, dynamic>.from(
            data[0],
          );

          return RegisterModel(
            email:
                usuarioMapa['email']?.toString() ??
                usuarioMapa['Email']?.toString() ??
                '',
            password: '',
            nombre:
                usuarioMapa['nombre']?.toString() ??
                usuarioMapa['Nombre']?.toString() ??
                '',
            telefono:
                usuarioMapa['telefono']?.toString() ??
                usuarioMapa['Telefono']?.toString() ??
                '',
            direccion:
                usuarioMapa['direccion']?.toString() ??
                usuarioMapa['Direccion']?.toString() ??
                '',
            selectedRolId: (() {
              final dynamic rolValue = usuarioMapa['rol'] is Map
                  ? (usuarioMapa['rol'] as Map)['idrol']
                  : usuarioMapa['Rol'] ??
                        usuarioMapa['rol'] ??
                        usuarioMapa['selectedRolId'] ??
                        usuarioMapa['idRol'];
              return rolValue is int
                  ? rolValue
                  : int.tryParse(rolValue?.toString() ?? '') ?? 0;
            })(),
          );
        }
        throw Exception(
          "El usuario '$nombreUsuario' no existe en la Base de Datos.",
        );
      } else {
        throw Exception(
          "Error del servidor Django: Código ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Falla detectada en el flujo de Flutter (Perfil): $e");
      throw Exception("Error de conexión al obtener perfil: $e");
    }
  }

  Future<List<ProductoModel>> obtenerProductosUsuario(
    String nombreUsuario,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/inventario/productos/?vendedor=$nombreUsuario',
      );
      print("Realizando petición HTTP a productos: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print(
        "Código de respuesta de Django (Productos): ${response.statusCode}",
      );
      print("Cuerpo de productos recibido: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((jsonItem) {
          return ProductoModel.fromJson(Map<String, dynamic>.from(jsonItem));
        }).toList();
      } else {
        throw Exception(
          "Error del servidor Django en productos: Código ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Falla detectada en el flujo de Flutter (Productos): $e");
      return [];
    }
  }

  Future<bool> actualizarPerfilUsuario({
    required String nombreUsuario,
    required String nuevoNombre,
    required String nuevoTelefono,
    required String nuevaDireccion,
  }) async {
    try {
      final urlBuscar = Uri.parse(
        '$baseUrl/api/usuarios/?nombre=$nombreUsuario',
      );
      final responseBuscar = await http.get(
        urlBuscar,
        headers: {'Content-Type': 'application/json'},
      );

      if (responseBuscar.statusCode != 200) {
        print("No se pudo obtener el usuario para editar.");
        return false;
      }

      final List<dynamic> data = jsonDecode(responseBuscar.body);
      if (data.isEmpty) {
        print("Usuario no encontrado en la BD.");
        return false;
      }

      final usuarioId = data[0]['idusuario'] ?? data[0]['id'];
      if (usuarioId == null) {
        print("No se encontró el id del usuario.");
        return false;
      }

      final urlPatch = Uri.parse('$baseUrl/api/usuarios/$usuarioId/');
      final responsePatch = await http.patch(
        urlPatch,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nuevoNombre,
          'telefono': nuevoTelefono,
          'direccion': nuevaDireccion,
        }),
      );

      print("Código respuesta PATCH perfil: ${responsePatch.statusCode}");
      return responsePatch.statusCode == 200 || responsePatch.statusCode == 204;
    } catch (e) {
      print("Error al actualizar perfil: $e");
      return false;
    }
  }

  Future<bool> actualizarProducto({
    required int idProducto,
    required String nuevoNombre,
    required int nuevoStock,
    required String nuevaDescripcion,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/inventario/productos/$idProducto/');
      print("Realizando petición PATCH a producto: $url");

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nuevoNombre,
          'stock': nuevoStock,
          'descripcion': nuevaDescripcion,
        }),
      );

      print("Código respuesta PATCH producto: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error al actualizar producto: $e");
      return false;
    }
  }

  Future<bool> eliminarProducto(int idProducto) async {
    try {
      final url = Uri.parse('$baseUrl/api/inventario/productos/$idProducto/');
      print("Realizando petición DELETE a producto: $url");
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print("Código respuesta DELETE producto: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error al eliminar producto: $e");
      return false;
    }
  }
}
