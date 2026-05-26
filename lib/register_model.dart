class RegisterModel {
  final String email;
  final String password;
  final int selectedRolId;
  final String nombre;
  final String telefono;
  final String direccion;

  RegisterModel({
    required this.email,
    required this.password,
    required this.selectedRolId,
    required this.nombre,
    required this.telefono,
    required this.direccion,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'contraseña': password,
      'idrol': selectedRolId,
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
    };
  }
}
