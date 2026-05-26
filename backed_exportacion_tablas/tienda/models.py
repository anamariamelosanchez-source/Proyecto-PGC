# tienda/models.py
from django.db import models

class Usuarios(models.Model):
    idusuario = models.IntegerField(db_column='idUsuario', primary_key=True)
    nombre = models.CharField(db_column='Nombre', max_length=45)
    telefono = models.CharField(db_column='Telefono', max_length=15)
    email = models.CharField(db_column='Email', max_length=45)
    contraseña = models.CharField(db_column='Contrasena', max_length=45)
    estado = models.CharField(db_column='Estado', max_length=1)

    class Meta:
        managed = False
        db_table = 'usuarios'


class Rol(models.Model):
    idrol = models.IntegerField(db_column='idRol', primary_key=True)
    nombre_rol = models.CharField(db_column='Nombre_Rol', max_length=120)

    class Meta:
        managed = False
        db_table = 'rol'


class UsuariosHasRol(models.Model):
    usuarios_idusuario = models.ForeignKey(Usuarios, models.DO_NOTHING, db_column='Usuarios_Idusuario', primary_key=True) 
    rol_idrol = models.ForeignKey(Rol, models.DO_NOTHING, db_column='Rol_idRol')

    class Meta:
        managed = False
        db_table = 'usuarios_has_rol'
        unique_together = (('usuarios_idusuario', 'rol_idrol'),)



class CategoriaProducto(models.Model):
    category_id = models.IntegerField(primary_key=True)
    nombre = models.CharField(db_column='Nombre', max_length=255)

    class Meta:
        managed = False
        db_table = 'categoria_producto'


class CategoriaServicio(models.Model):
    category_id = models.IntegerField(primary_key=True)
    nombre = models.CharField(db_column='Nombre', max_length=255)

    class Meta:
        managed = False
        db_table = 'categoria_servicio'


class Producto(models.Model):
    idproducto = models.IntegerField(db_column='idProducto', primary_key=True) 
    nombre = models.CharField(db_column='Nombre', max_length=45) 
    stock = models.IntegerField(db_column='Stock') 
    precio_venta = models.DecimalField(db_column='Precio_Venta', max_digits=10, decimal_places=2) 
    descripcion = models.CharField(db_column='Descripcion', max_length=200) 
    usuarios_idusuario = models.ForeignKey(Usuarios, models.DO_NOTHING, db_column='Usuarios_Idusuario') 
    category_category = models.ForeignKey(CategoriaProducto, models.DO_NOTHING, db_column='category_category_id')

    class Meta:
        managed = False
        db_table = 'producto'
        unique_together = (('idproducto', 'usuarios_idusuario', 'category_category'),)


class CategoriaHasProductos(models.Model):
    categoria_idcategoria = models.ForeignKey(
        CategoriaProducto, 
        models.DO_NOTHING, 
        db_column='Categoria_idCategoria', 
        primary_key=True 
    )
    productos_idproductos = models.ForeignKey(
        Producto, 
        models.DO_NOTHING, 
        db_column='Productos_idProductos'
    )

    class Meta:
        managed = False
        db_table = 'categoria_has_productos'
        unique_together = (('categoria_idcategoria', 'productos_idproductos'),)



class Inventario(models.Model):
    idinventario = models.AutoField(db_column='idInventario', primary_key=True) 
    cantidad = models.IntegerField(db_column='Cantidad') 
    precio_compra_unitario = models.DecimalField(db_column='Precio_Compra_Unitario', max_digits=10, decimal_places=2) 
    fecha_entrada = models.DateTimeField(db_column='Fecha_Entrada') 
    observaciones = models.CharField(db_column='Observaciones', max_length=255) 
    producto = models.ForeignKey(Producto, models.DO_NOTHING, db_column='Producto_idProducto') 

    class Meta:
        managed = False
        db_table = 'inventario'


class CarritoCompras(models.Model):
    idcarrito_compras = models.IntegerField(db_column='idCarrito_Compras', primary_key=True) 
    subtotal = models.DecimalField(db_column='Subtotal', max_digits=10, decimal_places=2) 
    total = models.DecimalField(db_column='Total', max_digits=10, decimal_places=2) 
    fecha_creacion = models.DateTimeField(db_column='Fecha_Creación') 
    estado = models.CharField(db_column='Estado', max_length=1) 
    usuarios_idusuario = models.ForeignKey(Usuarios, models.DO_NOTHING, db_column='Usuarios_Idusuario') 

    class Meta:
        managed = False
        db_table = 'carrito_compras'
        unique_together = (('idcarrito_compras', 'usuarios_idusuario'),)


class Servicios(models.Model):
    idservicios = models.IntegerField(db_column='idServicios', primary_key=True)
    # CORREGIDO: Se alinean los nombres con tu captura real de MySQL Workbench
    nombre = models.CharField(db_column='Nombre_Servicio', max_length=45)
    descripcion = models.CharField(db_column='Descripcion_Servicio', max_length=200)
    precio = models.DecimalField(db_column='Precio', max_digits=10, decimal_places=2)
    usuarios_idusuario = models.ForeignKey(Usuarios, models.DO_NOTHING, db_column='Usuarios_Idusuario')
    categoria_servicio_category = models.ForeignKey(CategoriaServicio, models.DO_NOTHING, db_column='Categoria_Servicio_category_id')

    class Meta:
        managed = False
        db_table = 'servicios'
        unique_together = (('idservicios', 'usuarios_idusuario', 'categoria_servicio_category'),)


class DetalleCarrito(models.Model):
    iddetalle_carrito = models.IntegerField(db_column='idDetalle_carrito', primary_key=True)
    cantidad = models.IntegerField(db_column='Cantidad')
    precio_unitario = models.DecimalField(db_column='Precio_Unitario', max_digits=10, decimal_places=2)
    carrito_compras = models.ForeignKey(CarritoCompras, models.DO_NOTHING, db_column='Carrito_Compras_idCarrito_Compras')
    producto = models.ForeignKey(Producto, models.DO_NOTHING, db_column='Producto_idProducto')
    servicios = models.ForeignKey(Servicios, models.DO_NOTHING, db_column='Servicios_idServicios')

    class Meta:
        managed = False
        db_table = 'detalle_carrito'
        unique_together = (('iddetalle_carrito', 'carrito_compras', 'producto', 'servicios'),)


class DetalleVenta(models.Model):
    iddetalle_venta = models.IntegerField(db_column='idDetalle_Venta', primary_key=True)
    cantidad = models.IntegerField(db_column='Cantidad')
    precio_unitario = models.DecimalField(db_column='Precio_Unitario', max_digits=10, decimal_places=2)
    fecha_pago = models.DateTimeField(db_column='Fecha_pago')
    venta_factura_idventa_factura = models.ForeignKey('api.VentaFactura', models.DO_NOTHING, db_column='Venta_Factura_idVenta_Factura')
    producto_idproducto = models.ForeignKey(Producto, models.DO_NOTHING, db_column='Producto_idProducto')
    servicios_idservicios = models.ForeignKey(Servicios, models.DO_NOTHING, db_column='Servicios_idServicios')

    class Meta:
        managed = False
        db_table = 'detalle_venta'
        unique_together = (('iddetalle_venta', 'venta_factura_idventa_factura', 'producto_idproducto', 'servicios_idservicios'),)
