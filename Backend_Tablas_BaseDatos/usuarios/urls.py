from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UsuariosViewSet,login_personalizado

router = DefaultRouter()
router.register(r'usuarios', UsuariosViewSet, basename='usuario')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', login_personalizado, name='login_personalizado'),
    path('', login_personalizado, name='registrar_usuario'),
    
]
