from django.contrib import admin
from .models import CategoriaProducto, Producto, CategoriaHasProductos


admin.site.register(CategoriaHasProductos)


@admin.register(CategoriaProducto)
class CategoriaProductoAdmin(admin.ModelAdmin):
    list_display = ('category_id', 'nombre')  
    search_fields = ('nombre',)  

