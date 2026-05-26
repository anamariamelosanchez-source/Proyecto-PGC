# api/models.py
# -*- coding: utf-8 -*-

from django.db import models  

class Contabilidad(models.Model):
    idcontabilidad = models.IntegerField(db_column='idContabilidad', primary_key=True)
    nombre_empresa = models.CharField(db_column='Nombre_Empresa', max_length=45)
    reporte = models.CharField(db_column='Reporte', max_length=1)
    total = models.DecimalField(db_column='Total', max_digits=10, decimal_places=2)
    fecha_edicion = models.DateTimeField(db_column='Fecha_Edicion')

    class Meta:
        managed = False
        db_table = 'contabilidad'

class VentaFactura(models.Model):
    idventa_factura = models.IntegerField(db_column='idVenta_Factura', primary_key=True)
    fecha_pedido = models.DateTimeField(db_column='Fecha_Pedido')
    mÚtodo_pago = models.CharField(db_column='Método_pago', max_length=45)
    impuesto_iva = models.DecimalField(db_column='Impuesto_Iva', max_digits=10, decimal_places=2)
    total = models.DecimalField(db_column='Total', max_digits=10, decimal_places=2)
    contabilidad_idcontabilidad = models.ForeignKey(Contabilidad, models.DO_NOTHING, db_column='Contabilidad_idContabilidad')

    class Meta:
        managed = False
        db_table = 'venta_factura'
        unique_together = (('idventa_factura', 'contabilidad_idcontabilidad'),)
