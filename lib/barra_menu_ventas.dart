import 'package:flutter/material.dart';
import 'añadir_producto.dart';
import 'inventario.dart';
import 'main.dart';

class VentasView extends StatefulWidget {
  const VentasView({super.key});

  @override
  State<VentasView> createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  String _subSeccionVentas = 'MENU_PRINCIPAL';

  @override
  Widget build(BuildContext context) {
    if (_subSeccionVentas == 'ANADIR_PRODUCTO') {
      return Stack(
        children: [
          AnadirProductoView(usuarioIdActual: 30),
          Positioned(top: 10, left: 10, child: _buildBotonBack()),
        ],
      );
    }

    if (_subSeccionVentas == 'INVENTARIO') {
      return Stack(
        children: [
          const InventarioView(),
          Positioned(top: 14, left: 10, child: _buildBotonBack()),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TuliColors.rosa, TuliColors.naranja],
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
            child: const Column(
              children: [
                Icon(Icons.store_rounded, color: Colors.white54, size: 40),
                SizedBox(height: 10),
                Text(
                  'TuliVentas',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gestiona tu negocio desde aquí',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          LayoutBuilder(
            builder: (context, constraints) {
              final anchoMosaico = constraints.maxWidth > 700 ? 200.0 : 150.0;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildBotonVentas(
                    titulo: 'AÑADIR\nPRODUCTO',
                    icono: Icons.add_box_rounded,
                    gradiente: const LinearGradient(
                      colors: [Color(0xFFE8417A), Color(0xFFFF6B9D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shadowColor: TuliColors.rosa,
                    onTap: () =>
                        setState(() => _subSeccionVentas = 'ANADIR_PRODUCTO'),
                    ancho: anchoMosaico,
                  ),
                  _buildBotonVentas(
                    titulo: 'INVENTARIO',
                    icono: Icons.inventory_2_rounded,
                    gradiente: const LinearGradient(
                      colors: [Color(0xFF7B3FA0), Color(0xFF9C55C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shadowColor: TuliColors.morado,
                    onTap: () =>
                        setState(() => _subSeccionVentas = 'INVENTARIO'),
                    ancho: anchoMosaico,
                  ),
                  _buildBotonVentas(
                    titulo: 'CONTABILIDAD',
                    icono: Icons.calculate_rounded,
                    gradiente: const LinearGradient(
                      colors: [Color(0xFFF5A623), Color(0xFFFFCC02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shadowColor: TuliColors.naranja,
                    onTap: () => print('Clic en Contabilidad'),
                    ancho: anchoMosaico,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBotonBack() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: TuliColors.rosa,
          size: 22,
        ),
        onPressed: () => setState(() => _subSeccionVentas = 'MENU_PRINCIPAL'),
      ),
    );
  }

  Widget _buildBotonVentas({
    required String titulo,
    required IconData icono,
    required LinearGradient gradiente,
    required Color shadowColor,
    required VoidCallback onTap,
    required double ancho,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: ancho,
            height: ancho,
            decoration: BoxDecoration(
              gradient: gradiente,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icono, size: ancho * 0.38, color: Colors.white)],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: TuliColors.textoSuave,
          ),
        ),
      ],
    );
  }
}
