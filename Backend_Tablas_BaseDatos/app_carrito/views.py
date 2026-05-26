from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from .models import CarritoCompras, DetalleCarrito
from rest_framework import serializers

class DetalleCarritoSerializer(serializers.ModelSerializer):
    subtotal = serializers.ReadOnlyField(source='subtotal_linea')
    producto_detalle = serializers.SerializerMethodField()

    class Meta:
        model = DetalleCarrito
        fields = ['iddetalle_carrito', 'cantidad', 'precio_unitario', 'carrito_compras', 'producto', 'subtotal', 'producto_detalle']

    def get_producto_detalle(self, obj):
        if obj.producto:
            return {
                "idproducto": obj.producto.idproducto,
                "nombre": obj.producto.nombre,
                "foto": obj.producto.foto.url if obj.producto.foto else None
            }
        return None

class CarritoComprasSerializer(serializers.ModelSerializer):
    detalles = DetalleCarritoSerializer(many=True, read_only=True)

    class Meta:
        model = CarritoCompras
        fields = ['idcarrito_compras', 'subtotal', 'total', 'fecha_creacion', 'estado', 'usuarios_idusuario', 'detalles']


# --- VIEWSETS QUE REQUERÍA TU URLS.PY ---
class CarritoComprasViewSet(viewsets.ModelViewSet):
    queryset = CarritoCompras.objects.all()
    serializer_class = CarritoComprasSerializer

    def get_queryset(self):
        queryset = CarritoCompras.objects.all()
        usuario = self.request.query_params.get('usuario')
        estado = self.request.query_params.get('estado')
        if usuario:
            queryset = queryset.filter(usuarios_idusuario=usuario)
        if estado:
            queryset = queryset.filter(estado=estado)
        return queryset


class DetalleCarritoViewSet(viewsets.ModelViewSet):
    queryset = DetalleCarrito.objects.all()
    serializer_class = DetalleCarritoSerializer

    def perform_create(self, serializer):
        detalle = serializer.save()
        self._recalcular_totales(detalle.carrito_compras)

    def perform_update(self, serializer):
        detalle = serializer.save()
        self._recalcular_totales(detalle.carrito_compras)

    def perform_destroy(self, instance):
        carrito = instance.carrito_compras
        instance.delete()
        self._recalcular_totales(carrito)

    def _recalcular_totales(self, carrito):
        detalles = DetalleCarrito.objects.filter(carrito_compras=carrito)
        nuevo_total = sum(d.subtotal_linea() for d in detalles)
        
        carrito.subtotal = nuevo_total
        carrito.total = nuevo_total
        carrito.save()
