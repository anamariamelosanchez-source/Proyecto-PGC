from rest_framework import viewsets, status
from rest_framework.response import Response
from .models import Producto, CategoriaProducto, CategoriaHasProductos
from .serializers import ProductoSerializer, CategoriaProductoSerializer, CategoriaHasProductosSerializer

class CategoriaProductoViewSet(viewsets.ModelViewSet):
    """Maneja el catálogo de categorías en el backend"""
    queryset = CategoriaProducto.objects.all()
    serializer_class = CategoriaProductoSerializer


class CategoriaHasProductosViewSet(viewsets.ModelViewSet):
    """Maneja la relación intermedia de categorías y productos"""
    queryset = CategoriaHasProductos.objects.all()
    serializer_class = CategoriaHasProductosSerializer


class ProductoViewSet(viewsets.ModelViewSet):
    """
    Controlador que procesa los productos. Intercepta y limpia las comillas
    extra (\"3\") enviadas por Flutter Web antes de validar el formulario.
    """
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer

    def create(self, request, *args, **kwargs):
        data = request.data.copy()

        if 'category_category' in data:
            valor = str(data['category_category']).replace('"', '').replace('\\', '').strip()
            data['category_category'] = valor
            data['category_category_id'] = valor
            
        if 'category_category_id' in data:
            valor = str(data['category_category_id']).replace('"', '').replace('\\', '').strip()
            data['category_category'] = valor
            data['category_category_id'] = valor

        # Limpieza estricta para el ID del Usuario creador
        if 'usuarios_idusuario' in data:
            valor_usr = str(data['usuarios_idusuario']).replace('"', '').replace('\\', '').strip()
            data['usuarios_idusuario'] = valor_usr
            data['usuarios_idusuario_id'] = valor_usr
            
        if 'usuarios_idusuario_id' in data:
            valor_usr = str(data['usuarios_idusuario_id']).replace('"', '').replace('\\', '').strip()
            data['usuarios_idusuario'] = valor_usr
            data['usuarios_idusuario_id'] = valor_usr

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        data = request.data.copy()

        if 'category_category' in data:
            valor = str(data['category_category']).replace('"', '').replace('\\', '').strip()
            data['category_category'] = valor
            data['category_category_id'] = valor
        if 'category_category_id' in data:
            valor = str(data['category_category_id']).replace('"', '').replace('\\', '').strip()
            data['category_category'] = valor
            data['category_category_id'] = valor

        if 'usuarios_idusuario' in data:
            valor_usr = str(data['usuarios_idusuario']).replace('"', '').replace('\\', '').strip()
            data['usuarios_idusuario'] = valor_usr
            data['usuarios_idusuario_id'] = valor_usr
        if 'usuarios_idusuario_id' in data:
            valor_usr = str(data['usuarios_idusuario_id']).replace('"', '').replace('\\', '').strip()
            data['usuarios_idusuario'] = valor_usr
            data['usuarios_idusuario_id'] = valor_usr

        serializer = self.get_serializer(instance, data=data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)
