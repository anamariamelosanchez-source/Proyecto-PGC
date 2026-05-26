# api/admin.py
from django.contrib import admin
from .models import Contabilidad, VentaFactura

@admin.register(Contabilidad)
class ContabilidadAdmin(admin.ModelAdmin):
    list_display = ('idcontabilidad', 'nombre_empresa', 'reporte', 'total', 'fecha_edicion')

@admin.register(VentaFactura)
class VentaFacturaAdmin(admin.ModelAdmin):
    list_display = ('idventa_factura', 'fecha_pedido', 'mÚtodo_pago', 'total')
