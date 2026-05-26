from django.db import models


class CategoriaProducto(models.Model):
    category_id = models.IntegerField(primary_key=True)
    nombre = models.CharField(db_column='Nombre', max_length=255)

    class Meta:
        managed = False
        db_table = 'categoria_producto'

class Producto(models.Model):
    idproducto = models.IntegerField(db_column='idProducto', primary_key=True) 
    nombre = models.CharField(db_column='Nombre', max_length=45) 
    stock = models.IntegerField(db_column='Stock') 
    precio_venta = models.DecimalField(db_column='Precio_Venta', max_digits=10, decimal_places=2) 
    descripcion = models.CharField(db_column='Descripcion', max_length=200) 
    usuarios_idusuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='Usuarios_Idusuario') 
    category_category = models.ForeignKey(CategoriaProducto, models.DO_NOTHING, db_column='category_category_id')
    foto = models.ImageField(upload_to='productos/', null=True, blank=True)
    

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




