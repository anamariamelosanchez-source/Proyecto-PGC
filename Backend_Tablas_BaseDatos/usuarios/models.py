from django.db import models

class Usuarios(models.Model):
    idusuario = models.CharField(db_column='Idusuario', max_length=16, primary_key=True)
    nombre = models.CharField(db_column='Nombre', max_length=255)
    email = models.CharField(db_column='Email', max_length=200)
    contraseña = models.CharField(db_column='Contrasena', max_length=255)
    telefono = models.IntegerField(db_column='Telefono')
    direccion = models.CharField(db_column='Direccion', max_length=45)
    estado = models.CharField(db_column='Estado', max_length=1)

    class Meta:
        managed = False
        db_table = 'Usuarios' 

    def __str__(self):
        return self.nombre
    
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