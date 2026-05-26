from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductoViewSet, CategoriaHasProductosViewSet, CategoriaProductoViewSet
router = DefaultRouter()

router.register(r'productos', ProductoViewSet, basename='producto')
router.register(r'categorias', CategoriaProductoViewSet, basename= 'categoria')
router.register(r'categoria-productos', CategoriaHasProductosViewSet, basename= 'categoriaproducto')
urlpatterns = [
    path('api/', include(router.urls)),
]
