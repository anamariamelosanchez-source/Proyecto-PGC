from django.contrib import admin
from .models import CarritoCompras, DetalleCarrito


class DetalleCarritoInline(admin.TabularInline):
    """Permite ver y editar los productos del carrito desde el panel del Carrito Principal."""
    model = DetalleCarrito
    extra = 0 
    fields = ['producto', 'cantidad', 'precio_unitario', 'get_subtotal_linea']
    readonly_fields = ['get_subtotal_linea']
    raw_id_fields = ['producto'] 

    def get_subtotal_linea(self, obj):
        if obj and obj.cantidad and obj.precio_unitario:
            return f"${obj.subtotal_linea():,.2f}"
        return "$0.00"
    
    get_subtotal_linea.short_description = 'Subtotal Línea'


@admin.register(CarritoCompras)
class CarritoComprasAdmin(admin.ModelAdmin):
    list_display = [
        'idcarrito_compras', 
        'usuarios_idusuario', 
        'subtotal', 
        'total', 
        'fecha_creacion', 
        'estado'
    ]

    list_filter = ['estado', 'fecha_creacion']
    search_fields = [
        'idcarrito_compras', 
        'usuarios_idusuario__idusuario', 
        'usuarios_idusuario__username' 
    ]
    readonly_fields = ['fecha_creacion']
    inlines = [DetalleCarritoInline]


@admin.register(DetalleCarrito)
class DetalleCarritoAdmin(admin.ModelAdmin):
    """Panel secundario por si necesitas buscar un registro de detalle específico."""
    list_display = [
        'iddetalle_carrito', 
        'carrito_compras', 
        'producto', 
        'cantidad', 
        'precio_unitario', 
        'get_subtotal'
    ]
    list_filter = ['carrito_compras__estado']
    raw_id_fields = ['carrito_compras', 'producto']

    def get_subtotal(self, obj):
        return f"${obj.subtotal_linea():,.2f}"
    
    get_subtotal.short_description = 'Subtotal'
