import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'registro.dart';
import 'home_page.dart';

class TuliColors {
  TuliColors._();

  static const Color rosa = Color(0xFFE8417A);
  static const Color naranja = Color(0xFFFF8C42);
  static const Color morado = Color(0xFF7B3FA0);
  static const Color rosaClaro = Color(0xFFFDE9EF);
  static const Color texto = Color(0xFF1A1A2E);
  static const Color textoSuave = Color(0xFF8E8EA0);
  static const Color fondo = Color(0xFFFAFAFC);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final storage = const FlutterSecureStorage();

  Future<String?> _verificarToken() async {
    return await storage.read(key: 'auth_token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuliMarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Serif',
        colorScheme: ColorScheme.fromSeed(seedColor: TuliColors.rosa),
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: _verificarToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: TuliColors.rosa),
              ),
            );
          }
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            return HomePage(nombreUsuarioActual: snapshot.data!);
          }
          return const LoginPage();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegisterPage(),
        '/home': (context) => HomePage(
          nombreUsuarioActual:
              ModalRoute.of(context)!.settings.arguments as String? ?? '',
        ),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _cargando = false;

  Future<void> loginConDjango() async {
    final String username = _usuarioController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _cargando = true);

    // - Usar '10.0.2.2' si estás probando en emulador de Android Studio.
    // - Usar '127.0.0.1' si pruebas en emulador de iOS, Web o Desktop.
    // - Usar la IP privada de tu PC si pruebas en un teléfono celular físico.
    final url = Uri.http('127.0.0.1:8000', '/api/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> respuestaJson = Map<String, dynamic>.from(
          jsonDecode(response.body),
        );
        print("RESPUESTA COMPLETA DE DJANGO: $respuestaJson");
        String tokenObtenido = respuestaJson['token'];
        final Map<String, dynamic> datosUsuario = Map<String, dynamic>.from(
          respuestaJson['user'] ?? {},
        );
        String nombreUsuario = datosUsuario['nombre'] ?? "Pepita Pepita";
        await _storage.write(key: 'auth_token', value: tokenObtenido);
        print('¡Conexión exitosa con Django! Token obtenido: $tokenObtenido');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Inicio de sesión correcto!')),
          );
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: nombreUsuario,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario o contraseña incorrectos')),
          );
        }
        print('Error del servidor: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión a la red: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 850;
    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFFFDE9E9) : Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (!isMobile)
            Positioned(
              right: -size.width * 0.1,
              child: Container(
                width: size.width * 0.65,
                height: size.width * 0.65,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE9E9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isMobile)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: SizedBox(
                        width: 180,
                        child: Image.asset(
                          'assets/logo_tulimarketing.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(25),
                    decoration: isMobile
                        ? BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ],
                          )
                        : null,
                    child: Column(
                      children: [
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildInput(
                          hint: 'Correo',
                          controller: _usuarioController,
                          icono: Icons.mail_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildInput(
                          hint: 'Contraseña',
                          controller: _passwordController,
                          icono: Icons.lock_outline_rounded,
                          obscure: true,
                        ),
                        const SizedBox(height: 28),
                        // Botón degradado rosa → morado
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE8417A), Color(0xFF7B3FA0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE8417A,
                                  ).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _cargando ? null : loginConDjango,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _cargando
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'INGRESAR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            '¿Olvidaste tu Contraseña?',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isMobile)
                    SizedBox(
                      width: size.width * 0.35,
                      child: Image.asset(
                        'assets/logo_tulimarketpng.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    required TextEditingController controller,
    required IconData icono,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0EE), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC0C0CC), fontSize: 14),
          prefixIcon: Icon(icono, color: const Color(0xFFC0C0D0), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
