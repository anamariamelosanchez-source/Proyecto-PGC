# carrito/models.py
from django.db import models


class CarritoCompras(models.Model):
    idcarrito_compras = models.AutoField(db_column='idCarrito_Compras', primary_key=True)
    subtotal = models.DecimalField(db_column='Subtotal', max_digits=10, decimal_places=2, default=0)
    total = models.DecimalField(db_column='Total', max_digits=10, decimal_places=2, default=0)
    fecha_creacion = models.DateTimeField(db_column='Fecha_Creacion', auto_now_add=True)
    estado = models.CharField(db_column='Estado', max_length=1, default='A')  # A=Activo, C=Cerrado
    usuarios_idusuario = models.ForeignKey(
        'usuarios.Usuarios',
        models.DO_NOTHING,
        db_column='Usuarios_Idusuario'
    )

    class Meta:
        managed = False
        db_table = 'carrito_compras'

    def __str__(self):
        return f"Carrito #{self.idcarrito_compras} - Usuario {self.usuarios_idusuario_id}"


class DetalleCarrito(models.Model):
    iddetalle_carrito = models.AutoField(db_column='idDetalle_carrito', primary_key=True)
    cantidad = models.IntegerField(db_column='Cantidad')
    precio_unitario = models.DecimalField(db_column='Precio_Unitario', max_digits=10, decimal_places=2)
    carrito_compras = models.ForeignKey(
        CarritoCompras,
        models.DO_NOTHING,
        db_column='Carrito_Compras_idCarrito_Compras',
        related_name='detalles'
    )
    producto = models.ForeignKey(
        'Producto.Producto',
        models.DO_NOTHING,
        db_column='Producto_idProducto',
        null=True,
        blank=True
    )

    class Meta:
        managed = False
        db_table = 'detalle_carrito'

    def subtotal_linea(self):
        return self.cantidad * self.precio_unitario