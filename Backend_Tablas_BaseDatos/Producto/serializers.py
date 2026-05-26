from rest_framework import serializers
from .models import Producto, CategoriaProducto, CategoriaHasProductos

class CategoriaProductoSerializer(serializers.ModelSerializer):
    class Meta:
        model = CategoriaProducto
        fields = '__all__'


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
        if 'category_category' in resource_data and 'category_category_id' not in resource_data:
            valor = str(resource_data['category_category']).replace('"', '').strip()
            resource_data['category_category_id'] = valor
        if 'usuarios_idusuario' in resource_data and 'usuarios_idusuario_id' not in resource_data:
            valor_usr = str(resource_data['usuarios_idusuario']).replace('"', '').strip()
            resource_data['usuarios_idusuario_id'] = valor_usr

        return super().to_internal_value(resource_data)
    
    def create(self, validated_data):
        return Producto.objects.create(**validated_data)


class CategoriaHasProductosSerializer(serializers.ModelSerializer):
    class Meta:
        model = CategoriaHasProductos
        fields = '__all__'



