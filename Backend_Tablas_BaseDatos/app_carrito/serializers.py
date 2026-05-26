# carrito/serializers.py
from rest_framework import serializers
from .models import CarritoCompras, DetalleCarrito


class DetalleCarritoSerializer(serializers.ModelSerializer):
    subtotal_linea = serializers.SerializerMethodField()
    nombre_producto = serializers.SerializerMethodField()
    foto_producto = serializers.SerializerMethodField()

    class Meta:
        model = DetalleCarrito
        fields = [
            'iddetalle_carrito',
            'cantidad',
            'precio_unitario',
            'subtotal_linea',
            'carrito_compras',
            'producto',
            'nombre_producto',
            'foto_producto',
        ]

    def get_subtotal_linea(self, obj):
        return float(obj.cantidad * obj.precio_unitario)

    def get_nombre_producto(self, obj):
        if obj.producto:
            return obj.producto.nombre
        return ''

    def get_foto_producto(self, obj):
        request = self.context.get('request')
        if obj.producto and obj.producto.foto:
            if request:
                return request.build_absolute_uri(obj.producto.foto.url)
            return obj.producto.foto.url
        return ''


class CarritoComprasSerializer(serializers.ModelSerializer):
    detalles = DetalleCarritoSerializer(many=True, read_only=True)
    total_items = serializers.SerializerMethodField()

    class Meta:
        model = CarritoCompras
        fields = [
            'idcarrito_compras',
            'subtotal',
            'total',
            'fecha_creacion',
            'estado',
            'usuarios_idusuario',
            'detalles',
            'total_items',
        ]

    def get_total_items(self, obj):
        return sum(d.cantidad for d in obj.detalles.all())