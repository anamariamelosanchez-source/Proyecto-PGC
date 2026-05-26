# tienda/admin.py
from django.contrib import admin
from .models import (
    Usuarios, Rol, UsuariosHasRol, CategoriaProducto, 
    CategoriaServicio, Producto, CategoriaHasProductos, 
    Inventario, CarritoCompras, Servicios, DetalleCarrito, DetalleVenta
)

@admin.register(Usuarios)
class UsuariosAdmin(admin.ModelAdmin):
    list_display = ('idusuario', 'nombre', 'email', 'estado')

@admin.register(Rol)
class RolAdmin(admin.ModelAdmin):
    list_display = ('idrol', 'nombre_rol')

@admin.register(UsuariosHasRol)
class UsuariosHasRolAdmin(admin.ModelAdmin):
    list_display = ('usuarios_idusuario', 'rol_idrol')

@admin.register(CategoriaProducto)
class CategoriaProductoAdmin(admin.ModelAdmin):
    list_display = ('category_id', 'nombre')

@admin.register(CategoriaServicio)
class CategoriaServicioAdmin(admin.ModelAdmin):
    list_display = ('category_id', 'nombre')

@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):
    list_display = ('idproducto', 'nombre', 'stock', 'precio_venta')

@admin.register(CategoriaHasProductos)
class CategoriaHasProductosAdmin(admin.ModelAdmin):
    list_display = ('categoria_idcategoria', 'productos_idproductos')

@admin.register(Inventario)
class InventarioAdmin(admin.ModelAdmin):
    list_display = ('idinventario', 'cantidad', 'precio_compra_unitario', 'fecha_entrada')

@admin.register(CarritoCompras)
class CarritoComprasAdmin(admin.ModelAdmin):
    list_display = ('idcarrito_compras', 'total', 'estado')

@admin.register(Servicios)
class ServiciosAdmin(admin.ModelAdmin):
    list_display = ('idservicios', 'nombre', 'precio')

@admin.register(DetalleCarrito)
class DetalleCarritoAdmin(admin.ModelAdmin):
    list_display = ('iddetalle_carrito', 'carrito_compras', 'producto', 'cantidad')

@admin.register(DetalleVenta)
class DetalleVentaAdmin(admin.ModelAdmin):
    list_display = ('iddetalle_venta', 'venta_factura_idventa_factura', 'cantidad', 'precio_unitario')
