from rest_framework import viewsets, status
from rest_framework.response import Response
from Producto.models import Producto
from .serializers import ProductoSerializer


class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer

    CAMPOS_SINCRONIZAR = [
        ('category_category', 'category_category_id'),
        ('usuarios_idusuario', 'usuarios_idusuario_id'),
    ]

    def _limpiar_data(self, data):
        """Normaliza y sincroniza campos FK que pueden venir con o sin sufijo _id."""
        for campo_base, campo_id in self.CAMPOS_SINCRONIZAR:
            valor = data.get(campo_id) or data.get(campo_base)
            if valor is not None:
                valor = str(valor).replace('"', '').replace('\\', '').strip()
                data[campo_base] = valor
                data[campo_id] = valor
        return data  

    def create(self, request, *args, **kwargs):
        data = self._limpiar_data(request.data.copy())
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        data = self._limpiar_data(request.data.copy())
        serializer = self.get_serializer(instance, data=data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)