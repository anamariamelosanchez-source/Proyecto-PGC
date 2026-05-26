from django.db import models

class Inventario(models.Model):
    idinventario = models.AutoField(db_column='idInventario', primary_key=True) 
    cantidad = models.IntegerField(db_column='Cantidad') 
    precio_compra_unitario = models.DecimalField(db_column='Precio_Compra_Unitario', max_digits=10, decimal_places=2) 
    fecha_entrada = models.DateTimeField(db_column='Fecha_Entrada') 
    observaciones = models.CharField(db_column='Observaciones', max_length=255) 
    producto = models.ForeignKey('Producto.Producto', models.DO_NOTHING, db_column='Producto_idProducto') 

    class Meta:
        managed = False
        db_table = 'inventario'