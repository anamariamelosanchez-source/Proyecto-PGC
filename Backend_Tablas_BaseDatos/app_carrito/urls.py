from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CarritoComprasViewSet, DetalleCarritoViewSet

router = DefaultRouter()
router.register(r'carritos', CarritoComprasViewSet, basename='carrito')
router.register(r'detalles', DetalleCarritoViewSet, basename='detalle-carrito')

urlpatterns = [
    path('', include(router.urls)),
]
