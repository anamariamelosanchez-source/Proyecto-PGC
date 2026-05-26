from django.contrib import admin
from django.utils.html import format_html
from Producto.models import Producto  

@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):

    list_display = [
        'idproducto', 
        'mostrar_foto', 
        'nombre', 
        'stock', 
        'precio_venta', 
        'category_category_id', 
        'usuarios_idusuario_id'
    ]
    
    list_filter = ['category_category_id', 'stock']
    search_fields = ['idproducto', 'nombre', 'descripcion']
    raw_id_fields = ['category_category', 'usuarios_idusuario']

    def mostrar_foto(self, obj):
        if obj.foto:
            return format_html('<img src="{}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;" />', obj.foto.url)
        return format_html('<span style="color: #999; font-style: italic;">Sin foto</span>')
    
    mostrar_foto.short_description = 'Imagen'
