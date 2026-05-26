from rest_framework import serializers
from Producto.models import Producto  

class ProductoSerializer(serializers.ModelSerializer):
    usuarios_idusuario_id = serializers.IntegerField(write_only=True)
    category_category_id = serializers.IntegerField(write_only=True)
    foto = serializers.ImageField(required=False, allow_null=True)  

    class Meta:
        model = Producto
        fields = [
            'idproducto', 
            'nombre', 
            'stock', 
            'precio_venta', 
            'descripcion', 
            'usuarios_idusuario_id', 
            'category_category_id',
            'foto',
        ]

    def to_internal_value(self, data): 
        resource_data = data.copy()

        if 'category_category' in resource_data:
            valor = str(resource_data['category_category']).replace('"', '').replace('\\', '').strip()
            resource_data['category_category_id'] = valor
        elif 'category_category_id' in resource_data:
            valor = str(resource_data['category_category_id']).replace('"', '').replace('\\', '').strip()
            resource_data['category_category_id'] = valor
        if 'usuarios_idusuario' in resource_data:
            valor_usr = str(resource_data['usuarios_idusuario']).replace('"', '').replace('\\', '').strip()
            resource_data['usuarios_idusuario_id'] = valor_usr
        elif 'usuarios_idusuario_id' in resource_data:
            valor_usr = str(resource_data['usuarios_idusuario_id']).replace('"', '').replace('\\', '').strip()
            resource_data['usuarios_idusuario_id'] = valor_usr

        return super().to_internal_value(resource_data)

    def create(self, validated_data):
        return Producto.objects.create(**validated_data)

    def update(self, instance, validated_data):
        """Maneja la actualización física del producto en modo Edición"""
        instance.nombre = validated_data.get('nombre', instance.nombre)
        instance.stock = validated_data.get('stock', instance.stock)
        instance.precio_venta = validated_data.get('precio_venta', instance.precio_venta)
        instance.descripcion = validated_data.get('descripcion', instance.descripcion)
        instance.usuarios_idusuario_id = validated_data.get('usuarios_idusuario_id', instance.usuarios_idusuario_id)
        instance.category_category_id = validated_data.get('category_category_id', instance.category_category_id)

        if 'foto' in validated_data:
            instance.foto = validated_data.get('foto', instance.foto)
        instance.save()
        return instance
