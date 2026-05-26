from rest_framework import serializers
from .models import Usuarios, Rol, UsuariosHasRol

class RolSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rol
        fields = ['idrol', 'nombre_rol'] 

class UsuariosSerializer(serializers.ModelSerializer):
    rol = serializers.SerializerMethodField()

    class Meta:
        model = Usuarios
        fields = [
            'idusuario', 
            'nombre', 
            'email', 
            'contraseña', 
            'telefono', 
            'direccion', 
            'estado', 
            'rol'
        ]
        extra_kwargs = {
            'contraseña': {
                'write_only': True,
                'style': {'input_type': 'password'}
            }
        }

    # Método encargado de buscar en la tabla intermedia y serializar el rol del usuario
    def get_rol(self, obj):
        relacion = UsuariosHasRol.objects.filter(usuarios_idusuario=obj).first()
        if relacion and relacion.rol_idrol:
            return RolSerializer(relacion.rol_idrol).data
        return None
